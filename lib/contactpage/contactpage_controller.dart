import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messageapp/chatpage/chatpage.dart';

import '../create group/create group_UI.dart';
import '../styles/text_style.dart';

class ContactController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _currentUser;

  RxList<Widget> contactCards = <Widget>[].obs;
  RxList<String> selectedContacts = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _currentUser = _auth.currentUser!;
    fetchContactCards();
  }

  void createNewGroup() {
    // Navigate to the create group screen and pass the selected contacts
    Get.to(() => CreateGroupPage(selectedContacts: selectedContacts));
  }

  void toggleContactSelection(String userId) {
    // Toggle the selection of a contact
    if (selectedContacts.contains(userId)) {
      selectedContacts.remove(userId);
    } else {
      selectedContacts.add(userId);
    }
  }

  Future<void> fetchContactCards() async {
    try {
      var snapshot = await _firestore.collection('users').get();
      List<DocumentSnapshot> users = snapshot.docs;

      // Sort users alphabetically based on fullName
      users.sort((a, b) => (a['fullName'] as String).compareTo(b['fullName'] as String));

      for (var user in users) {
        String fullName = user['fullName'];
        String userId = user.id;

        if (userId != _currentUser.uid) {
          String contactInitial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '';

          contactCards.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust vertical padding as needed
              child: GestureDetector(
                onTap: () async {
                  await _firestore
                      .collection('users')
                      .doc(_currentUser.uid)
                      .update({
                    'ongoingChats': FieldValue.arrayUnion([userId]),
                  });

                  // Navigate to chat screen with selected user
                  Get.to(() => ChatPage(
                    currentUser: _currentUser,
                    selectedUserId: userId,
                  ),
                      arguments: {'selectedUserId': userId, 'currentUser': _currentUser});
                },
                child: Card(
                  child: Container(
                    color: Colors.white, // Set the transparent color here
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Text(contactInitial, style: textBolds),
                        ),
                      ),
                      title: Text(fullName, style: textBolds),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error fetching contact cards: $e');
    }
  }
}