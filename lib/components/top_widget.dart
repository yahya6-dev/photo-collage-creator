import 'package:flutter/material.dart';

class TopWidget extends StatefulWidget {
  // Widget representing Entry point of our application
  // in the first screen
  const TopWidget({required this.onPressed});
  // This function onPressed move us to the next screen for selecting grid type and background Filling
  final void Function() onPressed;

  @override
  State<TopWidget> createState() => _TopWidgetState();
}

class _TopWidgetState extends State<TopWidget> {
  // Grid icon used in the create grid button
  final gridIcon = Icons.add;

  @override
  Widget build(BuildContext context) {
    return Container(
     child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                      Color.fromRGBO(0, 100, 250, 0.9)),
                ),
                // Move to next screen if pressed
                onPressed: widget.onPressed,
                label: Text("Create",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                icon: Icon(gridIcon, color: Color.fromRGBO(200, 200, 200, 1))),
                      ]),
    );
  }
}
