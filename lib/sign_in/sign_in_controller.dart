import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../dashbord/dashbord_page.dart';


class SignInController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool emailError = false.obs;
  RxBool passwordError = false.obs;

  final formKey = GlobalKey<FormState>();

  Future<void> signInUser() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Get.off(() => DashboardScreen());
      // Handle successful login, e.g., navigate to home screen
      Get.snackbar('Success', 'User signed in successfully');

      // Clear the text controllers
      emailController.clear();
      passwordController.clear();
    } catch (e) {
      print('Sign-in failed: $e');
      // Handle sign-in failure, e.g., show an error message.
      Get.snackbar('Error', 'Sign-in failed. Check your credentials.');
    }
  }
}