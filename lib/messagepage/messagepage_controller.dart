import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> currentUser = Rx<User?>(null);
  RxList<UserWithTimestamp> usersWithTimestamp = <UserWithTimestamp>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    fetchOngoingChats();
  }

  Future<void> fetchOngoingChats() async {
    try {
      if (currentUser.value == null) {
        print('Current user is null');
        return;
      }

      var snapshot = await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .get();
      List<dynamic> ongoingChats = snapshot.get('ongoingChats') ?? [];

      usersWithTimestamp.clear(); // Clear the previous data

      for (var userId in ongoingChats) {
        var latestMessage = await _firestore
            .collection('messages')
            .doc(_generateChatId(userId))
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        Timestamp latestMessageTimestamp = Timestamp.now();
        String recipientFullName = '';
        String lastMessageText = ''; // Initialize lastMessageText

        if (latestMessage.docs.isNotEmpty) {
          var lastMessageData = latestMessage.docs.first.data();
          latestMessageTimestamp = lastMessageData['timestamp'];
          recipientFullName = lastMessageData['recipientId'] == currentUser.value!.uid
              ? lastMessageData['senderId']
              : lastMessageData['recipientFullName'];
          lastMessageText = lastMessageData['text']; // Assign lastMessageText correctly
        }

        usersWithTimestamp.add(UserWithTimestamp(userId, latestMessageTimestamp, recipientFullName, lastMessageText));
      }

      // Sort users based on the latest message timestamp
      usersWithTimestamp.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error fetching ongoing chats: $e');
    }
  }

  String _generateChatId(String userId) {
    List<String> userIds = [currentUser.value!.uid, userId];
    userIds.sort();
    return userIds.join('_');
  }
}

class UserWithTimestamp {
  final String userId;
  final Timestamp timestamp;
  final String recipientFullName;
  final String lastMessage;

  UserWithTimestamp(this.userId, this.timestamp, this.recipientFullName, this.lastMessage);
}
