import 'package:flutter/material.dart';
import 'package:scab_flutter/screens/intro_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'SourceSansPro',
      ),
      home: IntroScreen(),
    );
  }
}