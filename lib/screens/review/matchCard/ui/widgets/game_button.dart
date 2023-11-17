import 'package:flutter/material.dart';

class GameButton extends StatelessWidget {
  const GameButton({
    required this.title,
    required this.onPressed,
    required this.color,
    this.width = double.infinity,
    this.fontSize = 16,
    Key? key,
  }) : super(key: key);

  final String title;
  final VoidCallback onPressed;
  final Color color;

  final double width;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            fixedSize: const Size(300, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
        child: Text(
          title,
        ),
      ),
    );
  }
}
