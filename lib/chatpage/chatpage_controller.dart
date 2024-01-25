import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
class ChatMessage {
  final String text;
  final String senderId;
  final bool isCurrentUserMessage;
  final DateTime timestamp;
  final String? imageUrl; // Make imageUrl optional by using String?

  ChatMessage({
    required this.text,
    required this.senderId,
    required this.isCurrentUserMessage,
    required this.timestamp,
    this.imageUrl, // Make imageUrl optional
  });
}



class ChatController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _selectedImage;

  late User _currentUser;
  late String _selectedUserId;
  // Change from late String to RxString
  RxString _selectedUserFullName = ''.obs;

  // Getter for selectedUserFullName
  String get selectedUserFullName => _selectedUserFullName.value;

  final TextEditingController messageController = TextEditingController();
  RxList<ChatMessage> messageWidgets = <ChatMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    _currentUser = _auth.currentUser!;
    Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>? ?? {};
    _selectedUserId = arguments['selectedUserId'] as String? ?? '';

    // Fetch the selected user's full name
    fetchSelectedUserFullName();

    fetchMessages();
  }

  Future<void> fetchSelectedUserFullName() async {
    try {
      var recipientUserSnapshot =
      await _firestore.collection('users').doc(_selectedUserId).get();
      _selectedUserFullName.value = recipientUserSnapshot.get('fullName');
    } catch (e) {
      print('Error fetching selected user full name: $e');
      // Set a default value for _selectedUserFullName
      _selectedUserFullName.value = 'User';
    }
  }





  String _chatRoomId() {
    List<String> userIds = [_currentUser.uid, _selectedUserId];
    userIds.sort();
    return userIds.join('_');
  }

  Future<void> fetchMessages() async {
    try {
      var snapshot = await _firestore
          .collection('messages')
          .doc(_chatRoomId())
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      List<QueryDocumentSnapshot> messages = snapshot.docs;

      messageWidgets.assignAll(
        messages.map(
              (message) {
            bool isCurrentUserMessage = message['senderId'] == _currentUser.uid;

            // Check if 'text' field exists before accessing
            String text = message['text'] ?? '';

            // Check if 'imageUrl' field exists and is not null before accessing
            String? imageUrl =
            message['imageUrl'] != null ? message['imageUrl']! : null;

            return ChatMessage(
              text: text,
              senderId: message['senderId'] ?? '',
              isCurrentUserMessage: isCurrentUserMessage,
              timestamp: (message['timestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              imageUrl: imageUrl,
            );
          },
        ),
      );
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }



  Future<void> sendMessage() async {
    String text = messageController.text.trim();

    if (text.isNotEmpty) {
      var recipientUserSnapshot =
      await _firestore.collection('users').doc(_selectedUserId).get();
      String recipientUserFullName = recipientUserSnapshot.get('fullName');

      await _firestore
          .collection('messages')
          .doc(_chatRoomId())
          .collection('messages')
          .add({
        'text': text,
        'senderId': _currentUser.uid,
        'recipientId': _selectedUserId,
        'recipientFullName': recipientUserFullName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      messageController.clear();
    } else if (_selectedImage != null) {
      await uploadImage(_selectedImage!);
    }
  }


  Future<void> uploadImage(File imageFile) async {
    try {
      if (_selectedUserId.isNotEmpty) {
        var storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('chat_images/${_currentUser.uid}_${_selectedUserId}/${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(imageFile);

        var imageUrl = await storageRef.getDownloadURL();

        await _firestore
            .collection('messages')
            .doc(_chatRoomId())
            .collection('messages')
            .add({
          'imageUrl': imageUrl,
          'senderId': _currentUser.uid,
          'recipientId': _selectedUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print('Error: _selectedUserId is empty');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}
