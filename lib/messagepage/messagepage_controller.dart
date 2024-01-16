import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../chatpage/chatpage.dart';

class MessageController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> currentUser = Rx<User?>(null);
  RxList<Widget> messageCards = <Widget>[].obs;

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

      List<UserWithTimestamp> usersWithTimestamp = [];

      for (var userId in ongoingChats) {
        var latestMessage = await _firestore
            .collection('messages')
            .doc(_generateChatId(userId))
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        Timestamp latestMessageTimestamp = Timestamp.now();
        String recipientFullName = ''; // Initialize recipientFullName

        if (latestMessage.docs.isNotEmpty) {
          var lastMessageData = latestMessage.docs.first.data();
          latestMessageTimestamp = lastMessageData['timestamp'];
          recipientFullName = lastMessageData['recipientFullName'];
        }

        usersWithTimestamp.add(UserWithTimestamp(userId, latestMessageTimestamp, recipientFullName));
      }

      // Sort users based on the latest message timestamp
      usersWithTimestamp.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      messageCards.assignAll(
        usersWithTimestamp.map(
              (user) {
            String userId = user.userId;

            return GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(user.recipientFullName), // Display recipient's name
                  subtitle: Text('Last Message: ${user.timestamp.toDate()}'),
                ),
              ),
              onTap: () {
                // Navigate to chat screen with selected user
                Get.to(() => ChatPage(
                  currentUser: currentUser.value!,
                  selectedUserId: userId,
                ), arguments: {'selectedUserId': userId, 'currentUser': currentUser});
              },
            );
          },
        ).toList(),
      );
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

  UserWithTimestamp(this.userId, this.timestamp,this.recipientFullName);
}
