import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class GroupChatController extends GetxController {
  RxString groupId = ''.obs;
  RxString groupName = ''.obs;
  RxList<GroupMessage> groupMessages = <GroupMessage>[].obs;
  TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ever(groupId, (_) {
      print('groupId changed to: ${groupId.value}');
      fetchGroupMessages();
    });
  }

  void fetchGroupMessages() async {
    try {
      if (groupId.value.isNotEmpty) {
        var messagesSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId.value)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

        groupMessages.assignAll(messagesSnapshot.docs.map((doc) {
          var data = doc.data();
          print('Data from Firestore: $data');
          return GroupMessage.fromMap(data);
        }).toList());

      } else {
        print('Error: groupId is empty');
      }
    } catch (e) {
      print('Error fetching group messages: $e');
    }
  }

  // GroupChatController
  void sendMessage() async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && groupId.value.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get()
            .then((userDoc) async {
          var senderName = userDoc.get('fullName') ?? 'Unknown';

          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId.value)
              .collection('messages')
              .add({
            'senderId': currentUser.uid,
            'senderName': senderName,
            'text': messageController.text,
            'timestamp': FieldValue.serverTimestamp(),
          });

          messageController.clear();
        });
      } else {
        print('Error: currentUser or groupId is invalid');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void uploadImage(File imageFile) async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && groupId.value.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get()
            .then((userDoc) async {
          var senderName = userDoc.get('fullName') ?? 'Unknown';

          var storageRef = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('groups/${groupId.value}/${DateTime.now().millisecondsSinceEpoch}.jpg');

          await storageRef.putFile(imageFile);

          var imageUrl = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId.value)
              .collection('messages')
              .add({
            'senderId': currentUser.uid,
            'senderName': senderName,
            'imageUrl': imageUrl,
            'timestamp': FieldValue.serverTimestamp(),
          });

          messageController.clear();
        });
      } else {
        print('Error: currentUser or groupId is invalid');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

}

class GroupMessage {
  final String senderId;
  final String senderName;
  final String? text;
  final String? imageUrl;
  final Timestamp timestamp;

  GroupMessage({
    required this.senderId,
    required this.senderName,
    this.text,
    this.imageUrl,
    required this.timestamp,
  });

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      senderId: map['senderId'] ?? '',
      senderName: map['senderName']?.toString().isNotEmpty ?? false
          ? map['senderName'].toString()
          : 'Unknown',
      text: map['text'] ?? null,
      imageUrl: map['imageUrl'] ?? null,
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}