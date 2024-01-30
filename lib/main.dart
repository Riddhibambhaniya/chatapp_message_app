import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'auth.controller.dart';
import 'splashscreen/splashscreen_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAJRsSnrvO9nb_prnLDFdZxNhortRjvgwU',
        appId: 'com.example.messageapp',
        messagingSenderId:'915469156468',
        projectId:'messageapp-81998',
        storageBucket:'gs://messageapp-81998.appspot.com',
      ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Chat App',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
      ),
      home: SplashView(),
    );
  }
}
