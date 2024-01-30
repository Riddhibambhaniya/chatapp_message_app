import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'pollpage/create_poll_controller.dart';

class GroupChatController extends GetxController {
  RxString groupId = ''.obs;
  RxString groupName = ''.obs;
  RxList<GroupMessage> groupMessages = <GroupMessage>[].obs;
  TextEditingController messageController = TextEditingController();
  RxString selectedChoice = ''.obs;
  RxMap selectedChoices = {}.obs; // Initialize with an empty map

  @override
  void onInit() {
    super.onInit();
    ever(groupId, (_) {
      print('groupId changed to: ${groupId.value}');
      fetchGroupMessages();
    });

    // Ensure that the user is authenticated before initializing the controller
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      initialize(currentUser);
    }
  }
  void initialize(User currentUser) {
    // Initialize the controller based on the current user
    // Set any initial values or perform tasks related to the user
    // ...
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
          return GroupMessage.fromMap(doc.id, data);
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
            'timestamp': Timestamp.now(),
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
        var storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('group_images')
            .child(groupId.value)
            .child('${DateTime.now().millisecondsSinceEpoch}_${currentUser.uid}.jpg');

        await storageRef.putFile(imageFile);

        var imageUrl = await storageRef.getDownloadURL();

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
            'imageUrl': imageUrl,
            'timestamp': Timestamp.now(),
          });
        });
      } else {
        print('Error: currentUser or groupId is invalid');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void sendPoll(PollModel poll) async {
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
            'poll': poll.toMap(),
            'timestamp': Timestamp.now(),
          });
        });
      } else {
        print('Error: currentUser or groupId is invalid');
      }
    } catch (e) {
      print('Error sending poll: $e');
    }
  }

  void submitPollResponse(PollModel poll) async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && groupId.value.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get()
            .then((userDoc) async {
          var senderName = userDoc.get('fullName') ?? 'Unknown';

          // Perform null check on selectedChoices[poll.question]
          var pollResponse = Get.find<GroupChatController>()
              .selectedChoices[poll.question] ?? 'No response';

          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId.value)
              .collection('messages')
              .add({
            'senderId': currentUser.uid,
            'senderName': senderName,
            'poll_response': pollResponse,
            'timestamp': FieldValue.serverTimestamp(),
          });
        });
      } else {
        print('Error: currentUser or groupId is invalid');
      }
    } catch (e) {
      print('Error submitting poll response: $e');
    }
  }

}

class GroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? text;
  final String? imageUrl;
  final Timestamp timestamp;
  final PollModel? poll;

  GroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.text,
    this.imageUrl,
    required this.timestamp,
    this.poll,
  });

  factory GroupMessage.fromMap(String id, Map<String, dynamic> map) {
    return GroupMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'],
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'] ?? Timestamp.now(),
      poll: map['poll'] != null ? PollModel.fromMap(map['poll']) : null,
    );
  }
}
