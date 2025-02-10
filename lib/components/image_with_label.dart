import "package:flutter/material.dart";

class ImageWithLabel extends StatefulWidget {
  ImageWithLabel(
      {required this.image,
      required this.label,
      required this.isSelected,
      required this.keyId,
      required this.onPressed});

  // Set the grid size and inform the parent
  void Function(String key) onPressed;
  // This widget icon
  Icon image;
  // This widget label/title
  String label;
  // Determine if this widget is selected
  bool isSelected;
  // Id of this widget
  String keyId;

  @override
  State<ImageWithLabel> createState() => ImageWithLabelState();
}

class ImageWithLabelState extends State<ImageWithLabel> {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        child: Padding(
            padding: EdgeInsets.all(4.0),
            child:Card(
              color:Color.fromRGBO(37, 37, 50, 0.9),
              margin: EdgeInsets.all(8),

              // Arranged its children in column order
              child: Column(children: [widget.image, Text(widget.label,style:TextStyle(color: (widget.isSelected ? Color.fromRGBO(0,100,250,1) : Colors.white),fontSize:12))]))),
            onTap: () {
              // Set this widget as the selected one
              widget.onPressed(widget.keyId);
        });
  }
}
