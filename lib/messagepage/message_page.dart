import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'messagepage_controller.dart';

class MessagePage extends StatelessWidget {
  final MessageController controller = Get.put(MessageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
        AppBar(
        backgroundColor: Colors.black,
        title: Padding(
          padding: const EdgeInsets.only(left: 78.0),
          child: Text('HOME', style: TextStyle(color: Colors.white)),
        ),
      ),
      Positioned(
        top: 120.0,
        left: 0,
        right: 0,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              color: Colors.white,
            ),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Expanded(
                child:   Obx(
            () => controller.messageCards.isEmpty
            ? Center(
          child: CircularProgressIndicator(),
        )
            : ListView(
          children: controller.messageCards,
        ),
      ),
                ) ] )) )]) );
  }
}

