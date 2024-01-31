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
  late List<DocumentSnapshot> users; // Add this line to store users
  late User _currentUser;

  RxList<Widget> contactCards = <Widget>[].obs;
  RxList<String> selectedContacts = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _currentUser = _auth.currentUser!;
    fetchContactCards();
  }

  Future<String?> getUserProfilePictureUrl(String userId) async {
    try {
      var snapshot = await _firestore.collection('users').doc(userId).get();
      return snapshot['profilePictureUrl'] as String?;
    } catch (e) {
      print('Error fetching profile picture URL: $e');
      return null;
    }
  }

  void createNewGroup() {
    Get.to(() => CreateGroupPage(selectedContacts: selectedContacts));
  }

  void toggleContactSelection(String userId) {
    if (selectedContacts.contains(userId)) {
      selectedContacts.remove(userId);
    } else {
      selectedContacts.add(userId);
    }
  }

  Future<void> fetchContactCards() async {
    try {
      var snapshot = await _firestore.collection('users').get();
      users = snapshot.docs;

      users.sort((a, b) => (a['fullName'] as String).compareTo(b['fullName'] as String));

      for (var user in users) {
        String fullName = user['fullName'];
        String userId = user.id;

        if (userId != _currentUser.uid) {
          String contactInitial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '';

          contactCards.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () async {
                  await _firestore
                      .collection('users')
                      .doc(_currentUser.uid)
                      .update({
                    'ongoingChats': FieldValue.arrayUnion([userId]),
                  });

                  Get.to(() => ChatPage(
                    currentUser: _currentUser,
                    selectedUserId: userId,
                  ),
                      arguments: {'selectedUserId': userId, 'currentUser': _currentUser});
                },
                child: Card(
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: FutureBuilder<String?>(
                          future: getUserProfilePictureUrl(userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              String? profilePictureUrl = snapshot.data;
                              return CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: profilePictureUrl != null
                                    ? NetworkImage(profilePictureUrl)
                                    : null,
                              );
                            } else {
                              return CircleAvatar(
                                backgroundColor: Colors.grey,
                              );
                            }
                          },
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

  // Method for updating the contact list based on the search query
  Future<void> updateContactListAsync(String query) async {
    // Fetch updated contacts asynchronously
    await fetchContactCards();

    // Clear the existing contact list
    contactCards.clear();

    // Filter contacts based on the query
    for (var user in users) {
      String fullName = user['fullName'];
      String userId = user.id;

      if (fullName.toLowerCase().contains(query.toLowerCase())) {
        // Add matching contacts to the list
        contactCards.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: () async {
                await _firestore
                    .collection('users')
                    .doc(_currentUser.uid)
                    .update({
                  'ongoingChats': FieldValue.arrayUnion([userId]),
                });

                Get.to(() => ChatPage(
                  currentUser: _currentUser,
                  selectedUserId: userId,
                ),
                    arguments: {'selectedUserId': userId, 'currentUser': _currentUser});
              },
              child: Card(
                child: Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: FutureBuilder<String?>(
                        future: getUserProfilePictureUrl(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            String? profilePictureUrl = snapshot.data;
                            if (profilePictureUrl != null) {
                              return CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(profilePictureUrl),
                              );
                            } else {
                              // No profile picture, display the first letter of the full name
                              String contactInitial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '';
                              return CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Text(
                                  contactInitial,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          } else {
                            // Loading state
                            return CircleAvatar(
                              backgroundColor: Colors.grey,
                            );
                          }
                        },
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
  }

}