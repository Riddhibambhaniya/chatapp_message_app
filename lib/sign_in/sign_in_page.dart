import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messageapp/sign_in/sign_in_controller.dart';

import '../chatpage/chatpage_controller.dart';
import '../onboarding/onboarding_page.dart';
import '../sign_up/sign_up_page.dart';
import '../styles/text_style.dart';

class EmailValidator {
  static String? validate(String value) {
    const Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final RegExp regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }
}

class SignInScreen extends StatelessWidget {
  final SignInController controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the onboarding screen
            Get.to(() => OnboardingScreen());
          },
        ),

      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: controller.formKey,

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    SizedBox(height: 30),
                    Text(
                    'Log in to Chatbox',
                    textAlign: TextAlign.center,
                    style: textBolds,
                  ),
                    SizedBox(height: 50),
                    Text(
                      '''Welcome back! Sign in using your social 
account or email to continue us''',
                      textAlign: TextAlign.center,
                      style: textWelcomeBack,
                      maxLines: 2,
                    ),
                    SizedBox(height: 70),
                    TextFormField(
                      controller: controller.emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(10),
                        filled: true,
                        fillColor: Colors.white,
                        errorText: controller.emailError.value
                            ? 'Incorrect email'
                            : null,
                      ),
                      onChanged: (_) =>
                      controller.emailError.value = false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }

                        String? emailValidationResult =
                        EmailValidator.validate(value);

                        return emailValidationResult;
                      },
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(10),
                        filled: true,
                        fillColor: Colors.white,
                        errorText: controller.passwordError.value
                            ? 'Incorrect password'
                            : null,
                      ),
                      onChanged: (_) =>
                      controller.passwordError.value = false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 90),
                  Container(
                    width: 340,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Color(0xFF24786D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (controller.formKey.currentState?.validate() ??
                            false) {
                          controller.signInUser();
                        }
                      },
                      child: Text(' Log In ', style: textBoldss),
                    ),
                  )

                  ],
                ),
              ),

          ),
        ),
      ),
    );
  }
}
