import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chatpage_controller.dart';

class ChatPage extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());
  final User currentUser;
  final String selectedUserId;

  ChatPage({
    required this.currentUser,
    required this.selectedUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with User'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.fetchMessages(); // Refresh messages
              },
              child: FutureBuilder(
                future: controller.fetchMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a circular progress indicator while loading
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    // Handle errors
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    // Data has been successfully fetched
                    return Obx(
                          () => ListView(
                        reverse: true,
                        children: controller.messageWidgets,
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
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
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
