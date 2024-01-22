import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            SizedBox(height: 16.0),
            Obx(
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
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                controller.createGroup();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey;
                    }
                    return Colors.blue;
                  },
                ),
              ),
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
