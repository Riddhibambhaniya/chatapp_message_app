import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        return {
          'userId': doc.id,
          'fullName': doc['fullName'],
          // Add other user details as needed
        };
      }).toList());

      // Remove the current user from the contact list
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
      print('Group Name: $groupName');
      print('Selected Contacts: $selectedContacts');

      // Reset controllers and selected contacts
      groupNameController.clear();
      selectedContacts.clear();

      Get.back(); // Navigate back or perform any other action
    } else {
      Get.snackbar('Error', 'Group name and contacts are required',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}