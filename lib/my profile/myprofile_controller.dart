import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> currentUser = Rx<User?>(null);
  RxString userProfilePic = ''.obs;
  RxString fullName = ''.obs;
  RxString email = ''.obs;
  RxString phoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      if (currentUser.value == null) {
        print('Current user is null');
        return;
      }

      var userSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .get();

      if (userSnapshot.exists) {
        // Ensure the fields in your Firestore document match these names
        userProfilePic.value = userSnapshot.get('userProfilePic') ?? '';
        fullName.value = userSnapshot.get('fullName') ?? '';
        email.value = userSnapshot.get('email') ?? '';
        phoneNumber.value = userSnapshot.get('phoneNumber') ?? '';

        print('User Profile Fetched: ${userProfilePic.value}, ${fullName.value}, ${email.value}, ${phoneNumber.value}');
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }


  Future<void> updateProfilePicture() async {
    try {
      if (currentUser.value == null) {
        print('Current user is null');
        return;
      }

      await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .update({'userProfilePic': userProfilePic.value});
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

// Additional logic for updating other user details goes here

// ... existing code ...
}
