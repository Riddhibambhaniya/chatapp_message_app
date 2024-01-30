// myprofile_controller.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth.controller.dart';

class MyProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  var userName = ''.obs;
  var userEmail = RxString('');
  var userPhoneNumber = RxString('');
  var userProfilePic = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadUserData();
  }
  Future<String?> getUserProfilePictureUrl({required String userId}) async {
    try {
      // Assuming you have a "users" collection in Firestore
      var userSnapshot = await _firestore.collection('users').doc(userId).get();

      // Check if the user exists
      if (userSnapshot.exists) {
        var userProfile = userSnapshot.data();
        // Assuming you store the profile picture URL under the key "profilePictureUrl"
        String? profilePictureUrl = userProfile?['profilePictureUrl'];

        return profilePictureUrl;
      } else {
        // User not found
        return null;
      }
    } catch (e) {
      print('Error getting user profile picture URL: $e');
      return null;
    }
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    if (uid != null) {
      await getUserDataFromFirestore(uid);
    }
  }

  Future<void> getUserDataFromFirestore(String userId) async {
    try {
      var userData = await _firestore.collection('users').doc(userId).get();
      if (userData.exists) {
        userName.value = userData['fullName'];
        userEmail.value = userData['email'];
        userProfilePic.value = userData['profilePictureUrl'];
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> updateProfileDetails({
    required String newDisplayName,
    required String newEmail,
    required String newPhoneNumber,
  }) async {
    final userUid = _auth.currentUser?.uid;

    if (userUid != null) {
      await _firestore.collection('users').doc(userUid).update({
        'fullName': newDisplayName,
        'email': newEmail,
        'phoneNumber': newPhoneNumber,
      });

      // Update the Rx variables to trigger updates in the UI
      userName.value = newDisplayName;
      userEmail.value = newEmail;
      userPhoneNumber.value = newPhoneNumber;
    }

    saveUserDataToSharedPreferences(userUid, newDisplayName, newEmail);
  }

  Future<void> uploadAndSetProfilePicture(File imageFile) async {
    try {
      final userUid = _auth.currentUser?.uid;

      // Upload image to Firebase Storage
      final storageRef = _storage.ref().child('profile_pictures/$userUid.jpg');
      await storageRef.putFile(imageFile);

      // Get the download URL of the uploaded image
      final imageUrl = await storageRef.getDownloadURL();

      // Update the user's profile picture URL in Firestore
      await _firestore.collection('users').doc(userUid).update({
        'profilePictureUrl': imageUrl,
      });

      // Update the Rx variable to trigger updates in the UI
      userProfilePic.value = imageUrl;

      // Save user data to SharedPreferences
      saveUserDataToSharedPreferences(userUid, userName.value, userEmail.value);
    } catch (e) {
      print('Error uploading and setting profile picture: $e');
    }
  }

  Future<void> saveUserDataToSharedPreferences(
      String? userUid, String? userName, String? userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userUid != null) prefs.setString('uid', userUid);
    if (userName != null) prefs.setString('fullName', userName);
    if (userEmail != null) prefs.setString('email', userEmail);
  }

  Future<void> clearUserDataOnLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
  }

  void logOut() {
    clearUserDataOnLogout();
    authController.signOutAndNavigateToOnboarding();
  }

  Future<void> updateProfilePicture() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadAndSetProfilePicture(imageFile);
    }
  }
}
