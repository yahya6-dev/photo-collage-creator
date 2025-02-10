import "package:flutter/material.dart";
import "grow_options.dart";
import "border_options.dart";
import "edit_options.dart";
import "option_item.dart";
import "fill_options.dart";
import "shape_options.dart";
import "dart:ui" as ui;
import "split_options.dart";

class CeilOptions extends StatefulWidget {
  CeilOptions(
      {required this.onPressed,
      required this.selectedCeil,
      required this.setColor,
      //required this.setImage,
      required this.removeChild,
      required this.splitVertical,
      required this.splitHorizontal,
      required this.setElevationHeight,
      required this.elevationHeight,
      required this.setShape,
      required this.setBorderColor});

  final void Function(Color) setBorderColor;
  // Set selected ceils' shape
  final void Function(String) setShape;
  // Dismiss this menu
  final void Function() onPressed;
  // Set a solid color as filling
  final void Function(Color color) setColor;
  final void Function() splitHorizontal;
  final void Function() splitVertical;
  final void Function(double) setElevationHeight;
  // Reset Ceil's style
  final void Function() removeChild;
  // Set Image on selected Ceil
  //final void Function(ui.Image image) setImage;

  final double elevationHeight;
  // Number of selected Ceil
  final int selectedCeil;

  @override
  State<CeilOptions> createState() => CeilOptionsState();
}

class CeilOptionsState extends State<CeilOptions> {
  // Selected Option Item
  String selectedTool = "";

  // An interface to be passed to OptionItem, so that it will call
  // in case an item is selected, to determine which operation to run
  void setSelectedTool(String selection) {
    setState(() {
      selectedTool = selection;
    });
  }

  // Call to close sub menu to return back to this widget
  void cancel() {
    setState(() {
      selectedTool = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine which menu to display, for submenu
    switch (selectedTool) {
      case "Grow":
        return GrowOptions(
            setSelectedTool: setSelectedTool,
            elevationHeight: widget.elevationHeight,
            setElevationHeight: widget.setElevationHeight);
      case "Split":
        return SplitOptions(
            cancel: cancel,
            setSelectedTool: setSelectedTool,
            splitVertical: widget.splitVertical,
            splitHorizontal: widget.splitHorizontal);
      case "Shape":
        return ShapeOptions(cancel: cancel, setShape: widget.setShape);
      case "Fill":
        return FillOptions(
            cancel: cancel,
            setColor: widget.setColor,
            //setImage: widget.setImage
            );
      case "Edit":
        return EditOptions(
            cancel: cancel,
            selectedCeil: widget.selectedCeil,
            removeChild: widget.removeChild);

      case "Border":
        return BorderOptions(
            cancel: cancel, setBorderColor: widget.setBorderColor);
      default:
        // These are default menu for display when no submenu is selected
        return Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          OptionItem(
              icon: Icon(Icons.image_outlined,
                  size: 20, color: Color.fromRGBO(200, 200, 200, 1)),
              label: "Fill",
              onOptionSelected: setSelectedTool),
          OptionItem(
              icon: Icon(Icons.edit,
                  size: 20, color: Color.fromRGBO(200, 200, 200, 1)),
              label: "Edit",
              onOptionSelected: setSelectedTool),
          OptionItem(
              icon: Icon(Icons.shape_line_outlined,
                  size: 20, color: Color.fromRGBO(200, 200, 200, 1)),
              label: "Shape",
              onOptionSelected: setSelectedTool),
          OptionItem(
              icon: Icon(Icons.border_all,
                  size: 20, color: Color.fromRGBO(200, 200, 200, 1)),
              label: "Border",
              onOptionSelected: setSelectedTool),
          OptionItem(
              icon: Icon(Icons.crop_rotate,
                  size: 20, color: Color.fromRGBO(200, 200, 200, 1)),
              label: "Rotate",
              onOptionSelected: setSelectedTool)
        ]));
    }
  }
}
