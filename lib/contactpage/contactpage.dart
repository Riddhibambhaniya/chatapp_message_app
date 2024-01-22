import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../styles/text_style.dart';
import 'contactpage_controller.dart';

class ContactPage extends StatelessWidget {
  final ContactController controller = Get.put(ContactController());

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
              child: Text('Contacts', style: TextStyle(color: Colors.white)),
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
                children: [ GestureDetector(
                  onTap: () => controller.createNewGroup(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'New group',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      children: [
                        Text(
                          'My Contacts',
                          style: appbar2, // You need to define appbar2 style
                        ),


                      ],
                    ),

                  Expanded(
                    child: Obx(() {
                      controller.update(); // Add this line to update the UI
                      return ListView(
                        children: controller.contactCards,
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
