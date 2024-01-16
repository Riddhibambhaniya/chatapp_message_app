import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messageapp/chatpage/chatpage.dart';

class ContactController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _currentUser;

  RxList<Widget> contactCards = <Widget>[].obs;

  @override
  void onInit() {
    super.onInit();
    _currentUser = _auth.currentUser!;
    fetchContactCards();
  }

  Future<void> fetchContactCards() async {
    try {
      var snapshot = await _firestore.collection('users').get();
      List<DocumentSnapshot> users = snapshot.docs;

      for (var user in users) {
        String fullName = user['fullName'];
        String userId = user.id;

        if (userId != _currentUser.uid) {
          contactCards.add(
            // contactpage.dart
              GestureDetector(
                onTap: () async {
                  await _firestore
                      .collection('users')
                      .doc(_currentUser.uid)
                      .update({
                    'ongoingChats': FieldValue.arrayUnion([userId]),
                  });

                  // Navigate to chat screen with selected user
                  Get.to(() => ChatPage(currentUser: _currentUser,
                    selectedUserId: userId,),
                      arguments: {'selectedUserId': userId, 'currentUser': _currentUser});
                },
                child: Card(
                  child: ListTile(
                    title: Text(fullName),
                  ),
                ),
              )

          );
        }
      }
    } catch (e) {
      print('Error fetching contact cards: $e');
    }
  }
}
