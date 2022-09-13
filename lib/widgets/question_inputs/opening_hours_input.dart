import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';


class OpeningHoursInput extends QuestionInputView {
  const OpeningHoursInput(
    QuestionInput questionInput,
    { void Function(Answer?)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _OpeningHoursInputState createState() => _OpeningHoursInputState();
}


class _OpeningHoursInputState extends State<OpeningHoursInput> {
  @override
  Widget build(BuildContext context) {
    return const Text('Dummy');
  }
}
