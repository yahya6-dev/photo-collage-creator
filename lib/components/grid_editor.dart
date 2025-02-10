import "package:flutter/material.dart";
import "main_screen.dart";
import "ceil_options.dart";
import "export_image.dart";
import "my_home_page.dart";
import "dart:ui" as ui;
import "ceil.dart";
import "package:multiselect/multiselect.dart";
import "package:file_picker/file_picker.dart";
import "dart:io";
import "dart:typed_data";
import "utils.dart";

class GridEditor extends StatefulWidget {
  // List Ceil instance representing ceils on our grid
  List<Ceil> children = [];
  // Our canvas grid size
  int gridSize;

  GridEditor({required this.gridSize}) {
    // Initialize our Ceil instance, that correspond with the number of gridSize
    for (var index = 0; index < gridSize * gridSize; index++) {
      children.add(Ceil());
    }
  }

  State<GridEditor> createState() => GridEditorState();
}

class GridEditorState extends State<GridEditor> {
  // Number ceils selected in the grid editor
  var selectedCeil = 0;
  // Redraw our canvas
  bool refresh = false;

  // These two variable are used to approximate the elevated ceil size 
  // in the destination image as they may have different size, output resolution can be higher than
  // our canvas resolution
  double heightMultiplier = 1.0;
  double widthMultiplier = 1.0;

  // Setting active child elevation on each slider move
  double elevationHeight = 0;

  // Hold a referrence to active childs, for determining whether two merging is possible or not
  List<int> activeChild = [];

  //bool isSelected = false;

  // Called to remove all ceils selection
  void deSelect() {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) child.setSelectionState(false);
        // Remove Selection on subceils
        child.subCeils.forEach((sub) {
          sub.setSelectionState(false);
        });
      });
      // reset number of selected ceils
      selectedCeil = 0;
    });
  }

  // Border Width & Border Color of just selected ceils
  double borderWidth = 0;
  Color borderColor = Colors.white;

  // Method for setting border color then route it to the  selected ceil for updating ceil border
  void setBorderColor(Color color) {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) child.setBorderColor(color);

        // Iterate through subCeils
        child.subCeils.forEach((ceil) {
            if (ceil.getSelectionState()) 
                ceil.setBorderColor(color);
          });
      });

      borderColor = color;
    });
  }

  // Method to retrieve border color
  Color getBorderColor() {
    return borderColor;
  }

  // Method for setting border width then route it to the ceil for updating ceil border width
  void setBorderWidth(double width) {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) child.setBorderWidth(width);
        // Loop through subceils
        child.subCeils.forEach((ceil) {
          if (ceil.getSelectionState()) {
            ceil.setBorderWidth(width);
          }
          });
      });
      borderWidth = width;
    });
  }

  // Method to get border width
  double getBorderWidth() {
    return borderWidth;
  }

  // Set active selected children, used for determining whether two ceils can be merged
  void setActiveChild(List<int> active) {
    setState(() {
      activeChild = [];

      // Copy active indexes to activeChild
      active.forEach((index) {
        activeChild.add(index);
      });
    });
  }

  // Get active selected children
  List<int> getActiveChild() {
    return activeChild;
  }

  // Our Canvas background image
  ui.Image? image;
  // flag to toggle gridlines on/off
  bool isGridOpened = true;

  // Toggle gridlines
  void setGridState(bool value) {
    setState(() {
      isGridOpened = value;

    });
  }

  // Set Image to the selected ceil as its background, usedb from ImageCropWidget
  void setImageFilling(ui.Picture picture, int width, int height) {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) {
          child.setPicture(picture as ui.Picture, width, height);
        }
        // Loop through sub ceils if any is selected
        child.subCeils.forEach((ceil)  {
          if (ceil.getSelectionState()) {
            ceil.setPicture(picture as ui.Picture,width,height);
          }
          });
      });
    });
  }

  // Reset our elevation height to ther value
  void resetElevationHeight(double value) {
    elevationHeight = value;
  }

  // Increase number of selected ceil used by Ceil class, when another ceil is selected
  void addSelectedCeil(int ceil) {
    setState(() {
      selectedCeil += ceil;
    });
  }

  // This decide if it is possible for two or more ceils to be merged together
  bool isMerginPossible(List<int> indexes) {
    bool flag = true;

    // First child
    var firstChild = widget.children[indexes[0]];

    // Terminate Early if Either ceils has a subCeils
    if (firstChild.subCeils.length > 0) {
      flag = false;
      return flag;
    }

    // Check whether merging is possible between two ceil by checking if they overlap
    Rect firstRect = firstChild.getRect();
    var pos = indexes[1];
    var secondChild = widget.children[pos];
    var secondRect = secondChild.getRect();

    // Terminate Early if Second has subCeils
    if (secondChild.subCeils.length > 0) {
      flag = false;
      return flag;
    }

    if (!firstRect.inflate(8.0).overlaps(secondRect)) {
      flag = false;
    }

    // Verify further they have same x or y
    var position1 = firstChild.getPosition();
    var position2 = secondChild.getPosition();
    if (!(position1[0] == position2[0] || position1[1] == position2[1])) {
      flag = false;
    }

    // Check either one of the ceils  is empty ["Dont have any content ie text color filling, or image"]
    // if not flag it as invalid mergin
    if (firstChild.haveFilling && secondChild.haveFilling) flag = false;

    // Check firstChild if it  has already merged another ceil
    // Allow only next merging if next merged ceil is on the same axis [Vertical or horizontal] as the
    // previous merging ceil.
    if (position1[0] == position2[0] && (firstChild.merginAxis == "Horizontal"))
      flag = false;

    if (position1[1] == position2[1] && (firstChild.merginAxis == "Vertical"))
      flag = false;

    return flag;
  }

  // Merging operation
  void mergeCeils() {
    setState(() {
      if (activeChild.length != 2) return;

      List<int> active = [];
      var index = 0;

      // Find active ceil indexes
      // and merge them together
      // If they have same x, increase height of  the second ceil,
      // if they have same y, increase width to the second ceil
      // then call setIsMerged(true) in the secondCeil
      widget.children.forEach((child) {
        if (child.getSelectionState()) active.add(index);

        index += 1;
      });

      // Possibly adjacent ceils
      var firstChild = widget.children[active[0]];
      var secondChild = widget.children[active[1]];

      // children positions [x,y]
      var position1 = firstChild.getPosition();
      var position2 = secondChild.getPosition();

      // Children width and height
      var size1 = firstChild.getSize();
      var size2 = secondChild.getSize();

      // Check if they have same x, you merge them vertically
      if (position1[0] == position2[0]) {
        firstChild.setRect(
            position1[0], position1[1], size1[0], size1[1] + size2[1]);
        firstChild.merginAxis = "Vertical";
      }

      // Check if they have same y, you merge them horizontally
      if (position1[1] == position2[1]) {
        firstChild.setRect(
            position1[0], position1[1], size1[0] + size1[0], size1[1]);
        firstChild.merginAxis = "Horizontal";
      }

      // Signal secondChild that it is no longer needed to be drawned.
      secondChild.setIsMerged(true);
      // Store first child Id so that in the course of saving, we trace back to the parent and merge
      // this ceil to it
      secondChild.merginId = firstChild.id;
      // Deselect second child ceil once merged to first ceil
      secondChild.setSelectionState(false);
      selectedCeil -= 1;
      // Reset active child to only firstChild
      activeChild = [active[0]];
    });
  }

 // This method remove cell's style.
   void removeActive() {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) {
          // Remove this ceil style and filling from the grid
          child.setSelectionState(false);
          child.removeCeilFilling();
          selectedCeil = 0;
        }

        // Loop through subCeils
        child.subCeils.forEach((ceil) {
          if (ceil.getSelectionState()) {
            child.setSelectionState(false);
            child..removeCeilFilling();
            selectedCeil = 0;
          }
          });
      });
    });
  }

  // Split Selected ceil vertically
  void splitVertical() {
    setState(() {
      widget.children.forEach((child) {
        // SubCeils can't be further subdivided
        /*child.subCeils.forEach((ceil) {
          if (ceil.getSelectionState()) ceil.splitVertical();
        });*/

        if (child.getSelectionState()) {
          child.splitVertical();
        }
      });
    });
  }

  void splitHorizontal() {
    setState(() {
      widget.children.forEach((child) {
        // Not yet implemented subCeil cant be splitted
        /*child.subCeils.forEach((ceil) {
          if (ceil.getSelectionState()) ceil.splitHorizontal();
        });*/

        if (child.getSelectionState()) {
          child.splitHorizontal();
        }
      });
    });
  }

  // Set Elevation to grow/enlarge the selected cells.
  void setElevationHeight(double value) {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) {
          child.setElevationHeight(value);
          elevationHeight = value;
        }

        // ElevationHeight of ceils not allowed
      });
      widget.children
          .sort((a, b) => (a.getElevationLevel() - b.getElevationLevel()));
    });
  }

  // Set Selected Ceil's Shape
  void setShape(String shape) {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) {
          child.setShape(shape);
        }

        // Loop through subCeils
        child.subCeils.forEach((ceil) {
          if (ceil.getSelectionState()) {
              ceil.setShape(shape);
          }
          });
      });
    });
  }

  // Set Color filling of the selected ceils.
  void setColor(Color color) {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) {
          child.setColor(color);
        } 
        // LOOP Through subceils if any
        child.subCeils.forEach((ceil) {
          if (ceil.getSelectionState()) {
              ceil.setColor(color);
          }
          });
      });
    });
  }

  // This function will be called to construct the picture scene by using PictureRecorder
  // to record graphics on the canvas.
  // It convert the image to png then save to filesystem
  Future<String?> exportImage(Color? color, ui.Image? image) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    var rect = Rect.fromLTWH(0, 0, exportWidth, exportHeight);
    Canvas canvas = Canvas(recorder, rect);
    // Clone actual ceils from this widget, as working directly can bring an adverse effect 
    List<Ceil> ceils = [
      ...widget.children.map((child) {
        return child.clone();
      })
    ];
    // Sort the based on the Id of our ceils,
    // This will help to draw them as the're in the original canvas
    ceils.sort((a, b) => a.getId() - b.getId());

    // Draw filling either image or solid color
    var height = exportHeight;
    var width = exportWidth;
    // Calculate our grid columns and rows
    var ceilWidth = width / widget.gridSize;
    var ceilHeight = height / widget.gridSize;
    // Clip anything that goes outside the allotted space
    var boundaryPath = Path();
    boundaryPath.addRect(Rect.fromLTWH(0, 0, width, height));
    boundaryPath.close();
    canvas.clipPath(boundaryPath);

    // Draw our background of the canvas as solid color if any
    if (color != null) {
      canvas.save();
      var paint = Paint()..color = color as Color;
      // screen rect size
      var rect = Rect.fromLTWH(0, 0, width, height);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
    // Draw our background of the canvas as image if any
    if (image != null) {
      var imageHeight = image?.height as int;
      var imageWidth = image?.width as int;

      var paint = Paint()..color = Colors.white;
      // image rect
      var imageRect = Rect.fromPoints(
          Offset(0, 0), Offset(imageWidth.toDouble(), imageHeight.toDouble()));
      var screenRect = Rect.fromPoints(Offset(0, 0), Offset(width, height));
      canvas.drawImageRect(image as ui.Image, imageRect, screenRect, paint);
    }

    // List of our newly cloned ceils' Rectangle
    var childrenPosition = <List<double>>[];
    for (var row = 0; row < widget.gridSize; row++) {
      for (var col = 0; col < widget.gridSize; col++) {
        List<double> startingOffsets;
        startingOffsets = [
          (col * ceilWidth),
          (ceilHeight * row),
          ceilWidth,
          ceilHeight
        ];
        // Rectangle size
        childrenPosition.add(startingOffsets);
      }
    }
    for (int pos = 0; pos < childrenPosition.length; ++pos) {
      List<double> position = childrenPosition[pos];
      print(position);
      var x = position[0];
      var y = position[1];
      var width = position[2];
      var height = position[3];

      // Recalculate elevation if ceil has any 
      if (ceils[pos].getElevationLevel() >= 1.0) {
        var elevation = ceils[pos].getElevationLevel().toDouble();
        ceils[pos].setRect(x, y, width, height);
        ceils[pos].setElevationHeightCustom(
            elevation, widthMultiplier, heightMultiplier);
      } else {
        ceils[pos].setRect(x, y, width, height);
      }

      // Scale the border according to the output size
      ceils[pos].borderWidth *= (heightMultiplier + widthMultiplier) / 2;
    }
    // Resolve merged ceils by actually mergin them
    ceils.forEach((secondChild) {
      if (secondChild.isMerged) {
        // find Parent ceil it is merged to
        var mergedId = secondChild.merginId as int;

        for (int index = 0; index < ceils.length; index++) {
          if (mergedId == ceils[index].id) {
            var firstChild = ceils[index];
            // Merge ceil to this current

            // children positions [x,y]
            var position1 = firstChild.getPosition();
            var position2 = secondChild.getPosition();

            // Children width and height
            var size1 = firstChild.getSize();
            var size2 = secondChild.getSize();
            // If they have same x merge them vertically
            if (position1[0] == position2[0]) {
              firstChild.setRect(
                  position1[0], position1[1], size1[0], size1[1] + size2[1]);
              firstChild.merginAxis = "Vertical";
            }
            // If they have same y merge them horizontally
            if (position1[1] == position2[1]) { 
              firstChild.setRect(
                  position1[0], position1[1], size1[0] + size1[0], size1[1]);
              firstChild.merginAxis = "Horizontal";
            }

            // Signal secondChild that it is no longer needed to be drawned.
            secondChild.setIsMerged(true);
          }
        }
      }
    });
    // Sort the ceil based on the overlap each ceil has
    ceils.sort((a, b) => (a.getElevationLevel() - b.getElevationLevel()));

    // Resolve subceils by actually drawing them in the canvas with appropriate size.
    for (var ithCeil = 0; ithCeil < ceils.length; ithCeil++) {
      Ceil child = ceils[ithCeil];

      List<Ceil> subCeils = [...child.subCeils.map((ceil) => ceil.clone())];
      // Store subceils here and remove them from child so as to update their x,y and width,height
      // after executing split operation stored in splitOperation
      child.subCeils = [];

      // Trace split operation within the ceils
      // then repeat them here
      for (var i = 0; i < child.splitOperation.length; i++) {
        var operation = child.splitOperation[i];

        if (operation == "horizontal") {
          child.splitHorizontal();
        } else if (operation == "vertical") {
          child.splitVertical();
        }
      }

      // Get size and position of the subCeils afterward update it to store subceils
      for (int index = 0; index < subCeils.length; index++) {
        var pos = child.subCeils[index].getPosition();
        var size = child.subCeils[index].getSize();
        subCeils[index].setRect(pos[0], pos[1], size[0], size[1]);
      }
      // Update Child with subceils having correct x,y and width, height
      child.subCeils = subCeils;
    }

    // Draw the ceils onto the canvas
    ceils.forEach((ceil) {
      // Draw only ceils that are not merged to other ceils
      if (!ceil.isMerged) {
        ceil.drawItem(canvas, isGridOpened);
      } else {
        //print("${ceil.getRect()} NOT DRAWNED");
      }
    });

    ui.Picture picture = recorder.endRecording();


    // Convert picture into an image
    ui.Image output = await picture.toImage(width.toInt(), height.toInt());
    // convert image to byte to store it in file
    var byteData = await output.toByteData(format: ui.ImageByteFormat.png);
    // bytes
    var bytes = Uint8List.sublistView(byteData as ByteData);
    // Popup save file dialog and save the byte to file
    String? filename = await FilePicker.platform.saveFile(
        dialogTitle: "Enter File Name To Export",
        fileName: "output.png",
        bytes: bytes,
        allowedExtensions: ["png"],
        type: FileType.image);
    return filename;
  }

  // Default export image size in terms of height and width
  double exportWidth = 360.0;
  double exportHeight = 200.0;

  // Function to Set Export Size ie 120x120 resolution
  // Use by SavePreview widget
  void setExportSize(double width, double height) {
    setState(() {
      exportWidth = width;
      exportHeight = height;
    });
  }

  // Redraw our grid ceils
  void refreshScreen() {
    setState(() {
      refresh != refresh;
    });
  }

  // Update selected ceils rotation angle based on their existing rotation angle.
  void rotateCeils() {
    setState(() {
      widget.children.forEach((child) {
        if (child.getSelectionState()) child.increaseRotationAngle();
        // Loop Through subceils
        child.subCeils.forEach((ceil) { 
          if (ceil.getSelectionState()) ceil.increaseRotationAngle();
          });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var topWidget = context.findRootAncestorStateOfType<MyHomePageState>();
    int gridSize = topWidget?.getGridSize() as int;
    Color? color = topWidget?.getColor();
    ui.Image? image = topWidget?.getImage();

    // Calculate ratio of editor height and output image height, then calculate editor width
    // and output image width to approximate ceils elevation
    var totalHeight = (MediaQuery.sizeOf(context).height/2);
    var totalWidth = MediaQuery.sizeOf(context).width;
   
    var size = Size(totalWidth, totalHeight / 2);

    // Calculate our canvas background image size if one exists
    if (image != null) {
      var imageHeight = image?.height as int;
      var imageWidth = image?.width as int;

      var sizing = findImageSize(imageWidth.toDouble(), imageHeight.toDouble(),
          totalWidth, totalHeight);
      size = Size(sizing[0], sizing[1]);
  
    }
    // Update our scaling factors
    heightMultiplier = exportHeight / totalHeight;
    heightMultiplier = exportWidth / totalWidth;

    // Available image resolution for export image
    var options = [
      "360.0x200.0",
      "320.0x50.0",
      "1600.0x500.0",
      "800.0x500.0",
      "1280.0x720.0",
      "1920.0x1080.0",
      "1614.0x2047.0"
    ];

    // Include current background image size in the export options
    if (image != null) {
      var width = image?.width.toDouble() as double;
      var height = image?.height.toDouble() as double;
      // Avoid duplicate from the option
      if (!options.contains("${width}x${height}")) {
        options.add("${width}x${height}");
      }
    }

    // Check whether there is any selection in the grid ceils, used by our checkbox
    bool isSelectedAny = selectedCeil != 0 ? true : false;

    return Container(
      decoration: BoxDecoration(color: Color.fromRGBO(37, 37, 50, 1)),
      child: Column(children: [
        SafeArea(
            child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              BackButton(
                  color: Color.fromRGBO(200, 200, 200, 1),
                  onPressed: () {
                    var homePageState =
                        context.findRootAncestorStateOfType<MyHomePageState>();
                    // Move back to the home page screen.
                    homePageState?.onBackButton();
                  }),
              Container(
                  width: 170,
                  height: 50,
                  child: Card(
                      color: Color.fromRGBO(37, 37, 50, 0.7),
                      child: DropDownMultiSelect(
                          hint: Text("Export Size",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white)),
                          selectedValuesStyle: TextStyle(color: Colors.white),
                          separator: "__",
                          onChanged: (List<String> x) {
                            print("$x Always appearing ${x.last}");
                            if (x.length > 0) {
                              // Map of available export size
                              var map = {
                                "360.0x200.0": [360.0, 200.0],
                                "320.0x50.0": [320.0, 50.0],
                                "1600.0x500.0": [1600.0, 500.0],
                                "800.0x500.0": [800.0, 500.0],
                                "1280.0x720.0": [1280.0, 720.0],
                                "1920.0x1080.0": [1920.0, 1080.0],
                                "1614.0x2047.0": [1614.0, 2047.0]
                              };
                              // Include current image size if it is not null in the export size list
                              if (image != null) {
                                var height = image?.height.toDouble() as double;
                                var width = image?.width.toDouble() as double;
                                map["${width}x${height}"] = [width, height];
                              }
                              var index = x.last as String;
                              var values = map[index] as List<double>;
                              print(values);
                              setExportSize(values[0], values[1]);
                            }
                          },
                          options: options,
                          selectedValues: ["${exportWidth}x${exportHeight}"],
                          whenEmpty: "Default Size"))),
              if (selectedCeil != 0)
                Row(children: [
                  Text("Selected $selectedCeil",
                      style: TextStyle(
                          color: Color.fromRGBO(200, 200, 200, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none)),
                  Card(
                      color: Color.fromRGBO(37, 37, 50, 1),
                      child: Checkbox(
                          fillColor: WidgetStatePropertyAll<Color>(
                              Color.fromRGBO(37, 37, 50, 1)),
                          value: isSelectedAny,
                          onChanged: (value) {
                            deSelect();
                          }))
                ])
            ])),
        if (selectedCeil != 0)
          CeilOptions(
              onPressed: () {},
              selectedCeil: selectedCeil,
              setColor: setColor,
              //setImage: setImage,
              removeChild: removeActive,
              splitHorizontal: splitHorizontal,
              splitVertical: splitVertical,
              setElevationHeight: setElevationHeight,
              elevationHeight: elevationHeight,
              setShape: setShape,
              setBorderColor: setBorderColor),
        Expanded(
            child: MainScreen(
                isMerginPossible: isMerginPossible,
                isGridOpened: isGridOpened,
                gridSize: gridSize,
                color: color,
                image: image,
                refreshScreen: refreshScreen,
                addSelectedCeil: addSelectedCeil,
                children: widget.children)),
        ExportImage(
            isGridOpened: isGridOpened,
            setGridState: setGridState,
            onSave: exportImage,
            color: color,
            image: image)
      ]),
    );
  }
}
