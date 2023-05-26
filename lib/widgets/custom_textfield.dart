import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatefulWidget {
  const CustomTextFieldWidget({super.key, required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final Function() onSubmitted;

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: TextFieldRow(controller: widget.controller, onSubmitted: widget.onSubmitted),
    );
  }
}

class TextFieldRow extends StatefulWidget {
  const TextFieldRow({super.key, required this.controller, required this.onSubmitted});
  final TextEditingController controller;
  final Function() onSubmitted;

  @override
  State<TextFieldRow> createState() => _TextFieldRowState();
}

class _TextFieldRowState extends State<TextFieldRow> {
  bool textFieldEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        textFieldEmpty
            ? Container(
                margin: const EdgeInsets.all(4.0),
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 3, color: Colors.grey.withOpacity(0.6)),
                ),
              )
            : const SizedBox(
                width: 24.0,
                height: 24.0,
                child: Icon(
                  Icons.search,
                  size: 24.0,
                ),
              ),
        const SizedBox(width: 8.0),
        Expanded(
          child: TextField(
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.onSubmitted();
                setState(() {
                  textFieldEmpty = false;
                });
              } else {
                setState(() {
                  textFieldEmpty = true;
                });
              }
            },
            controller: widget.controller,
            style: const TextStyle(fontSize: 16.0),
            decoration: const InputDecoration(
              hintText: 'Введите адрес',
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ),
        if (!textFieldEmpty)
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    textFieldEmpty = true;
                  });
                  widget.controller.clear();
                },
                child: const Icon(Icons.close),
              ),
            ],
          )
      ],
    );
  }
}
