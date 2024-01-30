// create_poll_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../groupchat_controller.dart';

class CreatePollController extends GetxController {
  final RxString question = ''.obs;
  final RxList<String> choices = <String>[].obs;
  final RxString pollId = ''.obs; // Add pollId to track the created poll

  void addChoice(String choice) {
    choices.add(choice);
  }

  void removeChoice(int index) {
    choices.removeAt(index);
  }

  bool validatePoll() {
    return question.isNotEmpty && choices.length >= 2;
  }

  void submitPoll() {
    if (validatePoll()) {
      // Create a PollModel object
      PollModel poll = PollModel(question: question.value, choices: choices.toList());

      // Send the poll to the group chat
      Get.find<GroupChatController>().sendPoll(poll);

      // Assign a unique id to the poll
      pollId.value = UniqueKey().toString();

      // Clear the question and choices for the next poll
      question.value = '';
      choices.clear();
    } else {
      // Handle invalid poll (e.g., show an error message)
      print('Invalid Poll. Please provide a question and at least two choices.');
    }
  }
}

class PollModel {
  late String question;
  late List<String> choices;

  PollModel({required this.question, required this.choices});

  factory PollModel.fromMap(Map<String, dynamic> map) {
    return PollModel(
      question: map['question'] ?? '',
      choices: List<String>.from(map['choices'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'choices': choices,
    };
  }
}
