import "package:flutter/material.dart";
import "option_item.dart";
import "grid_editor.dart";

class EditOptions extends StatefulWidget {
  // Edit Options Menu for Growing Ceil, Splitting Ceil(Vertical or Horizontal),Merging Ceils
  EditOptions({required this.cancel,
   required this.selectedCeil,
   required this.removeChild});
  @override
  State<EditOptions> createState() => EditOptionsState();
  // This function removeChild is called to reset parent ceils or subCeil to its default
  // It is called from OptionItem
  void Function() removeChild;
  //  Number of selected ceil 
  int selectedCeil;
  // This function is called to navigate to previous menu
  void Function() cancel;
   
}

class EditOptionsState extends State<EditOptions> {
  var selectedTool = "";
  // This function set active EditSubmenu item
  void setSelectedTool(String selection) {
    setState(() {
      selectedTool = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    var topWidget = context.findRootAncestorStateOfType<GridEditorState>();
    // List Possible ceils that can be merged into one ceil
    var activeChild = topWidget?.getActiveChild();

    // Show mergin option
    bool flag = false;

    // Check if there are active children that are possibly to be merged together
    // if "YES" set flag = true; else flag = false.
    if (activeChild != null) {
      if (activeChild.length == 2)
        flag = true;
    }

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BackButton(
              color: Color.fromRGBO(200, 200, 200, 1),
              onPressed: () {
                widget.cancel();
              }),
          Text("Edit Ceil Options",
              style: TextStyle(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  fontSize: 12,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w100)),
        ],
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Row(children: [
            // If merging is possible show merge option
            if (flag)
              OptionItem(
                  label: "Merge",
                  icon: Icon(Icons.merge,
                      color: Color.fromRGBO(200, 200, 200, 1)),
                  onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Remove",
                icon:
                    Icon(Icons.remove, color: Color.fromRGBO(230, 230, 230, 1)),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Split",
                icon: Icon(Icons.splitscreen,
                    color: Color.fromRGBO(230, 230, 230, 1)),
                onOptionSelected: setSelectedTool),
            OptionItem(
                label: "Grow",
                icon: Icon(Icons.elevator,
                    color: Color.fromRGBO(230, 230, 230, 1)),
                onOptionSelected: setSelectedTool)
          ]),      ]),
      )
    ]);
  }
}
