import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';


class StringInput extends QuestionInputView {
  const StringInput(
    QuestionInput questionInput,
    { void Function(Answer?)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _StringInputState createState() => _StringInputState();
}

class _StringInputState extends State<StringInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minValue = widget.questionInput.min ?? 0;
    final maxValue = widget.questionInput.max;

    return ValueListenableBuilder(
        valueListenable: _controller,
        builder: (context, TextEditingValue text, __) {
          return TextFormField(
            onChanged: _handleChange,
            controller: _controller,
            maxLength: maxValue,
            decoration: InputDecoration(
              hintText: 'Hier eintragen...',
              counter: const Offstage(),
              suffixIcon: IconButton(
                onPressed: _handleClear,
                color: Colors.black87,
                icon: const Icon(Icons.clear_rounded),
              )
            ),
            autovalidateMode: AutovalidateMode.always,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return null;
              }
              if (text.length < minValue ){
                return 'Eingabe zu kurz';
              }
            },
          );
        }
    );
  }


  void _handleClear() {
    _controller.clear();
    _handleChange();
  }


  void _handleChange([String value = '']) {
    final answer = value.isNotEmpty
      ? StringAnswer(
        questionValues: widget.questionInput.values,
        answer: value
      )
      : null;

    widget.onChange?.call(answer);
  }
}
