import "package:flutter/material.dart";
import "image_with_label.dart";

class GridChooser extends StatefulWidget {
  GridChooser({required this.selectedKey, required this.onPressed});

  String selectedKey;
  void Function(String key) onPressed;

  @override
  State<GridChooser> createState() => GridChooserState();
}

class GridChooserState extends State<GridChooser> {
  @override
  Widget build(BuildContext context) {
    // list of images
    var four_four =
        Icon(Icons.grid_4x4, color: Color.fromRGBO(200, 200, 200, 1));
    var six_six =
        Icon(Icons.grid_view, color: Color.fromRGBO(200, 200, 200, 1));
    var three_three =
        Icon(Icons.grid_3x3, color: Color.fromRGBO(200, 200, 200, 1));

    return Container(
        // Container list of grid type represented as ImageWithLabel
        // That each ImageWithLabel change state on pressed,
        // ImageWithLabel expect label pass as string for title
        // keyId which is used to know which grid is selected
        // and Icon from material lib, isSelected make the
        // comparison to know which button is imagewithlabel to mark as
        // selected.
        decoration: BoxDecoration(color: Color.fromRGBO(37, 37, 50, 0.7)),
        padding: EdgeInsets.all(4.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ImageWithLabel(
              label: "3x3 grid",
              image: three_three,
              isSelected: "one" == widget.selectedKey,
              keyId: "one",
              onPressed: widget.onPressed),
          ImageWithLabel(
              label: "4x4 grid",
              image: four_four,
              isSelected: "two" == widget.selectedKey,
              keyId: "two",
              onPressed: widget.onPressed),
          ImageWithLabel(
              label: "6x6 grid",
              image: six_six,
              isSelected: "three" == widget.selectedKey,
              keyId: "three",
              onPressed: widget.onPressed)
        ]));
  }
}
