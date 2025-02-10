import "package:flutter/material.dart";
import "option_item.dart";
import "ceil_options.dart";
import "grid_editor.dart";

class GrowOptions extends StatefulWidget {
  GrowOptions({required this.setSelectedTool,
   required this.setElevationHeight,required this.elevationHeight});
  var selectedTool = "";
  // Move to the previous menu
  void Function(String) setSelectedTool;
  // Set selected elevation
  void Function(double) setElevationHeight;

  // Selected ceil's elevation used by our slider control
  double elevationHeight;

  @override
  State<GrowOptions> createState() => GrowOptionsState();
}

class GrowOptionsState extends State<GrowOptions> {
  double elevationHeight = 0;

  @override
  Widget build(BuildContext context) {
    var topWidget = context.findRootAncestorStateOfType<CeilOptionsState>();
    var gridEditor = context.findRootAncestorStateOfType<GridEditorState>();
   // TODO: implement build
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BackButton(
              color: Color.fromRGBO(200, 200, 200, 1),
              onPressed: () {
                gridEditor?.resetElevationHeight(0);
                // Move to the previous menu
                widget.setSelectedTool("Edit");
              }),
          Text("Grow Ceil",
              style: TextStyle(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  fontSize: 12,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w100)),
        ],
      ),
      Row(children: [
        Column(
          children:[
          Card(
          color: Color.fromRGBO(37,37,50,1),
          child: Slider(
            secondaryActiveColor: Color.fromRGBO(37, 37, 50, 1),
            value: widget.elevationHeight,
            onChanged: (value) {
                // Update selected ceil elevationHeight
                gridEditor?.setElevationHeight(value);
              
              
            },
            label: "Grow",
            min:0,
            max:32,
            activeColor: Color.fromRGBO(37, 37, 50, 1),
            thumbColor: Color.fromRGBO(0, 100, 250, 1),
            overlayColor:
                WidgetStatePropertyAll<Color>(Color.fromRGBO(37, 37, 50, 1)),
          ),
        ),  Text("Grow",style: TextStyle(color:Color.fromRGBO(230,230,230,1),fontSize:12,decoration:TextDecoration.none,fontWeight:FontWeight.w100)),
      ]
    )
  ])
    ]);
  }
}
