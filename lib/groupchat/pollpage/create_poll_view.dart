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
                           // onChanged: (value) => controller.choices[i] = value,
                           // textDirection: TextDirection.rtl,
                            decoration: InputDecoration(labelText: 'Choice ${i + 1}'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => controller.removeChoice(i),
                        ),
                      ],
                    ),
                  if (controller.showNewChoice.value) // Display "New Choice" only when the flag is true
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) => controller.addChoice(value),
                            decoration: InputDecoration(labelText: 'New Choice'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => controller.showNewChoice.value = false,
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.toggleNewChoice(),
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
