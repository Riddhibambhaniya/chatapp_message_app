// SearchScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chatpage/chatpage.dart';
import '../groupchat/groupchat_UI.dart';
import 'messagepage_controller.dart';

class SearchScreen extends StatelessWidget {
  final MessageController controller = Get.find<MessageController>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                controller.filterChats(value);
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.filteredPersonalChats.isEmpty && controller.filteredGroupChats.isEmpty) {
                  return Center(child: Text('No results'));
                }

                return ListView.builder(
                  itemCount: controller.filteredPersonalChats.length + controller.filteredGroupChats.length,
                  itemBuilder: (context, index) {
                    return buildChatCard(context, index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChatCard(BuildContext context, int index) {
    if (index < controller.filteredPersonalChats.length) {
      var personalChat = controller.filteredPersonalChats[index];
      return GestureDetector(
        onTap: () {
          // Handle the tap for personal chat
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
            leading: CircleAvatar(
              // Load profile picture here using personalChat.userId
              backgroundImage: NetworkImage('profile_picture_url'), // Replace with the actual URL
            ),
            title: Text(
              personalChat.fullName,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ),
      );
    } else {
      var groupChatIndex = index - controller.filteredPersonalChats.length;
      var groupChat = controller.filteredGroupChats[groupChatIndex];
      return GestureDetector(
        onTap: () {
          // Handle the tap for group chat
          Get.to(() => GroupChatPage(groupId: groupChat.groupId, groupName: groupChat.groupName));
        },
        child: Card(
          color: Colors.white,
          child: ListTile(
            title: Text(
              groupChat.groupName,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ),
      );
    }
  }
}
