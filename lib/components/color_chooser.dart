import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:photo_collage_creator/components/background_image_selector.dart';
import 'package:photo_collage_creator/components/my_home_page.dart';
import 'package:photo_collage_creator/components/preset_colors.dart';
import 'package:photo_collage_creator/main.dart';
import "utils.dart";

class ColorChooser extends StatefulWidget {

  @override
  State<ColorChooser> createState() => ColorChooserState();
}

class ColorChooserState extends State<ColorChooser> {
  // Default color of our color picker
  Color? color = Colors.white;
  // Inform parent of a newly selected color
  void updateColor(Color? color) {
    setState(() {
      this.color = color;
    });
  }

  // Color chooser state variable if color is selected from
  // the color chooser, use to cause selected color to be shown
  var isSelected = false;

  @override
  Widget build(BuildContext context) {
    var backgroundImageSelector =
        context.findRootAncestorStateOfType<BackgroundImageSelectorState>();
    
    // TODO: implement build
    return Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Color.fromRGBO(37, 37, 50, 0.9),
            borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text("choose solid color",
                  style: TextStyle(color: Color.fromRGBO(230, 230, 230, 1))),
          SizedBox(height: 8),
          Row(children: [
            // List Of Predefined Colors Represented as Rectangular widgets
            PresetColors(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("select color",
                    style: TextStyle(
                        color: Color.fromRGBO(200, 200, 200, 1), fontSize: 12)),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          if (!isSelected) {
                            setState(() {
                              isSelected = true;
                            });
                          }

                          showDialog(
                            builder: (context) {
                              return AlertDialog(
                                  title: const Text("Color Chooser"),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                        pickerColor: color as Color,
                                        onColorChanged: (color) {
                                          this.color = color;
                                        }),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll<Color>(
                                                  Color.fromRGBO(
                                                      0, 100, 250, 1))),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        // Inform parent new color selection
                                        backgroundImageSelector
                                            ?.setBackgroundColor(color);
                                      },
                                      child: Text("Set Color",
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  250, 250, 250, 1))),
                                    )
                                  ]);
                            },
                            context: context,
                          );
                        },
                        // Rectangular icon of our color picker
                        icon: Icon(Icons.rectangle_sharp,
                            color: color, size: 64)),
                    // Draw a checkmark on color picker if it tapped
                    if (isSelected)
                      Icon(Icons.check, size: 16, color: Colors.white),
                  ],
                ),
              ],
            )
          ])
        ]));
  }
}
