import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _currentUser;
  late String _selectedUserId;

  final TextEditingController messageController = TextEditingController();
  RxList<Widget> messageWidgets = <Widget>[].obs;

  static ChatController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    _currentUser = _auth.currentUser!;

    // Get the selectedUserId from the arguments
    Map<String, dynamic>? arguments = Get.arguments as Map<String, dynamic>?;
    _selectedUserId = arguments?['selectedUserId'] as String? ?? '';

    fetchMessages();
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
              (message) => ListTile(
            title: Text(message['text']),
            subtitle: Text(message['senderId']),
          ),
        ),
      );
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage() async {
    String text = messageController.text.trim();

    if (text.isNotEmpty) {
      await _firestore
          .collection('messages')
          .doc(_chatRoomId())
          .collection('messages')
          .add({
        'text': text,
        'senderId': _currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      messageController.clear();
    }
  }
}
