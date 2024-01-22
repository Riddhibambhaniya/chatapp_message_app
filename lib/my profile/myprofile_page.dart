import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'myprofile_controller.dart';

class MyProfileView extends StatelessWidget {
  final MyProfileController controller = Get.put(MyProfileController());
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final userProfilePic = controller.userProfilePic.value;
              return Column(
                children: [
                  CircleAvatar(
                    radius: 60.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: userProfilePic.isNotEmpty
                        ? NetworkImage(userProfilePic)
                        : null,
                    child: userProfilePic.isEmpty
                        ? Text(
                      controller.fullName.value.isNotEmpty
                          ? controller.fullName.value[0].toUpperCase()
                          : '',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                        : null,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Email: ${controller.email.value}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Phone Number: ${controller.phoneNumber.value}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              );
            }),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _pickImage();
              },
              child: Text('Upload Profile Picture'),
            ),

            // Add other profile details and editing fields here
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        // Update the user's profile picture in the controller and Firestore
        controller.userProfilePic.value = pickedFile.path;
        await controller.updateProfilePicture();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }}