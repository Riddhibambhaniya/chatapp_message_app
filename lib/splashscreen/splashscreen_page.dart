import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messageapp/splashscreen/splashscreen_controller.dart';



class SplashView extends GetView<SplashController> {
  final SplashController controller = Get.put(SplashController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo -uihut (6).jpg',
              fit: BoxFit.fill,
              height: 200,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
