import 'package:flutter/material.dart';

class ChangeThemeBtnWidget extends StatelessWidget {
  const ChangeThemeBtnWidget({
    Key? key,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    required this.onTap,
  }) : super(key: key);

  final Color backgroundColor;
  final Color iconColor;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: backgroundColor,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Icon(
        Icons.color_lens,
        color: iconColor,
      ),
    );
  }
}
