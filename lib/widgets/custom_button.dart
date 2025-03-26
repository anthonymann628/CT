import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool outlined;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color,
    this.outlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color btnColor = color ?? Theme.of(context).primaryColor;
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                primary: btnColor,
                side: BorderSide(color: btnColor),
              ),
              child: Text(label),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                primary: btnColor,
                onPrimary: Colors.white,
              ),
              child: Text(label),
            ),
    );
  }
}
