import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dashbord/dashbord_page.dart';
import '../sign_in/sign_in_page.dart';

class SignUpController extends GetxController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reEnterPasswordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  RxBool emailError = false.obs;
  RxBool passwordError = false.obs;
  RxBool isFormValid = false.obs;
  final formKey = GlobalKey<FormState>();

  String? profilePictureUrl; // Add a variable to store profile picture URL

  Future<void> registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Upload profile picture and get the download URL
      // For simplicity, let's assume you have a separate method to upload the picture
      // You can replace this with your actual method to upload profile pictures
      String pictureUrl = await uploadProfilePicture(userCredential.user!.uid);

      // Update the profile picture URL in the local variable
      profilePictureUrl = pictureUrl;

      // Save user data to Firestore with the profile picture URL
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullNameController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        'uid': userCredential.user!.uid,
        'profilePictureUrl': profilePictureUrl,
      });

      Get.offAll(() => DashboardScreen());

      // Clear form fields
      fullNameController.clear();
      emailController.clear();
      passwordController.clear();
      reEnterPasswordController.clear();
      phoneNumberController.clear();
    } catch (e) {
      print('Registration failed: $e');
      // Handle registration failure, e.g., show an error message.
    }
  }

  // Replace this method with your actual method to upload profile pictures
  Future<String> uploadProfilePicture(String userId) async {
    // Implement your logic to upload the profile picture and get the download URL
    // For example, you can use Firebase Storage for this purpose
    // Once uploaded, return the download URL
    String downloadUrl = "https://example.com/profile-picture.jpg";
    return downloadUrl;
  }
}
