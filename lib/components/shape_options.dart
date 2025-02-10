import "package:flutter/material.dart";
import "option_item.dart";

class ShapeOptions extends StatefulWidget {
  ShapeOptions({required this.cancel,required this.setShape});
  @override
  State<ShapeOptions> createState() => ShapeOptionsState();

  void Function() cancel;
  void Function(String) setShape;
}


class ShapeOptionsState extends State<ShapeOptions> {
  var selectedTool = "";
  // Set Current Selected Ceil's Shape in the OptionItem 
  void setSelectedTool(String selection) {
    setState(() {
      selectedTool = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // List of available shape that a ceil can be made to
      Row(
        children:[BackButton(
              color: Color.fromRGBO(230, 230, 230, 1),
              onPressed: () {
                widget.cancel();
              }),Text("Change Grid Ceil Shape",
          style: TextStyle(
              color: Color.fromRGBO(200, 200, 200, 1),
              fontSize: 12,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w100)), 
          ]),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Row(children: [
            OptionItem(
                label: "Heart",
                icon: null,
                image: Image.asset("assets/heart.png"),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Star",
                icon:
                    Icon(Icons.star_outlined, color: Color.fromRGBO(230, 230, 230, 1)),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Rectangle",
                icon: Icon(Icons.rectangle_outlined,
                    color: Color.fromRGBO(230, 230, 230, 1)),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Hexagon",
                icon: null,
                image: Image.asset("assets/hexagon.png"),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Pentagon",
                icon: null,
                image: Image.asset("assets/pentagon.png"),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Heptagon",
                icon: null,
                image: Image.asset("assets/heptagon.png"),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Triangle",
                icon: null,
                image: Image.asset("assets/triangle.png"),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Diamond",
                icon: Icon(Icons.diamond_outlined,size:20,color:Color.fromRGBO(220,220,220,1)),
                //image: Image.asset("assets/diamond.png"),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Circle",
                icon: Icon(Icons.circle_outlined,size:20,color: Color.fromRGBO(220,220,220,1)),
                onOptionSelected: setSelectedTool),
          ]),
        ]),
      )
    ]);
  }
}
