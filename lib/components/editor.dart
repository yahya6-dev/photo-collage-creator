import "package:flutter/material.dart";
import "ceil.dart";
import "dart:ui" as ui;
import "utils.dart";

class Editor extends CustomPainter {
  // This Class draw our canvas with our grid ceil represented as Ceil class, each having its
  // attribute such as color and image filling etc.
  Editor(
      {required this.children,
      required this.gridSize,
      required this.shouldPaint,
      required this.isGridOpened,
      this.color,
      this.image});

  // Dictate whether to show or hide grid line
  bool isGridOpened;
  // Our grid ceil
  var children = <Ceil>[];
  // size of our grid ie 4x4 or 3x3
  int gridSize;
  // background image of our canvas
  ui.Image? image;
  // background color of our canvas if giving
  Color? color;
  bool shouldPaint;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw filling either image or solid color
    var height = size.height;
    var width = size.width;
    var ceilWidth = width / gridSize;
    var ceilHeight = height / gridSize;
    // Clip anything that goes outside the allotted space
    var boundaryPath = Path();
    boundaryPath.addRect(Rect.fromLTWH(0,0,width,height));
    canvas.clipPath(boundaryPath);

    if (color != null) {
      canvas.save();
      var paint = Paint()..color = color as Color;
      // screen rect size
      var rect = Rect.fromLTWH(0, 0, width, height);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }

    // Draw Our Background Image
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

    var childrenPosition = <List<double>>[];
    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        List<double> startingOffsets;
        startingOffsets = [
          (col * ceilWidth),
          (ceilHeight * row),
          ceilWidth,
          ceilHeight
        ];
        // Rectangle size of our grid ceils
        childrenPosition.add(startingOffsets);
      }
    }

    for (int pos = 0; pos < childrenPosition.length; ++pos) {
      canvas.save();
      List<double> position = childrenPosition[pos];
      var x = position[0];
      var y = position[1];
      var width = position[2];
      var height = position[3];
      // Dont assign position and size to an already drawned ceil
      if (!children[pos].isDrawned) { 
        children[pos].setRect(x, y, width, height);
        children[pos].setIsDrawned(true);
        children[pos].id = pos;
        }
      // Draw Ceil in our canvas
      children[pos].drawItem(canvas,isGridOpened);
      canvas.restore();  
    }


  }

  @override
  bool shouldRepaint(Editor oldDelegate) => shouldPaint;
}
    