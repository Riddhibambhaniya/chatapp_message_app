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

  Future<void> registerUser() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
        // phoneNumber: phoneNumberController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': fullNameController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        'uid': userCredential.user!.uid,

      });

      Get.offAll(() => DashboardScreen());

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