// MessagePage.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../auth.controller.dart';
import '../chatpage/chatpage.dart';
import '../groupchat/groupchat_UI.dart';
import '../my profile/myprofile_controller.dart';
import '../my profile/myprofile_page.dart';
import 'messagepage_controller.dart';
import 'search_screen.dart';

class MessagePage extends StatelessWidget {
  final MessageController controller = Get.put(MessageController());
  final MyProfileController myProfileController = Get.put(MyProfileController());
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('en', timeago.EnMessages());

    return Scaffold(
      backgroundColor: Colors.black,
      body:
      Stack(
        children: [
          AppBar(
            backgroundColor: Colors.black,
         leading :   Padding(
           padding: const EdgeInsets.only(left:17.0),
           child: IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // Open search screen when search icon is clicked
                  Get.to(() => SearchScreen());
                },
              ),
         ),
            title:  Padding(
                padding: const EdgeInsets.only(left: 70.0),
                child: Text('Chats', style: TextStyle(color: Colors.white)),
              ),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 28.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.person, size: 30, color: Colors.white),
                    onPressed: () async {
                      await myProfileController.loadUserData();
                      Get.to(() => MyProfileView());
                    },
                  ),
                ),
              ),
              // New IconButton for search

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
              child: Obx(
                    () => (controller.personalChats.isEmpty && controller.groupChats.isEmpty)
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: controller.personalChats.length + controller.groupChats.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(index.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        if (index < controller.personalChats.length) {
                          var userId = controller.personalChats[index].userId;
                          controller.removePersonalChat(userId);
                        } else {
                          var groupChatIndex = index - controller.personalChats.length;
                          var groupId = controller.groupChats[groupChatIndex].groupId;
                          controller.removeGroupChat(groupId);
                        }
                        // Remove the dismissed item from the list
                        controller.personalChats.refresh();
                        controller.groupChats.refresh();
                      },
                      child: buildChatCard(context, index),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChatCard(BuildContext context, int index) {
    if (index < controller.personalChats.length) {
      // Personal chat card
      var personalChat = controller.personalChats[index];
      return GestureDetector(
        onTap: () {
          Get.to(() => ChatPage(
            currentUser: controller.currentUser.value!,
            selectedUserId: personalChat.userId,
          ),
              arguments: {
                'selectedUserId': personalChat.userId,
                'currentUser': controller.currentUser,
              });
        },
        child: Card(
          color: Colors.white,
          child: ListTile(
            // Your personal chat card content
            leading: FutureBuilder<String?>(
              future: myProfileController.getUserProfilePictureUrl(userId: personalChat.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  String? profilePictureUrl = snapshot.data;
                  return CircleAvatar(
                    backgroundImage: profilePictureUrl != null ? NetworkImage(profilePictureUrl) : null,
                  );
                } else {
                  return CircleAvatar();
                }
              },
            ),
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
      );
    } else {
      // Group chat card
      var groupChatIndex = index - controller.personalChats.length;
      var groupChat = controller.groupChats[groupChatIndex];
      return GestureDetector(
        onTap: () async {
          await controller.fetchGroupMessagesForChats();
          Get.to(() => GroupChatPage(groupId: groupChat.groupId, groupName: groupChat.groupName));
        },
        child: Card(
          color: Colors.white,
          child: ListTile(
            // Your group chat card content
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
      );
    }
  }
}
