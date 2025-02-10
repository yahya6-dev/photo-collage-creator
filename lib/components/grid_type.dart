import 'package:flutter/material.dart';
import 'package:flutter_page_stepper/flutter_page_stepper.dart';
import 'background_image_selector.dart';
import 'my_home_page.dart';
import "grid_box.dart";

class GridType extends StatefulWidget {
  GridType({required this.onNextScreen});
  final void Function() onNextScreen;
  @override
  State<GridType> createState() => _GridTypeState();
}

class _GridTypeState extends State<GridType> {
  bool refreshScreen = false;
  // Back button icon to move to the first page
  final IconData backIcon = Icons.arrow_back;

  // initial page default to currentPageStepper = 0
  // that is displayed by the flutter_page_stepper.
  var currentStepperpage = 0;

  // This function is called by the next button to move to the
  // next page within the page stepper.
  void onPressedNext() {
    setState(() {
      currentStepperpage = 1;
    });
  }

  // Navigate back to color or image selection screen
  void onBack() {
    setState(() {
      currentStepperpage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(50, 50, 60, 0.9),
        body: SafeArea(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(
                    color: Color.fromRGBO(200, 200, 200, 1),
                    onPressed: () {
                      var homePageState = context
                          .findRootAncestorStateOfType<MyHomePageState>();
                      // move back to the home page screen.
                      homePageState?.onBackButton();
                    }),
                //SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Choose Grid Type & Background Image",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ]),
                Expanded(
                  child: FlutterPageStepper(
                      indicatorSize: 48,
                      dividerWidth: 100,
                      textStyle: TextStyle(
                          color: Color.fromRGBO(0, 10, 60, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      stepperLength: 2,
                      activeColor: Color.fromRGBO(250, 250, 250, 1),
                      currentIndex: currentStepperpage,
                      children: [
                        BackgroundImageSelector(onPressed: onPressedNext),
                        GridBoxWidget(
                            onPressed: widget.onNextScreen, onBack: onBack)
                      ]),
                )
              ]),
        ));
  }
}
