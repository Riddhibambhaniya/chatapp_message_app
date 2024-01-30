import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../dashbord/dashbord_page.dart';

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

  RxString profilePictureUrl = ''.obs; // Updated to RxString

  Future<void> registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Upload profile picture and get the download URL


      // Save user data to Firestore with the profile picture URL
      await FirebaseFirestore.instance.collection('users').doc(
        userCredential.user!.uid,
      ).set({
        'fullName': fullNameController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        'uid': userCredential.user!.uid,
        'profilePictureUrl': profilePictureUrl.value,
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


}