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
            Center(
              child: CircleAvatar(
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
            ),
            SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.only(left:8.0),
              child: Text('Display Name', style: appbar1),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left:8.0,right:8.0),
              child: TextFormField(
                controller: TextEditingController(text: controller.userName.value),
                onChanged: (value) {
                  controller.userName.value = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your new display name',
                ),
              ),
            ),
            SizedBox(height:70),
      Center(
        child: ElevatedButton(
          onPressed: () {
            controller.updateProfileDetails(
              newDisplayName: controller.userName.value,
              newEmail: controller.userEmail.value,
              newPhoneNumber: controller.userPhoneNumber.value,
            );
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black, // Background color
            onPrimary: Colors.white, // Text color
          ),
          child: Text('Confirm'),
        ),
      ),


          ],
        ),
      ),
    );
  }
}
