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
      var userSnapshot = await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        var userProfile = userSnapshot.data();
        String? profilePictureUrl = userProfile?['profilePictureUrl'];

        return profilePictureUrl;
      } else {
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

      userName.value = newDisplayName;
      userEmail.value = newEmail;
      userPhoneNumber.value = newPhoneNumber;
    }

    saveUserDataToSharedPreferences(userUid, newDisplayName, newEmail);
  }

  Future<void> uploadAndSetProfilePicture(File imageFile) async {
    try {
      final userUid = _auth.currentUser?.uid;

      final storageRef = _storage.ref().child('profile_pictures/$userUid.jpg');
      await storageRef.putFile(imageFile);

      final imageUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(userUid).update({
        'profilePictureUrl': imageUrl,
      });

      userProfilePic.value = imageUrl;

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
