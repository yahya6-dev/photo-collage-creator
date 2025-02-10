import "package:flutter/material.dart";
import "ceil.dart";
import "editor.dart";
import "my_home_page.dart";
import "dart:ui" as ui;
import "utils.dart";
import "grid_editor.dart";

class MainScreen extends StatefulWidget {
  // Our grid size
  int gridSize;
  // Possibly list of ceils that can be merged
  List<Ceil> children = [];
  // Solid background color of our canvas 
  Color? color;
  // Image background of our canvas
  ui.Image? image;
  // Refresh grid editor
  void Function() refreshScreen;
  // Cout number of selected ceil
  void Function(int arg) addSelectedCeil;
  

  MainScreen(
      {required this.gridSize,
      required this.refreshScreen,
      required this.addSelectedCeil,
      required this.children,
      required this.isGridOpened,
      required this.isMerginPossible,
      this.color,
      this.image});

  // Indicator if gridlines are showned or not
  bool isGridOpened;
  // This function determine whether two ceils can be merged
  bool Function(List<int>) isMerginPossible;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Refresh Our Canvas by redrawing it, default dont refresh
  bool refresh = false;

  // Refresh  this widget
  void updateState() {
    setState(() {
      refresh = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var topParent = context.findRootAncestorStateOfType<GridEditorState>();

    // Calculate area size of our canvas
    var height = MediaQuery.sizeOf(context).height;
    var width = MediaQuery.sizeOf(context).width;
    
    var size = Size(width, height / 2);

    // If image is used as background, find apropriate size for it.
    if (widget.image != null) {
      var imageHeight = widget.image?.height as int;
      var imageWidth = widget.image?.width as int;

      var sizing = findImageSize(imageWidth.toDouble(),imageHeight.toDouble(),width,height);
      size = Size(sizing[0],sizing[1]);

    } 

    return Center(
      child: SingleChildScrollView(
          child: Listener(
              // Respond when any of our grid ceils is tapped
              onPointerUp: (PointerUpEvent event) {
                Offset local = event.localPosition;

                // Track the index of our grid ceils 
                var index = 0;
                // indexes of selected ceils
                List<int> activeChild = [];

                // Determine which ceil is selected or deselected
                widget.children.forEach((child) {
                  child.updateState(local, updateState, widget.addSelectedCeil);
                  
                  // Add ceil index to activeChild, as it may be merged into other ceil
                  // if selected.
                  if (child.getSelectionState() && (!child.isMerged) ) activeChild.add(index);
                  
                  index += 1;
                });

              // Checking activeChild.length == 2, to decide whether two ceils can be merged 
              if (activeChild.length == 2) {
                bool isPossible = widget.isMerginPossible(activeChild);

                // If merging is possible inform gridEditor, that merging is possible on the selected ceil
                if (isPossible)
                  topParent?.setActiveChild(activeChild);

                // Reset reset mergeable ceil to empty list, since they cant be merged
                else {
                  topParent?.setActiveChild([]);

                }
               }

               // Merging is not allowed on morethan 2 ceils or less than 1 ceils
               else {
                topParent?.setActiveChild([]);
               }

              },
              // Draw our canvas
              child: CustomPaint(
                size: size,
                painter: Editor(
                    isGridOpened:widget.isGridOpened,
                    children: widget.children,
                    gridSize: widget.gridSize,
                    image: widget.image,
                    color: widget.color,
                    shouldPaint: refresh),
              ))),
    );
  }
}
