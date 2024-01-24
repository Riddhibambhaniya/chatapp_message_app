import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../auth.controller.dart';
import '../chatpage/chatpage.dart';
import '../groupchat/groupchat_UI.dart';
import '../my profile/myprofile_controller.dart';
import '../my profile/myprofile_page.dart';
import 'messagepage_controller.dart';

class MessagePage extends StatelessWidget {
  final MessageController controller = Get.put(MessageController());
  final MyProfileController myProfileController = Get.put(MyProfileController());
  final AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('en', timeago.EnMessages());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AppBar(
            backgroundColor: Colors.black,
            title: Center(
              child: Text('Chats', style: TextStyle(color: Colors.white)),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Get.to(() => MyProfileView());
                },
                child: Obx(() {
                  final userController = Get.find<MyProfileController>();
                  final userProfilePic =
                      userController.userProfilePic.value;
                  final userName = userController.userName.value;

                  return CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.blue,
                    backgroundImage: userProfilePic.isNotEmpty
                        ? AssetImage(userProfilePic)
                        : null,
                    child: userProfilePic.isEmpty
                        ? Text(
                      userName.isNotEmpty
                          ? userName[0].toUpperCase()
                          : '',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                        : null,
                  );
                }),
              ),
            ],
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
                    child: Obx(() =>
                    (controller.personalChats.isEmpty && controller.groupChats.isEmpty)
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : ListView.builder(
                      itemCount: controller.personalChats.length + controller.groupChats.length,
                      itemBuilder: (context, index) {
                        if (index < controller.personalChats.length) {
                          // Display personal chat
                          var personalChat = controller.personalChats[index];


                          return GestureDetector(
                              child: Card(
                                color: Colors.white,
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 18.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${personalChat?.fullName ?? "No Name"}',
                                              style: TextStyle(fontSize: 14.0),
                                            ),

                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        timeago.format(
                                          personalChat.latestMessageTimestamp!.toDate(),
                                          locale: 'en',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                // Handle tap for personal chat
                                Get.to(() => ChatPage(
                                  currentUser: controller.currentUser.value!,
                                  selectedUserId: personalChat.userId,
                                ),
                                    arguments: {
                                      'selectedUserId': personalChat.userId,
                                      'currentUser': controller.currentUser,
                                    });
                              },
                            );
                          } else {
                            // Display group chat
                            var groupChatIndex = index - controller.personalChats.length;
                            var groupChat = controller.groupChats[groupChatIndex];
                            return GestureDetector(
                              child: Card(
                                color: Colors.white,
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 18.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${groupChat?.groupName ?? "No Group Name"}',
                                              style: TextStyle(fontSize: 14.0),
                                            ),

                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        timeago.format(
                                          groupChat.latestMessageTimestamp!.toDate(),
                                          locale: 'en',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () async {
                                // Handle tap for group chat
                                await controller.fetchGroupMessagesForChats();
                                // In MessagePage where you navigate to GroupChatPage
                                Get.to(() => GroupChatPage(
                                    groupId: groupChat.groupId, groupName: groupChat.groupName));
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}