import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          return GroupMessage.fromMap(doc.data());
        }).toList());
      } else {
        print('Error: groupId is empty');
      }
    } catch (e) {
      print('Error fetching group messages: $e');
    }
  }

  void sendMessage() async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && groupId.value.isNotEmpty) {
        // Get the sender's name
        var senderName = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get()
            .then((doc) => doc.get('fullName') ?? 'Unknown');

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

        // Clear the message input field
        messageController.clear();
      } else {
        print('Error: currentUser or groupId is invalid');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

class GroupMessage {
  final String senderId;
  final String senderName;
  final String text;
  final Timestamp timestamp;

  GroupMessage(this.senderId, this.senderName, this.text, this.timestamp);

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      map['senderId'] ?? '',
      map['senderName'] ?? 'Unknown',
      map['text'] ?? '',
      map['timestamp'] ?? Timestamp.now(),
    );
  }
}
