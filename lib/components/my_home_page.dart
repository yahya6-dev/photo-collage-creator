import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_collage_creator/components/grid_type.dart';
import 'package:photo_collage_creator/components/top_widget.dart';
import 'grid_editor.dart';
import "dart:ui" as ui;

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // This App consist of three states:
  // color `If user choose to fill the grid background color with solid color`
  // gridSize `This identify the number of columns and rows of the grid`
  // imagePath `This is the path to the image selected to use as our canvas background`
  // image `This is the image  corresponding to the image at imagePath`
  Color? color;
  String? imagePath;
  int gridSize = 4;
  ui.Image? image;

  // State variable for navigating  between pages
  // page 0 is the first page; page 1 is the second page,
  // page 2 is the screen, for creating the actual grid.
  var pageNumber = 0;

  // LoadImage path is called once user selected choose an image to use
  //  as grid background color, we know that onece imagePath != null,
  //  we schedule theloading of  image asynchronously, and rerender the whole app
  void loadImage() {
    if (imagePath != null) {
      var data = File(imagePath as String).readAsBytesSync();
      ui.decodeImageFromList(data, (ui.Image img) {
        setState(() {
          image = img;
        });
      });
    }
  }

  // An interface for retrieving grid background image, used by descendent of this widget
  ui.Image? getImage() {
    return image;
  }

  // An interface to get color used by descendent of this widget
  Color? getColor() {
    return color;
  }

  // An interface to get image path
  String? getImagePath() {
    return imagePath;
  }

  // An  Interface to retrieve grid size
  int getGridSize() {
    return gridSize;
  }

  // An interface to get the loaded image size use by backgroundImageSelector for
  // displaying image of apropriate size
  List<double> getImageSize() {
    if (image != null) {
      var height = image?.height as int;
      var width = image?.width as int;
      return [width.toDouble(), height.toDouble()];
    }
    return [0, 0];
  }

  // An Interface to modify the color, that is selected by user
  // to use as grid background color
  void setColor(Color? color) {
    setState(() {
      this.color = color;
    });
  }

  // An interface to modify imagePath, once image path change
  // we load the recent selected image, to use as canvas background image,
  // if it is pass null as argument, it is indicating that the user, decided to
  // use solid color as grid background color
  void setImagePath(String? path) {
    if (path != null) {
      setState(() {
        imagePath = path;
        loadImage();
      });
    } else {
      setState(() {
        imagePath = null;
        image = null;
      });
    }
  }

  // An interface to modify gridSize
  void setGridSize(int gridSize) {
    this.gridSize = gridSize;
  }

  // An interface to move back to first page, used by the descendent of this widget to move back
  void onBackButton() {
    // Navigate to the initial page
    if (pageNumber == 1) {
      setState(() {
        pageNumber = 0;
        // Reset imagePath and image to null
        imagePath = null;
        image = null;

      });
    }

    // Navigate to the second page of color/image selection as background
    else if (pageNumber == 2) {
      setState(() {
        pageNumber = 1;
      });
    }
  }

  // An interface to move to grid image editor page
  void onPressedCreate() {
    setState(() {
      pageNumber = 2;
    });
  }

  // An interface to move to the next page from first page, for selection
  // of background color or image background
  void onPressed() {
    setState(() {
      pageNumber = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If pageNumber equal 2 we know that the user chose a color background or image background
    // and he pressed next, return the Editing Screen
    if (pageNumber == 2) return Scaffold(body:GridEditor(gridSize: gridSize));

    // pageNumber == 1 the user is in grid type chooser and color widget
    // we render GridType Widget.
    if (pageNumber == 1) {
      return GridType(onNextScreen: onPressedCreate);
    }

    // Else we render the first screen
    else {
      return Container(
          decoration: BoxDecoration(color: Color.fromRGBO(57, 57, 70, 1)),
          child: TopWidget(onPressed: onPressed));
    }
  }
}
