import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'color_chooser.dart';
import 'my_home_page.dart';
import "utils.dart";

class BackgroundImageSelector extends StatefulWidget {
  BackgroundImageSelector({required this.onPressed});
  // This widget render the User Interface for selecting
  // image from the file system and load it by calling `MyHomePageState.setImagePath`.
  // It expect a single argument to be passed of type Function, that is used to move to the next stepper page
  // after selection of an image or solid color.
  final void Function() onPressed;

  @override
  State<BackgroundImageSelector> createState() =>
      BackgroundImageSelectorState();
}

class BackgroundImageSelectorState extends State<BackgroundImageSelector> {
  // This variable holds reference to the selected Image to use as grid background image
  Image? selectedBackgroundImage;

  BackgroundImageSelectorState();
  // This variable holds reference to the grid selected background color
  Color? selectedBackgroundColor;

  // Set the  grid background color and reset grid image background by setting it to `null`
  void setBackgroundColor(Color? color) {
    selectedBackgroundColor = color;
    // Store at the  top parent "MyHomepage"
    var parentWidget = context.findRootAncestorStateOfType<MyHomePageState>();
    parentWidget?.setColor(color);
    parentWidget?.setImagePath(null);
  }

  @override
  Widget build(BuildContext context) {
    var parentWidget = context.findRootAncestorStateOfType<MyHomePageState>();

    // Test if image path is set, then calculate apropriate image size based on the Device available screen size
    if (parentWidget?.getImagePath() != null) {
      // Calculate the apropriate image dimension
      var screenWidth = MediaQuery.sizeOf(context).width-32;
      var screenHeight = MediaQuery.sizeOf(context).height / 2;
      var size = parentWidget?.getImageSize() as List<double>;
      // Estimate the apropriate size with minimum aspect ration loss
      var sizing = findImageSize(size[0],size[1],screenWidth,screenHeight);
      
      var file = File(parentWidget?.getImagePath() as String);
      // Resize our image
      selectedBackgroundImage = Image.file(file,width:sizing[0],height:sizing[1]);
    }


    return Card(
      color: Color.fromRGBO(57, 57, 70, 0.9),
      margin: EdgeInsets.all(16),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,

          // We test here if user select an image to use as background image
          // we show a preview of it,
          // In case he didn't we show a widget for selecting color that is when `selectedBackgroundImage == null`
          // We show both image selection widget and color selection widget
          children: [
            // The user select an image and it is loaded
            if (selectedBackgroundImage != null)
               Expanded(child:selectedBackgroundImage as Image),

            if (selectedBackgroundImage == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ListTile(
                    leading: Icon(Icons.image,
                        color: Color.fromRGBO(200, 200, 200, 1)),
                    title: Text("Choose Background Image",
                        style: TextStyle(color: Colors.white, fontSize: 16))),
              ),

            // The user does not select an image, we show image icon, that when tapped take you filesytem 
            // for image selection
            if (selectedBackgroundImage == null)
              IconButton(
                // Load file from the filesystem to use as
                // grid background image when press this widget
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                          type: FileType.custom,
                          allowMultiple: false,
                          allowedExtensions: ["png", "jpg", "jpeg"]);

                  // if result != null user select an image
                  // we save a reference of it in the Toplevel
                  // widget MyHomePage by calling topWidget?.setImagePath.
                  if (result != null) {
                    String path = result.files.single.path as String;
                    var file = File(path);

                    // Notify this widget that an image
                    // is selected.
                    parentWidget?.setImagePath(path as String);
                  }
                },
                icon: Icon(
                  Icons.upload_file,
                ),
                color: Colors.white,
                iconSize: 48,
              ),
            SizedBox(height: 8.0),

            // We hide 'Or' Text if selectedBackgroundImage
            // is not null.
            if (selectedBackgroundImage == null)
              Text("Or",
                  style: TextStyle(
                      color: Color.fromRGBO(200, 200, 200, 1), fontSize: 20)),

            // We hide ColorChooser widget  if selectedBackgroundImage
            // is not null.
            if (selectedBackgroundImage == null) ColorChooser(),

            // If user choose an  image or solid color
            // we show next button to move to the next screen or cancel to reselect again.
            if (selectedBackgroundImage != null ||
                selectedBackgroundColor != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: selectedBackgroundImage != null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  children: [
                    if (selectedBackgroundImage != null)
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Reset selected image to null
                              // user select cancel button
                              selectedBackgroundImage = null;
                              selectedBackgroundColor = null;
                              parentWidget?.setImagePath(null);
                            });
                          },
                          child: Text("Cancel",
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 10, 50, 1)))),
                    ElevatedButton(
                        onPressed: () {
                          // Move to the next Screen within flutter_page_stepper
                          widget.onPressed();
                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll<Color>(
                                Color.fromRGBO(0, 100, 250, 1))),
                        child: Text("Next",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)))
                  ],
                ),
              )
          ]),
    );
  }
}
