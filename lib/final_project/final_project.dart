import 'dart:convert';

import 'package:final_project/database_helper.dart';
import 'package:final_project/final_project/final_project_form_page.dart';
import 'package:final_project/methods/public.dart';
import 'package:final_project/models_objects/task.dart';
import 'package:final_project/uris.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class FinalProjectPage extends StatefulWidget {
  @override
  _FinalProjectPageState createState() => _FinalProjectPageState();
}

class _FinalProjectPageState extends State<FinalProjectPage> {
  List<Foods>? _list;

  AppBar _appBar() {
    return AppBar(title: Text("Final Project"));
  }

  Widget _body() {
    if (_list == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (_list!.isEmpty) {
      return Center(
        child: Text("No Data"),
      );
    }
    return ListView(
        children: _list!.map((food) => Text("${food.name}")).toList());
  }

  Widget _fabGoToForm() {
    return FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(
                MaterialPageRoute(builder: (context) => FinalProjectFormPage()))
            .whenComplete(() => _readDataFromDB()),
        label: Text("Add Food"),
        icon: Icon(Icons.food_bank));
  }

  @override
  void initState() {
    _readDataFromDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: _fabGoToForm(),
    );
  }

  void _readDataFromDB() async {
    final Database? db = await DatabaseHelper.db.database;
    List<dynamic>? results = await db!.query("food");
    if (results == null || results!.isEmpty) return null;
    _list = results.map((result) => Foods.fromMapSQL(result)).toList();
  }

  void _loadDataFromServer() async {
    try {
      http.Response _response = await http.get(Uri.parse(Uris().foodApi),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 20));
      if (_response.statusCode == 200) {
        _list = await json.decode(utf8.decode(_response.bodyBytes));
        setState(() {});
      }
    } catch (error) {
      snackMessage(
          message: "${error.toString()}", context: context, isError: true);
    }
  }
}
