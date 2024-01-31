import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../styles/text_style.dart';
import 'myprofile_controller.dart';
import 'myprofile_page.dart';

class EditProfileView extends StatelessWidget {
  final MyProfileController controller = Get.find<MyProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 62.0,
              backgroundColor: Colors.white,
              child: GestureDetector(
                onTap: () async {
                  await controller.updateProfilePicture();
                },
                child: ClipOval(
                  child: SizedBox(
                    width: 120.0,
                    height: 120.0,
                    child: YourImageWidget(controller: controller),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Text('Display Name', style: appbar1),
            SizedBox(height: 10),
            TextFormField(
              controller: TextEditingController(text: controller.userName.value),
              onChanged: (value) {
                controller.userName.value = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter your new display name',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                controller.updateProfileDetails(
                  newDisplayName: controller.userName.value,
                  newEmail: controller.userEmail.value,
                  newPhoneNumber: controller.userPhoneNumber.value,
                );
                Get.back();
              },
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
