
// MessageController
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> currentUser = Rx<User?>(null);
  RxList<Chat> personalChats = <Chat>[].obs;
  RxList<GroupChat> groupChats = <GroupChat>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    fetchChats();
  }

  Future<void> fetchChats() async {
    try {
      if (currentUser.value == null) {
        print('Current user is null');
        return;
      }

      // Fetch personal chats
      await fetchPersonalChats();

      // Fetch group chats
      await fetchGroupChats();
    } catch (e) {
      print('Error fetching chats: $e');
    }
  }

  Future<void> fetchPersonalChats() async {
    try {
      var snapshot = await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .get();

      // Ensure "ongoingChats" field is present and is a List
      List<dynamic> ongoingChats = snapshot.get('ongoingChats') ?? [];
      if (!(ongoingChats is List)) {
        ongoingChats = [];
      }

      personalChats.clear();


      for (var userId in ongoingChats) {
        // Fetch user data to get the full name
        var userSnapshot = await _firestore.collection('users').doc(userId).get();
        var fullName = userSnapshot.get('fullName') ?? 'Unknown';

        // Fetch the latest message for the chat
        var latestMessage = await _firestore
            .collection('messages')
            .doc(_generateChatId(userId))
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        Timestamp latestMessageTimestamp = Timestamp.now();

        if (latestMessage.docs.isNotEmpty) {
          var lastMessageData = latestMessage.docs.first.data();
          latestMessageTimestamp = lastMessageData['timestamp'];
        }

        personalChats.add(Chat(userId, fullName, latestMessageTimestamp));
      }

      personalChats.sort((a, b) => b.latestMessageTimestamp.compareTo(a.latestMessageTimestamp));
    } catch (e) {
      print('Error fetching personal chats: $e');
    }
  }


  Future<void> fetchGroupChats() async {
    try {
      var snapshot = await _firestore
          .collection('groups')
          .where('members', arrayContains: currentUser.value!.uid)
          .get();

      groupChats.assignAll(snapshot.docs.map((doc) {
        var groupChat = GroupChat.fromMap(doc.data());
        print('Group ID: ${groupChat.groupId}');
        return groupChat;
      }).toList());
      groupChats.sort((a, b) {
        final aTimestamp = a.latestMessageTimestamp;
        final bTimestamp = b.latestMessageTimestamp;

        if (aTimestamp == null && bTimestamp == null) {
          return 0;
        } else if (aTimestamp == null) {
          return 1;
        } else if (bTimestamp == null) {
          return -1;
        }

        return bTimestamp.compareTo(aTimestamp);
      });

      await fetchGroupMessagesForChats();
    } catch (e) {
      print('Error fetching group chats: $e');
    }
  }

  Future<void> fetchGroupMessagesForChats() async {
    try {
      for (var groupChat in groupChats) {
        if (groupChat.groupId.isNotEmpty) {
          var messagesSnapshot = await _firestore
              .collection('groups')
              .doc(groupChat.groupId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (messagesSnapshot.docs.isNotEmpty) {
            var lastMessageData = messagesSnapshot.docs.first.data();
            groupChat.latestMessageTimestamp = lastMessageData['timestamp'];

            // Update GroupMessage with senderName
            groupChat.latestMessage = GroupMessage(
              lastMessageData['senderId'],
              lastMessageData['senderName'], // Make sure senderName is stored in Firestore
              lastMessageData['text'],
              lastMessageData['timestamp'],
            );
          } else {
            print('Warning: No messages found for group chat with ID ${groupChat.groupId}');
            // Handle the situation when there are no messages for this group chat
          }
        } else {
          print('Warning: groupId is empty for a group chat');
          // Handle the situation when groupId is empty for a group chat
        }
      }
      update();
    } catch (e) {
      print('Error fetching group messages for chats: $e');
    }
  }


  String _generateChatId(String userId) {
    List<String> userIds = [currentUser.value!.uid, userId];
    userIds.sort();
    return userIds.join('_');
  }
}

class Chat {
final String userId;
final String fullName;
final Timestamp latestMessageTimestamp;

Chat(this.userId, this.fullName, this.latestMessageTimestamp);
}

class GroupChat {
  final String groupId;
  final String groupName;
  final List<String> groupMembers; // Add this line
  late Timestamp latestMessageTimestamp;
  late GroupMessage? latestMessage;

  GroupChat(this.groupId, this.groupName, this.groupMembers, this.latestMessageTimestamp);

  factory GroupChat.fromMap(Map<String, dynamic> map) {
    return GroupChat(
      map['groupId'] ?? '',
      map['groupName'] ?? '',
      List<String>.from(map['groupMembers'] ?? []),
      map['latestMessageTimestamp'] ?? Timestamp.now(),
    );
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