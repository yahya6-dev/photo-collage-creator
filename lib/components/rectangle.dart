import 'package:flutter/material.dart';
import "background_image_selector.dart";
import 'preset_colors.dart';
import "color_chooser.dart";
import "utils.dart";
import "my_home_page.dart";

class Rectangle extends StatefulWidget {
  // Color of our rectangle
  final Color color;
  // Determine if this rectangle is selected or not
  bool isSelected;

  Rectangle({required this.color, required this.isSelected});

  @override
  State<Rectangle> createState() => _RectangleState();
}

class _RectangleState extends State<Rectangle> {
  @override
  Widget build(BuildContext context) {
    // Get Reference to ColorChooserState and BackgroundImageSelectorState
    var colorChooserState =
        context.findAncestorStateOfType<ColorChooserState>();
    var backgroundSelector =
        context.findRootAncestorStateOfType<BackgroundImageSelectorState>();
    var parentWidget = context.findRootAncestorStateOfType<MyHomePageState>();

    return GestureDetector(
        child: Container(
            height: 80,
            width: 50,
            color: widget.color,
            child: Card(
                margin: EdgeInsets.all(8),
                // If this widget is selected show widget.color else draw it with an overlay of white color
                color: widget.isSelected
                    ? widget.color
                    : Color.fromRGBO(250, 250, 250, 0.3),

                child: Row(children: [
                  Text(""),
                  // Draw a check mark if this widget is selected
                  if (widget.isSelected)
                    Center(
                        child: Icon(Icons.check, size: 32, color: Colors.white))
                ]))),
        onTap: () async {
          if (widget.isSelected) {
            // If this widget is already selected inform parent to reset to default color
            setState(() {
              //widget.isSelected = false;
              backgroundSelector?.setBackgroundColor(null);
              colorChooserState?.updateColor(Colors.white);
            });
          }
          // Image not selected informed parent
          if (!widget.isSelected) {
            backgroundSelector?.setBackgroundColor(widget.color as Color?);
            // Update our selected color as this rectangle color
            colorChooserState?.updateColor(widget.color);
          }
        });
  }
}
