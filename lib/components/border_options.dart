import "package:flutter/material.dart";
import "option_item.dart";
import "grid_editor.dart";

class BorderOptions extends StatefulWidget {
  // This Widget render User Interface for setting current selected  ceil's
  // border color and border width, It expect argument cancel of type function
  // use to move back to the main menu
  BorderOptions({required this.cancel, required this.setBorderColor});
  @override
  State<BorderOptions> createState() => BorderOptionsState();
  // Dismiss this submenu
  final void Function() cancel;

  // Interface to set border color on selected called from OptionsItem
  // this one route the call to the gridEditor for the corresponding update
  final void Function(Color) setBorderColor;

}

class BorderOptionsState extends State<BorderOptions> {
  // Current selected tool under focus
  var selectedTool = "";

  // Change selectedTool based on the recent tool that is tapped.
  // render the widget again
  void setSelectedTool(String selection) {
    setState(() {
      selectedTool = selection;
    });
  }


  @override
  Widget build(BuildContext context) {
    var topWidget = context.findRootAncestorStateOfType<GridEditorState>();

    // Get a corresponding border color and width from the gridEditor, as the state for border is maintained 
    // at all by GridEditor
    Color borderColor;
    double borderWidth;

    // Retrieve border color from GridEditor
    if (topWidget?.getBorderColor() != null)
      borderColor  = topWidget?.getBorderColor() as Color;

    else 
      borderColor = Colors.white;

    // Retrieve border width from GridEditor
    if (topWidget?.getBorderWidth() != null) 
      borderWidth = topWidget?.getBorderWidth() as double;
    else
      borderWidth = 0;


    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Main Header
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        BackButton(
            color: Color.fromRGBO(200, 200, 200, 1),

            // Close this widget and return back to main menu
            onPressed: () {
              widget.cancel();
            }),
        Text("Ceil Border Option",
            style: TextStyle(
                color: Color.fromRGBO(200, 200, 200, 1),
                fontSize: 12,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w100))
      ]),
      Row(children: [
        // This widget render OptionItem[consisting of label and icon] that when tapped changes selectedTool
        // to its label and carry out an operation on the selected grid ceil
        OptionItem(
            label: "Border Color",
            icon: Icon(Icons.border_color,
                color: Color.fromRGBO(200, 200, 200, 1)),
            onOptionSelected: setSelectedTool),

        // Slider for setting border color
        Card(
            color: Color.fromRGBO(37, 37, 50, 1),
            child: Column(children: [
              Slider(
                secondaryActiveColor: Color.fromRGBO(37, 37, 50, 1),
                value: borderWidth,
                onChanged: (value) {
                  // Call setBorderWidth from gridEditor to set the border width
                  topWidget?.setBorderWidth(value);
                 
                },
                label: "Border Width",
                min: 0,
                max: 8,
                activeColor: Color.fromRGBO(37, 37, 50, 1),
                thumbColor: Color.fromRGBO(0, 100, 250, 1),
                overlayColor: WidgetStatePropertyAll<Color>(
                    Color.fromRGBO(37, 37, 50, 1)),
              ),
              Text("Border Width",
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1)))
            ])),
      ]),
    ]);
  }
}
