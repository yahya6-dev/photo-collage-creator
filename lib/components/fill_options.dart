import "package:flutter/material.dart";
import "option_item.dart";
import "my_home_page.dart";
import "dart:ui" as ui;

class FillOptions extends StatefulWidget {
  FillOptions({required this.cancel,required this.setColor, //required this.setImage
    });
  @override
  State<FillOptions> createState() => FillOptionsState();
  // Dismiss this widget
  void Function() cancel;
  // Set color filling of our selected ceil
  void Function(Color color) setColor;
}

class FillOptionsState extends State<FillOptions> {
  // Current option menu tapped
  var selectedTool = "";
  // Notify parent of the selected tool
  void setSelectedTool(String selection) {
    setState(() {
      selectedTool = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BackButton(
              color: Color.fromRGBO(200, 200, 200, 1),
              onPressed: () {
                widget.cancel();
              }),
          Text("Fill Ceil Option",
              style: TextStyle(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  fontSize: 12,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w100)),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        OptionItem(
            label: "Image",
            icon: Icon(Icons.image, color: Color.fromRGBO(200, 200, 200, 1)),
            onOptionSelected: setSelectedTool),
        OptionItem(
            label: "Color",
            icon:
                Icon(Icons.rectangle, color: Color.fromRGBO(230, 230, 230, 1)),
            onOptionSelected: setSelectedTool),
      ]),
    ]);
  }
}
