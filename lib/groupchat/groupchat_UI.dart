// group_chat_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'groupchat_controller.dart';

class GroupChatPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  GroupChatPage({required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    print('GroupChatPage - groupId: $groupId, groupName: $groupName');
    // Create an instance of the controller and assign the values immediately
    final GroupChatController controller = Get.put(GroupChatController());
    controller.groupId.value = groupId;
    controller.groupName.value = groupName;

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
                  () => ListView.builder(
                itemCount: controller.groupMessages.length,
                itemBuilder: (context, index) {
                  var message = controller.groupMessages[index];
                  // Display group messages
                  return ListTile(
                    title: Text(message.senderName),
                    subtitle: Text(message.text),
                  );
                },
              ),
            ),
          ),
          // Message input field and send button
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  controller.sendMessage();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
