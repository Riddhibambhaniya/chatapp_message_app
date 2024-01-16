import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'contactpage_controller.dart';

class ContactPage extends StatelessWidget {
  final ContactController controller = Get.put(ContactController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Obx(() {
        controller.update(); // Add this line to update the UI
        return ListView(
          children: controller.contactCards,
        );
      }),
    );
  }
}
