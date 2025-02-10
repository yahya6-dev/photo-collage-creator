import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import "dart:ui" as ui;

class ExportImage extends StatefulWidget {
  ExportImage({required this.isGridOpened, required this.setGridState,required this.onSave,this.image,this.color});
  // Background Filling of the canvas either image or color, used to drawing export image
  Color? color;
  // Image Background Of our canvas if any is selected, used to drawing export image 
  ui.Image? image;
  // This function is called to popup filename picker and save our collage to filesystem
  Future<String?> Function(Color?, ui.Image?) onSave;
  // Set Whether grid lines are showned or not
  void Function(bool value) setGridState;
  // State Variable that indicate whether gridlines are showned or not
  bool isGridOpened;

  @override
  State<ExportImage> createState() => _ExportImageState();
}

class _ExportImageState extends State<ExportImage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Card(
              color: Color.fromRGBO(37, 37, 50, 1),
              child:Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(children: [
                  Text("Turn Off Gridlines",
                    style: TextStyle(color: Color.fromRGBO(230, 230, 230, 1), fontSize: 12 )),
                Checkbox(
                    fillColor: WidgetStatePropertyAll<Color>(
                        Color.fromRGBO(37, 37, 50, 1)),
                    value: widget.isGridOpened,
                    onChanged: (value)  {
                      // Change grid lines state
                      widget.setGridState(value as bool);
                    })
              ]))),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                      Color.fromRGBO(0, 100, 250, 1))),
              child: Text("Export", style: TextStyle(color: Colors.white)),
              onPressed: () async {        
                  String? filename = await widget.onSave(widget.color,widget.image);
                  // If filename != null, we know user enter export name, we show a notification here
                  if (filename != null) {
                        ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Card(
                          color:Color.fromRGBO(37,37,50,1),
                          child:Padding(
                           padding: EdgeInsets.all(8.0),
                           child:Text("Exported Successfully",
                           style: TextStyle(color:Colors.white)
                          )))));
                      }
                      }),
        ]));
  }
}
