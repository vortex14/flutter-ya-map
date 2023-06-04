import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatefulWidget {
  const CustomTextFieldWidget({
    Key? key,
    required this.controller,
    required this.onSearchTextChanged,
    required this.onCleanTextField,
  }) : super(key: key);

  final TextEditingController controller;
  final Function() onSearchTextChanged;
  final Function() onCleanTextField;

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            offset: const Offset(0, 1),
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
      child: TextFieldRow(
        controller: widget.controller,
        onSearchTextChanged: widget.onSearchTextChanged,
        onCleanTextField: widget.onCleanTextField,
      ),
    );
  }
}

class TextFieldRow extends StatefulWidget {
  const TextFieldRow({
    Key? key,
    required this.controller,
    required this.onSearchTextChanged,
    required this.onCleanTextField,
  }) : super(key: key);
  final TextEditingController controller;
  final Function() onSearchTextChanged;
  final Function() onCleanTextField;

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
            onChanged: (value) {
              widget.onSearchTextChanged();
              if (value.isEmpty) widget.onCleanTextField();
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
