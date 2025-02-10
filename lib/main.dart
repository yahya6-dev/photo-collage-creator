import 'package:flutter/material.dart';
import "components/components.dart";
import "package:flutter/services.dart";

void main() {
  // Set Our App Only in Portrait Mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // main function where app get called
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  // Our Top level widget  that wrap our application
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        title: "Custom",
        theme: ThemeData(useMaterial3: true),
        home: MyHomePage());
  }
}
