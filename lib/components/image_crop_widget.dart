import "package:flutter/material.dart";
import "dart:ui" as ui;
import "option_item.dart";
import "dart:io";
import "utils.dart";
import "dart:ui";

class MyPainter extends CustomPainter {
  MyPainter(
      {required this.image, required this.rect, required this.drawingRect});

  // Selected image to use as filling
  ui.Image image;
  // Cropping selection rectangle
  Rect rect;
  // Drawing rect, representing our complete canvas rect
  Rect drawingRect;

  @override
  void paint(Canvas canvas, Size size) {
    var imageHeight = image.height.toDouble();
    var imageWidth = image.width.toDouble();

    // Clip the path, so that anything drawned outside our drawingRect is not showned.
    var path = Path();
    path.addRect(drawingRect);
    path.close();
    canvas.clipPath(path);

    // Top left anchor use for scaling our selection rect
    var x1 = rect.left + rect.width / 2;
    var y1 = rect.top;

    // Left anchor use for scaling our selection rect
    var y2 = rect.top + rect.height / 2;
    var x2 = rect.left;

    // Right anchor use for scaling our selection rect
    var y3 = rect.top + rect.height / 2;
    var x3 = rect.left + rect.width;

    // Bottom anchor use for scaling our selection rect
    var y4 = rect.top + rect.height;
    var x4 = rect.left + rect.width / 2;

    // Offset for lines that crisscross the rectangle;
    var x5 = rect.left + rect.width / 2;
    var y5 = rect.top;
    var x6 = rect.left + rect.width / 2;
    var y6 = rect.top + rect.height;

    // The second line offset
    var x7 = rect.left;
    var y7 = rect.top + rect.height / 2;
    var x8 = rect.left + rect.width;
    var y8 = rect.top + rect.height / 2;

    // Draw the image
    var paint = Paint()..color = Color.fromRGBO(250, 250, 250, 0.8);
    canvas.drawImageRect(image, Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        drawingRect, paint);

    // Draw the rectangle, for cropping our image
    var paint1 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect, paint1);

    // Draw lines that criss cross the the rectangle
    canvas.drawLine(Offset(x5, y5), Offset(x6, y6), paint1);
    canvas.drawLine(Offset(x7, y7), Offset(x8, y8), paint1);

    // Draw the top handle
    var paint2 = Paint()..color = Colors.white;
    var handleTopOffset = Offset(x1, y1);
    canvas.drawCircle(handleTopOffset, 15.0, paint2);

    // Draw the left handle
    var handleLeftOffset = Offset(x2, y2);
    canvas.drawCircle(handleLeftOffset, 15.0, paint2);

    // Draw the right handle
    var handleRightOffset = Offset(x3, y3);
    canvas.drawCircle(handleRightOffset, 15.0, paint2);

    // Draw the bottom handle
    var handleBottomOffset = Offset(x4, y4);
    canvas.drawCircle(handleBottomOffset, 15.0, paint2);
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}

class ImageCropWidget extends StatefulWidget {
  // Path to the selected image to be loaded
  String imagePath;
  final void Function(ui.Picture, int, int) setImageFilling;

  // We load the image from here
  ImageCropWidget({required this.imagePath, required this.setImageFilling}) {
    print("Is this always beeing called!");
  }

  @override
  State<ImageCropWidget> createState() => _ImageCropWidgetState();
}

class _ImageCropWidgetState extends State<ImageCropWidget> {
  // Selected Image to be loaded
  ui.Image? image;

  // Rectangle size for selecting section to be cropped
  double x = 10;
  double y = 10;
  double width = 0;
  double height = 0;

  // Detect which handle is pressed ie left,right,bottom,top.
  var handle = "";

  // Offset from where to start moving or increase the rect
  var origin = Offset(0.0, 0.0);
  var sizing = [0.0, 0.0];

  // This function load the selected image asynchrously afterward, it update the State
  // to let this widget know
  Future<void> loadImage() async {
    // Read the image from the widget.imagePath as bytes
    var file = File(widget.imagePath);
    var data = await file.readAsBytes();

    ui.decodeImageFromList(data, (img) {
      // Update state
      setState(() {
        image = img;
      });
    });
  }

  // When this state created load our image
  @override
  void initState() {
    loadImage();
  }

  @override
  Widget build(BuildContext context) {
    // Widget representing Ok and Back on the top of our dialog
    var topWidget =
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      // Dismiss the dialog

      BackButton(
          color: Color.fromRGBO(200, 200, 200, 1),
          // Close this widget and return back main menu
          onPressed: () {
            Navigator.of(context).pop();
          }),

      // Dismiss and apply the operation
      image == null
          ? Text("")
          : ElevatedButton(
              child: Text("Apply",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                    Color.fromRGBO(0, 100, 250, 0.9)),
              ),

              onPressed: () {
                // Canvas Drawing area
                var drawingRect = Rect.fromLTWH(0, 0, sizing[0], sizing[1]);

                // Create instance of picture recorder for recording graphic command
                // on canvas
                ui.PictureRecorder recorder = ui.PictureRecorder();
                Canvas canvas = Canvas(recorder, drawingRect);

                // Draw graphics in the canvas excluding cropping rectangle
                // Draw the image
                var paint = Paint()..color = Color.fromRGBO(250, 250, 250, 1);
                var copiedImage = image as ui.Image;
                canvas.drawImageRect(
                    copiedImage,
                    Rect.fromLTWH(0, 0, copiedImage.width.toDouble(),
                        copiedImage.height.toDouble()),
                    drawingRect,
                    paint);

                // Draw a path and use it to clip the image only around the cropping rectangle
                var path = Path();
                path.addRect(Rect.fromLTWH(x, y, width, height));
                path.close();
                canvas.clipPath(path);
                Picture picture = recorder.endRecording();

                // Set the picture to the active child
                widget.setImageFilling(picture, width.toInt(), height.toInt());

                // Call respective operation
                // then dismiss the dialog
                Navigator.of(context).pop();
              })
    ]);

    // This widget show progressbar if the image is in the course of loading
    var progressBar = Center(
        child: Container(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
                color: Color.fromRGBO(35, 35, 35, 1))));

    // The image still is loading
    if (image == null) {
      return Column(children: [topWidget, progressBar]);
    }

    // The image loaded successfully
    else {
      // Get screen size to resize the picture correctly
      var screenWidth = (MediaQuery.sizeOf(context).width);
      var screenHeight = MediaQuery.sizeOf(context).height;

      // Find apropriate size to draw the image
      sizing = [
        image?.width.toDouble() as double,
        image?.height.toDouble() as double
      ];

      // If the loaded image is less than our screenwidth, we show it in fullscreen width
      if (image?.width.toDouble() as double > screenWidth) {
        sizing[0] = screenWidth;
      }
      // We draw it 3/4 of our screen width 
      else if ((image?.width.toDouble() as double) - 300 < screenWidth) {
        sizing[0] = (screenWidth / 4) * 3;
      }

      // if Image loaded is greater than our screen height, we set its height as 3/4 of our screen height 
      if (image?.height.toDouble() as double > screenHeight) {
        sizing[1] = (screenHeight / 4) * 3;
      }
      // We draw it  2/4 of our screen height 
      else if ((image?.height.toDouble() as double) - 300 < screenHeight) {
        sizing[1] = (screenHeight / 4) * 2;
      }

      // Check width and height of our selection rectangle as initially is set to zero
      // before image loading.
      if (width == 0) {
        width = sizing[0] - 20;
      }

      if (height == 0) {
        height = sizing[1] - 20;
      }

      // Cropping selection rectangle always clamp y by imageWidth-width and imageHeight-height
      // so that the rectangle don't leave its boundary
      try {
          x=x.clamp(0.0, sizing[0] - width);
          y=y.clamp(0.0, sizing[1] - height);
          width=width.clamp(0.0, sizing[0]-10);
          height=height.clamp(0.0, sizing[1]-20);

      }
      catch(e) {
        print("$e Occured");
      }
      // Cropping image rectangle
      Rect rect = Rect.fromLTWH(x,y,width,height);

      // Our canvas size
      var size = Size(sizing[0], sizing[1]);
      // When we tap the screen determine what to do, rescaling the cropping rectangle or moving it
      void onPointerDown(event) {
        var direction = "";
        origin = event.localPosition;
        // Top Handle Offset
        var x1 = rect.left + rect.width / 2;
        var y1 = rect.top;
        var rect1 = Rect.fromLTWH(x1, y1, 15, 15);

        // Left Handle Offset
        var x2 = rect.left;
        var y2 = rect.top + rect.height / 2;
        var rect2 = Rect.fromLTWH(x2, y2, 15, 15);

        // Right Handle Offset
        var x3 = rect.left + rect.width;
        var y3 = rect.top + rect.height / 2;
        var rect3 = Rect.fromLTWH(x3, y3, 15, 15);

        // Bottom Handle Offset
        var x4 = rect.left + rect.width / 2;
        var y4 = rect.top + rect.height;
        var rect4 = Rect.fromLTWH(x4, y4, 15, 15);

        // Check whether is top, increase the reactivity, to make more sensitive
        if (rect1.inflate(10.0).contains(event.localPosition)) {
          direction = "top";
        }

        // Check whether is left, increase the reactivity, to make more sensitive
        if (rect2.inflate(10.0).contains(event.localPosition)) {
          direction = "left";
        }

        // Check whether is right, increase the reactivity, to make more sensitive
        if (rect3.inflate(10.0).contains(event.localPosition)) {
          direction = "right";
        }
        // Check whether is bottom, increase the reactivity, to make more sensitive
        if (rect4.inflate(10.0).contains(event.localPosition)) {
          direction = "bottom";
        }

        // We move the rectangle instead of rescaling it.
        if (direction == "") {
          if (rect.contains(event.localPosition)) {
            direction = "any";
          }
        }

        setState(() {
          handle = direction;
        });
      }

      ;

      return Column(children: [
        topWidget,
        Padding(
            padding: EdgeInsets.all(4),
            child: Text("Crop Image",
                style: TextStyle(
                    color: Color.fromRGBO(220, 220, 220, 1), fontSize: 20))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Listener(
              onPointerDown: onPointerDown,
              onPointerMove: (event) {
                
                var origin0 = event.original?.localPosition;

                if (origin0 == null) {
                  origin0 = origin;
                }


                if (origin != null) {
                  if ((handle == "top") || (handle == "bottom")) {
                    // Detect whether to increase or decrease the rect
                    //var diffOffset = event.localPosition.dy - origin0.dy;
                      // We increase y by event.delta.dy since moving up our dy is negative and down it is positive
                      if (handle == "top") {
                        y += event.delta.dy;
                          height -= event.delta.dy;
                      }

                      // We increase or decrease height 
                      if (handle == "bottom") {
                          height += event.delta.dy;
                       
                      }
                     
                    }

                  // Case 2 if user use right or left handle
                  else if ((handle == "left") || (handle == "right")) {
                    //var diff = event.localPosition.dx - origin.dx;
                      // Clamp Our x not be less than 1.0
                      if (handle == "left") {
                        if ( (x + event.delta.dx ) > 1.0)
                           x += event.delta.dx;

                        // Clamp our width not be less than 10.0
                        if ( (width - event.delta.dx) > 10 )
                          width -= event.delta.dx;
                      }

                      // Case two for right button
                      if (handle == "right") {
                        if ( (width + event.delta.dx) < sizing[0])
                          width += event.delta.dx;
                      }
                    }

                  // Case  where handle is any, move our rectangle
                  else if (handle == "any") {
                    var diffX = event.localPosition.dx - origin.dx;
                    // Case user move left or right
                    if (diffX < 0) {
                      x += event.delta.dx;

                    } else if (diffX > 0) {
                      x += event.delta.dx;
                    }

                    var diff = event.localPosition.dy - origin.dy;

                    // case if user move top or bottom
                    if (diff > 0) {
                      y += event.delta.dy;
                      
                    }

                    if (diff < 0) {
                      y += event.delta.dy;
                    }
                  }
                }

                // Case where this is the first move origin is null
                else if (origin == null) {
                  if (handle == "top") {
                    y -= 1;
                  } else if (handle == "bottom") {
                    height -= 1;
                  } else if (handle == "left") {
                    x -= 1;
                  } else if (handle == "right") {
                    width -= 1;
                  }
                }

                setState(() {
                  //print("Inform the parent $handle");
                });
              },
              // Canvas Painter
              child: CustomPaint(
                  size: size,
                  painter: MyPainter(
                      image: image as ui.Image,
                      rect: rect,
                      drawingRect: Rect.fromLTWH(0, 0, sizing[0], sizing[1]))))
        ])
      ]);
    }
  }
}
