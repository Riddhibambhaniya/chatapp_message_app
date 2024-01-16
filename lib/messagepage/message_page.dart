import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'messagepage_controller.dart';

class MessagePage extends StatelessWidget {
  final MessageController controller = Get.put(MessageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Obx(
            () => controller.messageCards.isEmpty
            ? Center(
          child: CircularProgressIndicator(),
        )
            : ListView(
          children: controller.messageCards,
        ),
      ),
    );
  }
}

