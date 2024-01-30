import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../groupchat_controller.dart';
import 'create_poll_controller.dart';

class PollWidget extends StatelessWidget {
  final PollModel poll;

  PollWidget(this.poll);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(poll.question, style: TextStyle(fontWeight: FontWeight.bold)),
        for (int i = 0; i < poll.choices.length; i++)
          Obx(() => RadioListTile<String>(
            title: Text(poll.choices[i]),
            value: poll.choices[i],
            groupValue: Get.find<GroupChatController>().selectedChoices[poll.question] ?? '',
            onChanged: (value) {
              Get.find<GroupChatController>().selectedChoices[poll.question] = value!;
            },
          )),
        ElevatedButton(
          onPressed: () {
            Get.find<GroupChatController>().submitPollResponse(poll);
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
