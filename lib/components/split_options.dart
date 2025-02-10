import "package:flutter/material.dart";
import "option_item.dart";
import "my_home_page.dart";
import "dart:ui" as ui;
import "ceil_options.dart";

class SplitOptions extends StatefulWidget {
  SplitOptions({required this.cancel, required this.setSelectedTool,
   required this.splitHorizontal, required this.splitVertical});

  @override
  State<SplitOptions> createState() => SplitOptionsState();
  // Function to dismiss this widget
  void Function() cancel;
  // Used to move to the previous menu
  void Function(String selected) setSelectedTool;
  // Function to call to split selected ceil horizontally
  void Function() splitHorizontal;
  // Function to call to split selected ceil vertically
  void Function() splitVertical;
}

class SplitOptionsState extends State<SplitOptions> {
  // Selected option item
  var selectedTool = "";
  
  // Used to by OptionItem to determine which option menu is selected
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
                // Move to the edit menu 
                widget.setSelectedTool("Edit");
              }),
          Text("Split Ceil Options",
              style: TextStyle(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  fontSize: 12,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w100)),
        ],
      ),
      // UI for for split option menu
      Row(children: [
        OptionItem(
            label: "Split Vertical",
            icon: Icon(Icons.vertical_split,
                color: Color.fromRGBO(200, 200, 200, 1)),
            onOptionSelected: setSelectedTool),
        OptionItem(
            label: "Split Horizontal",
            icon: Icon(Icons.horizontal_split,
                color: Color.fromRGBO(230, 230, 230, 1)),
            onOptionSelected: setSelectedTool),
      ]),
    ]);
  }
}
