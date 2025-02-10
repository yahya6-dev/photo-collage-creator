import "dart:io";
import "dart:ui";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "dart:math" as math;
import "package:flutter/widgets.dart";
import "grid_chooser.dart";
import "my_home_page.dart";
import "utils.dart";
import "package:flutter/painting.dart" as painting;
import "package:flutter/painting.dart";
import "dart:ui" as ui;
import "utils.dart";
import "dart:math";

class GridBox extends CustomPainter {
  // Grid box painter create grid a based on the size provided
  GridBox({required this.count, this.color, this.image});

  // size of each grid box
  var count;
  // color user select
  Color? color;
  ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    // screen size height and width
    var screenWidth = size.width - 32;
    var screenHeight = (size.height);
    print(screenWidth);
    print(screenHeight);
    double width = screenWidth / this.count;
    double height = (screenHeight - 16) / this.count;

    // calculate number of rows and columns
    int numberOfRows = this.count;
    int numberOfColumns = this.count;

    var paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(200, 200, 200, 1);
    // paint for first rectangle
    var paint1 = Paint()..color = Color(0x32323cff);
    canvas.save();
    // draw second rectangle
    var paint2 = Paint()..color = Color.fromRGBO(57, 57, 70, 0.9);
    var secondRect = Rect.fromPoints(
        Offset(0, 16), Offset(screenWidth + 32, screenHeight - 16));
    canvas.drawRect(secondRect, paint2);
    canvas.restore();

    var offset = 16;

    var thirdRect = Rect.fromPoints(
        Offset(16, 0), Offset(screenWidth + 16, screenHeight - 16));

    // draw thirdrectangle
    // either as image or solid color
    canvas.save();
    if (color != null && image == null) {
      print("Why Not Drawn! ${color?.red}");
      var paint2 = Paint()
        ..color = color as Color
        ..style = PaintingStyle.fill;
      canvas.drawRect(thirdRect, paint2);
    }

    canvas.restore();

    if (image != null) {
      print("drawned image yes!");
      double? height = image?.height.toDouble();
      double? width = image?.width.toDouble();
      var size = findImageSize(
          width as double, height as double, screenWidth, screenHeight);
      //print("$size $screenWidth $screenHeight => $width $height oke");
      canvas.drawImageRect(
          image as ui.Image,
          Rect.fromPoints(
              Offset(0, 0),
              Offset(image?.width.toDouble() as double,
                  image?.height.toDouble() as double)),
          Rect.fromPoints(
              Offset(16, 0), Offset(screenWidth + 16, screenHeight - 16)),
          paint);
    }

    for (var row = 0; row <= numberOfRows; row++) {
      for (var col = 0; col <= numberOfColumns; col++) {
        Offset startingOffsets;

        startingOffsets = Offset((col * width) + offset, (height * row));
        // Rectangle size
        var rect =
            Rect.fromPoints(startingOffsets, Offset(width + offset, height));
        // draw Rectangle
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(canvas) => false;
}

class GridBoxWidget extends StatefulWidget {
  GridBoxWidget({required this.onPressed, required this.onBack});
  // move to the grid type selection screen
  void Function() onPressed;
  // move back to color screen
  void Function() onBack;
  @override
  State<GridBoxWidget> createState() => GridBoxWidgetState();
}

class GridBoxWidgetState extends State<GridBoxWidget> {
  String selectedKey = "two";
  Color? color;
  String? path;
  ui.Image? image;

  void setActive(String key) {
    setState(() {
      selectedKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    var parentWidget = context.findRootAncestorStateOfType<MyHomePageState>();
    print(parentWidget?.getImagePath());

    var gridSize = 4;
    color = parentWidget?.getColor();
    image = parentWidget?.getImage();
    //print("$color What?");
    // Determine which grid type the user selects.
    switch (selectedKey) {
      case "one":
        gridSize = 3;
        break;
      case "two":
        gridSize = 4;
        break;
      case "three":
        gridSize = 6;
        break;
      default:
        gridSize = 4;
    }
    // Inform my home page about selected grid
    parentWidget?.setGridSize(gridSize);
    // Two buttons 'continue' and 'back' 
    var buttons = Container(
        margin: EdgeInsets.all(8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ElevatedButton(
              onPressed: () {
                image = null;
                color = null;
                widget.onBack();
              },
              child: Text("Back",
                  style: TextStyle(color: Color.fromRGBO(0, 10, 60, 1)))),
          ElevatedButton(
            onPressed: widget.onPressed,
            child: Text("Continue", style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(
                  Color.fromRGBO(0, 100, 250, 0.9)),
            ),
          )
        ]));

    // Device screen width to draw our gridded preview screen
    var width = MediaQuery.sizeOf(context).width-64;

    // Device screen height divide by 2
    var height = MediaQuery.sizeOf(context).height / 2;

    // Size of our custom painter
    var size = Size(width, height);
    print("$color as perceived $color");

    return Card(
        color: Color.fromRGBO(50, 50, 60, 0.9),
        margin: EdgeInsets.all(8),
        child: Column(children: [
          CustomPaint(
              size: size,
              painter: GridBox(count: gridSize, color: color, image: image)),
          GridChooser(selectedKey: selectedKey, onPressed: setActive),
          buttons
        ]));
  }
}
