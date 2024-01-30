// create_poll_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_poll_controller.dart';

class CreatePollPage extends StatelessWidget {
  final CreatePollController controller = Get.put(CreatePollController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Poll'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: controller.question.value),
              onChanged: (value) => controller.question.value = value,
              decoration: InputDecoration(labelText: 'Poll Question'),
            ),
            SizedBox(height: 16),
            Text('Choices:'),
            Obx(
                  () => Column(
                children: [
                  for (int i = 0; i < controller.choices.length; i++)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: controller.choices[i]),
                            onChanged: (value) => controller.choices[i] = value,
                            decoration: InputDecoration(labelText: 'Choice ${i + 1}'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => controller.removeChoice(i),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.addChoice('New Choice'),
                    child: Text('Add Choice'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.submitPoll(),
              child: Text('Submit Poll'),
            ),
          ],
        ),
      ),
    );
  }
}
