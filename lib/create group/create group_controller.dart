import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../groupchat/groupchat_UI.dart';
import '../messagepage/messagepage_controller.dart';

class CreateGroupController extends GetxController {
  RxList<Map<String, dynamic>> contacts = <Map<String, dynamic>>[].obs;
  RxList<String> selectedContacts = <String>[].obs;
  TextEditingController groupNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchContacts();
  }

  void fetchContacts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      contacts.assignAll(snapshot.docs.map((doc) {
        var fullName = doc['fullName'] as String?;
        return {
          'userId': doc.id,
          'fullName': fullName ?? 'Unknown',
        };
      }).toList());
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        contacts.removeWhere((contact) => contact['userId'] == currentUser.uid);
      }
    } catch (e) {
      print('Error fetching contacts: $e');
    }
  }

  void toggleContactSelection(String userId) {
    if (selectedContacts.contains(userId)) {
      selectedContacts.remove(userId);
    } else {
      selectedContacts.add(userId);
    }
    update();
  }

  void createGroup() {
    String groupName = groupNameController.text.trim();
    if (groupName.isNotEmpty && selectedContacts.isNotEmpty) {
      // Create a group in Firestore
      var groupRef = FirebaseFirestore.instance.collection('groups').doc();
      var groupId = groupRef.id; // This line retrieves the group ID

      // Add group details
      groupRef.set({
        'groupId': groupId,  // Add this line to store groupId
        'groupName': groupName,
        'members': [FirebaseAuth.instance.currentUser!.uid, ...selectedContacts],
        'latestMessageTimestamp': FieldValue.serverTimestamp(),
      });


      // Reset controllers and selected contacts
      groupNameController.clear();
      selectedContacts.clear();

      // Fetch group chats again to update the state
      Get.find<MessageController>().fetchGroupChats();

      Get.back(); // Navigate back or perform any other action
      Get.to(() => GroupChatPage(groupId: groupId, groupName: groupName));
    } else {
      Get.snackbar('Error', 'Group name and contacts are required',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

}
