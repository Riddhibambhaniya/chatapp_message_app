// myprofile_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth.controller.dart';

class MyProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var userName = ''.obs;
  var userEmail = RxString('');
  var userPhoneNumber = RxString('');
  var userProfilePic = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await getUserDataFromSharedPreferences();
  }

  Future<void> updateProfileDetails({
    required String newDisplayName,
    required String newEmail,
    required String newPhoneNumber,
  }) async {
    final userUid = _auth.currentUser?.uid;

    if (userUid != null) {
      await FirebaseFirestore.instance.collection('users').doc(userUid).update({
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

  Future<void> updateProfilePicture(String newProfilePictureUrl) async {
    final userUid = _auth.currentUser?.uid;

    if (userUid != null) {
      await FirebaseFirestore.instance.collection('users').doc(userUid).update({
        'profilePictureUrl': newProfilePictureUrl,
      });

      userProfilePic.value = newProfilePictureUrl;
    }

    saveUserDataToSharedPreferences(userUid, userName.value, userEmail.value);
  }

  Future<void> saveUserDataToSharedPreferences(
      String? userUid, String? userName, String? userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userUid != null) prefs.setString('uid', userUid);
    if (userName != null) prefs.setString('fullName', userName);
    if (userEmail != null) prefs.setString('email', userEmail);
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('fullName') ?? '';
    userEmail.value = prefs.getString('email') ?? '';
    userProfilePic.value = prefs.getString('profilePictureUrl') ?? '';
  }


  Future<void> clearUserDataOnLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    prefs.remove('fullName');
    prefs.remove('email');
    prefs.remove('profilePictureUrl');
  }

  void logOut() {
    clearUserDataOnLogout();
    authController.signOutAndNavigateToOnboarding();
  }

}
