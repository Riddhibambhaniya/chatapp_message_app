// group_chat_page.dart
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
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
            child:
            // group_chat_page.dart
            // group_chat_page.dart
            Obx(
                  () => ListView.builder(
                itemCount: controller.groupMessages.length,
                itemBuilder: (context, index) {
                  var message = controller.groupMessages[index];
                  return ListTile(
                    title: Text(message.senderName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        message.imageUrl != null
                            ? Image.network(message.imageUrl!)
                            : Text(message.text!),
                        Text(
                          'Sent by: ${message.senderName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),


          ),
          // Message input field and send button
          Row(
            children: [    IconButton(
              icon: Icon(Icons.emoji_emotions),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return  EmojiPicker(
                      onEmojiSelected: (Category? category, Emoji? emoji) {
                        if (category != null && emoji != null) {
                          controller.messageController.text += emoji.emoji;
                        }
                      },
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 *
                            (foundation.defaultTargetPlatform ==
                                TargetPlatform.iOS
                                ? 1.30
                                : 1.0),
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                        initCategory: Category.RECENT,
                        bgColor: const Color(0xFFF2F2F2),
                        indicatorColor: Colors.blue,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.blue,
                        backspaceColor: Colors.blue,
                        skinToneDialogBgColor: Colors.white,
                        skinToneIndicatorColor: Colors.grey,
                        enableSkinTones: true,
                        recentTabBehavior: RecentTabBehavior.RECENT,
                        recentsLimit: 28,
                        replaceEmojiOnLimitExceed: false,
                        noRecents: const Text(
                          'No Recents',
                          style: TextStyle(
                              fontSize: 20, color: Colors.black26),
                          textAlign: TextAlign.center,
                        ),
                        loadingIndicator: const SizedBox.shrink(),
                        tabIndicatorAnimDuration: kTabScrollDuration,
                        categoryIcons: const CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL,
                        checkPlatformCompatibility: true,
                      ),
                    );
                  },
                );
              },
            ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(width: 0.0, color: Colors.grey),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: controller.messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                ),
              ),

              IconButton(
                icon: Icon(Icons.image),
                onPressed: () async {
                  final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    File imageFile = File(pickedFile.path);
                    controller.uploadImage(imageFile);
                  }
                },
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
