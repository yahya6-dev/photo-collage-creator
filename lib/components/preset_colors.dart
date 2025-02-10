import 'package:flutter/material.dart';
import 'package:photo_collage_creator/components/color_chooser.dart';
import 'package:photo_collage_creator/components/rectangle.dart';

class PresetColors extends StatefulWidget {
  // This widget contain some predefine colors that
  // a user can select.
  PresetColors({super.key});

  @override
  State<PresetColors> createState() => _PresetColorsState();
}

class _PresetColorsState extends State<PresetColors> {
  @override
  Widget build(BuildContext context) {
    // Get reference to ColorChooserState to know if one of the rectangle color match selected color,
    // so as to mark it as selected or not
    var parentWidget = context.findAncestorStateOfType<ColorChooserState>();
    
    return Row(
      children: [
        Rectangle(
            color: Colors.blue, isSelected: parentWidget?.color == Colors.blue),
        SizedBox(width: 8.0),
        Rectangle(
            color: Colors.red, isSelected: parentWidget?.color == Colors.red),
        SizedBox(width: 8.0),
        Rectangle(
            color: Colors.green,
            isSelected: parentWidget?.color == Colors.green),
        SizedBox(width: 8.0),
      ],
    );
  }
}
