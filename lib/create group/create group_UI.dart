import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messageapp/styles/text_style.dart';

import 'create group_controller.dart';

class CreateGroupPage extends StatelessWidget {
  final List<String> selectedContacts;

  CreateGroupPage({required this.selectedContacts});

  final CreateGroupController controller = Get.put(CreateGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body:SingleChildScrollView(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left:22.0),
              child: Text('Group Description',style: appbar1,),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left:22.0),
              child: Text('''Make Group 
for Team Work''',style:TextStyle(
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:22.0,right:22),
              child: TextField(
                controller: controller.groupNameController,
                decoration: InputDecoration(labelText: 'Group Name'),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left:22.0,right:22),
              child: Obx(
                    () => Column(
                  children: controller.contacts.map((contact) {
                    return ListTile(
                      title: Text(contact['fullName']),
                      trailing: Checkbox(
                        value: controller.selectedContacts.contains(contact['userId']),
                        onChanged: (bool? value) {
                          controller.toggleContactSelection(contact['userId']);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 40.0),
            Padding(
              padding: const EdgeInsets.only(left:22.0,right:22.0),
              child: ElevatedButton(
                onPressed: () {
                  controller.createGroup();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey;
                      }
                      return Color(0xFF24786D);
                    },
                  ),
                ),
                child: Text('Create Group',style:TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
              ),
            ),
          ],
        ),
      )
    );
  }
}
