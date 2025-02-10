import "package:flutter/material.dart";
import "package:flutter_colorpicker/flutter_colorpicker.dart";
import "fill_options.dart";
import "grid_editor.dart";
import  "image_crop_widget.dart";
import "dart:ui" as ui;
import "edit_options.dart";
import "split_options.dart";
import "ceil_options.dart";
import "grow_options.dart";
import "shape_options.dart";
import "border_options.dart";
import "dart:io";
import "package:file_picker/file_picker.dart";

// This file contains only distinct operation
// to apply to the current selected ceils, and it is serving as Option Menu Item.
class OptionItem extends StatefulWidget {
  OptionItem(
      {required this.icon,
      required this.label,
      required this.onOptionSelected,
      this.image});
  
  // Icon to display  as option menu icon
  final Icon? icon;
  
  // Label to display as an option menu label 
  final String label;

  // Function to call when option menu is tapped
  final void Function(String key) onOptionSelected;

  // It serve the same function as icon, if icon is not provided, to use as icon.
  final Image? image;

  @override
  State<OptionItem> createState() => OptionItemState();
}

class OptionItemState extends State<OptionItem> {
  // Active ceil color default to green blue;
  var activeColor = Color.fromRGBO(0,100,250,1);

  // ceil background filling
  Color color = Colors.white;


  // Path to image to use as ceil background image
  String? selectedImagePath;
  // Default ceil border color
  var borderColor = Colors.white;


  // This Function is called to pop up the file picker for selecting image to be used as ceil background.
  // The function is called when the user select an Image option from Filling option menu
  Future<void> setImagePath(final void Function(ui.Picture picture,int,int) setImageFilling) async {
    // Pop up the file picker for image selection
      // supported extension png jpg jpeg
      FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowMultiple: false,
              allowedExtensions: ["png", "jpg", "jpeg"]);

      setState(() {
        // if result is not null the user made a selection
        if (result != null){
          selectedImagePath = result.files.single.path; 
         }

         if (selectedImagePath != null) {
           var path = selectedImagePath as String;
           // Reset selected image path for subsequent calls
           selectedImagePath = null;
           showDialog(
             context: context,
             builder: (context) {
                return Dialog.fullscreen(
                    backgroundColor:Color.fromRGBO(57, 57, 70, 0.6),
                    // Attach ImageCropWidget for loading and cropping user selected image
                    child: ImageCropWidget(imagePath:path,setImageFilling: setImageFilling)
                    );
                  });
                
              }
        });
  }

  // This Function is used to trace,
 //  which color a user choose to use as background filling of a selected ceil.
  void setColor(Color color) {
    setState(() {
      this.color = color;
    });
  }


  @override
  Widget build(BuildContext context) {
    // Get References to the parent widgets for calling corresponding operation
    var topWidget = context.findRootAncestorStateOfType<FillOptionsState>();
    var gridEditor = context.findRootAncestorStateOfType<GridEditorState>();
    var editOptions = context.findRootAncestorStateOfType<EditOptionsState>();
    var splitCeil = context.findRootAncestorStateOfType<SplitOptionsState>();
    var ceilOptions = context.findRootAncestorStateOfType<CeilOptionsState>();
    var growOptions =
        context.findRootAncestorStateOfType<GrowOptionsState>();
    var shapeOptions = context.findRootAncestorStateOfType<ShapeOptionsState>();
    var borderOptions = context.findRootAncestorStateOfType<BorderOptionsState>();

    // Retrieve selected  tool from ceilOptions
    var selectedTool = "";
    if (ceilOptions?.selectedTool != null)
      selectedTool = ceilOptions?.selectedTool as String;

    return GestureDetector(
        child: Container(
            margin: EdgeInsets.all(8.0),
            child: Column(children: [

              // Either of one them must be null
              if (widget.icon != null) widget.icon as Icon,
              if (widget.image != null) widget.image as Image,
              
              SizedBox(height: 4),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 12,
                      // Change selected color when it is active.
                      color: selectedTool == widget.label ? activeColor : Color.fromRGBO(230, 230, 230, 1),
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none)),
            ])),
        onTap: () {
          widget.onOptionSelected(widget.label);
          // When This widget is tapped, carry out the apropriate operation on the selected ceils
          switch (widget.label) {
            // Rotate the the selected ceils.
            case "Rotate":
              gridEditor?.rotateCeils();
              break;

            // Change selected ceils' border color
            case "Border Color":
               // Pop a dialog containing color picker
               showDialog(
                  builder: (context) {
                    return AlertDialog(
                        backgroundColor: Color.fromRGBO(57, 57, 70, 1),
                        iconColor: Color.fromRGBO(57, 57, 70, 1),
                        contentTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        title: Text("Choose Border Color",
                                  style: TextStyle(
                                  color: Color.fromRGBO(230, 230, 230, 1))),

                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () {
                                // Call setBorderColor from the borderOption, to affect selected ceil's border
                                borderOptions?.widget
                                    .setBorderColor(borderColor);
                                Navigator.of(context).pop();
                                ceilOptions?.setSelectedTool("Border");
                              },
                              child: Text("Set"))
                        ],
                        content: SingleChildScrollView(
                            child: ColorPicker(
                                pickerColor: borderColor,
                                onColorChanged: (Color color) {
                                  borderColor = color;

                                })));
                  },
                  context: context);
                  break;

            case "Grow":
              // Set Selected tool to Grow, therefore ceilOptions will render GropOption widget
              // as its submenu
              ceilOptions?.setSelectedTool("Grow");
              break;

            // Call splitCeil.widget.splitVertical to split our selected ceil vertically
            case "Split Vertical":
              splitCeil?.widget.splitVertical();
              break;

            // Call splitCeil.widget.splitHorizontal to split our selected ceil horizontally
            case "Split Horizontal":
              splitCeil?.widget.splitHorizontal();

            // Set current selected tool to  "Split", therefore CeilOptions will render SplitOption as menu
            // for splitting ceils.
            case "Split":
              ceilOptions?.setSelectedTool("Split");
              break;
            // Remove Ceil style by calling editOptions.widget.removeChild
            case "Remove":
              editOptions?.widget.removeChild();
              break;
            // Merge two ceils that are adjacent to each other, provided they one of them or all contains no style
            case "Merge":
              gridEditor?.mergeCeils();
              break;
              // Change Selected  Ceil's Shape
            case "Heart" ||
                  "Star" ||
                  "Rectangle" ||
                  "Hexagon" ||
                  "Pentagon" ||
                  "Heptagon" ||
                  "Triangle" ||
                  "Diamond" ||
                  "Circle":
              shapeOptions?.widget.setShape(widget.label);
              break;

            // Pop up dialog for selecting color to use as ceil's filling
            case "Color":
              showDialog(
                  builder: (context) {
                    return AlertDialog(
                        backgroundColor: Color.fromRGBO(57, 57, 70, 1),
                        iconColor: Color.fromRGBO(57, 57, 70, 1),
                        contentTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        title: Text("Choose Filling Color",
                            style: TextStyle(
                                color: Color.fromRGBO(230, 230, 230, 1))),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () {
                                topWidget?.widget.setColor(color);
                                Navigator.of(context).pop();
                              },
                              child: Text("Fill"))
                        ],
                        content: SingleChildScrollView(
                            child: ColorPicker(
                                pickerColor: Colors.white,
                                onColorChanged: (Color color) {
                                  // Trace which color, our user select
                                  setColor(color);
                                })));
                  },
                  context: context);
              break;
              // Set Image Path to load and use an image as background of selected ceil
            case "Image":
              setImagePath(gridEditor!.setImageFilling);
              break;
          }
        });
  }
}
