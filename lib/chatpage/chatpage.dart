import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:messageapp/styles/text_style.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'chatpage_controller.dart';

class ChatPage extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());
  final User currentUser;
  final String selectedUserId;

  ChatPage({
    required this.currentUser,
    required this.selectedUserId,
  });

  String _formatDateTime(DateTime dateTime) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          String fullName = controller.selectedUserFullName.isNotEmpty
              ? controller.selectedUserFullName
              : 'User';
          return Text(
            ' $fullName',
            // Assuming appbar2 is defined somewhere in your styles
            style: appbar2,
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.fetchMessages();
              },
              child: FutureBuilder(
                future: controller.fetchMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return Obx(
                          () => ListView.builder(
                        reverse: true,
                        itemCount: controller.messageWidgets.length,
                        itemBuilder: (context, index) {
                          ChatMessage message =
                          controller.messageWidgets[index];

                          return Align(
                            alignment: message.isCurrentUserMessage
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: message.isCurrentUserMessage
                                    ? Colors.blue
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      color: message.isCurrentUserMessage
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    '${_formatDateTime(message.timestamp)}',
                                    style: TextStyle(
                                      color: message.isCurrentUserMessage
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return EmojiPicker(
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
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    controller.sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}