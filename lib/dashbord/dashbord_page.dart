import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messageapp/contactpage/contactpage.dart';
import 'package:messageapp/messagepage/message_page.dart';



import 'dashbord_controller.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
            () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            MessagePage(),
            ContactPage(),

          ],
        ),
      ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Message',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_phone),
              label: 'Contact',
            ),

          ],
        ),
      ),
    );
  }
}
