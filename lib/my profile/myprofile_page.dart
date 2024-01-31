import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../styles/text_style.dart';
import '../dashbord/dashbord_page.dart';
import '../styles/color.dart';
import 'edit profile view.dart';
import 'myprofile_controller.dart';
class MyProfileView extends GetView<MyProfileController> {
  final MyProfileController controller = Get.put(MyProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 278.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Get.to(() => DashboardScreen());
                  },
                ),
              ),
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
              SizedBox(
                height: 15,
              ),
              Obx(() => Text(
                controller.userName.value,
                style: appbar,
              )),
              SizedBox(
                height: 50,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                  color: Colors.white,
                ),
                width: 400,
                height: 1000,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0),
                      child: Text(
                        "Display Name",
                        style: appbar1,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0),
                      child: Text(
                        controller.userName.value,
                        style: appbar2,
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0),
                      child: Text(
                        "Email Address",
                        style: appbar1,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0),
                      child: Text(
                        controller.userEmail.value ?? '',
                        style: appbar2,
                      ),
                    ),
                    SizedBox(
                      height: 70,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => EditProfileView());
                        },
                        child: Text("Edit Profile"),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Log Out",
                            titleStyle: textBolds,
                            middleText: "Are you sure you want to log out?",
                            middleTextStyle: appbar2,
                            textConfirm: "Yes",
                            textCancel: "No",
                            onConfirm: () {
                              controller.logOut();
                            },
                            onCancel: () {
                              Get.back();
                            },
                          );
                        },
                        child: Text("Log Out"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YourImageWidget extends StatelessWidget {
  final MyProfileController controller;

  YourImageWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () {
        if (controller.userProfilePic.isNotEmpty) {
          if (controller.userProfilePic.value.startsWith('http')) {
            return Image.network(
              controller.userProfilePic.value,
              fit: BoxFit.cover,
            );
          } else {
            return Image.file(
              File(controller.userProfilePic.value),
              fit: BoxFit.cover,
            );
          }
        } else {
          return Text(
            (controller.userName.isNotEmpty)
                ? controller.userName.value[0].toUpperCase()
                : '',
            style: TextStyle(
              fontSize: 35.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        }
      },
    );
  }
}