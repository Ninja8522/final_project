import 'package:final_project/final_project/final_project.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.redAccent[700],
          accentColor: Colors.pinkAccent[700],
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Theme.of(context).primaryColor)),
      home: FinalProjectPage(),
    );
  }
}
