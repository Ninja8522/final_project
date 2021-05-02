// import 'dart:convert';

import 'dart:convert';

import 'package:final_project/database_helper.dart';
import 'package:final_project/methods/public.dart';
import 'package:final_project/models_objects/task.dart';
import 'package:final_project/uris.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class FinalProjectFormPage extends StatefulWidget {
  @override
  _FinalProjectFormPageState createState() => _FinalProjectFormPageState();
}

class _FinalProjectFormPageState extends State<FinalProjectFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name = "";
  String _calories = "";

  AppBar _appBar() {
    return AppBar(title: Text("Final Project Form"));
  }

  Widget _inputName() {
    return Container(
      child: TextFormField(
        keyboardType: TextInputType.name,
        onSaved: (val) => _name = val ?? "",
        style: TextStyle(fontWeight: FontWeight.bold),
        validator: (val) =>
            (val != null && val.isNotEmpty) ? null : "Issue in Name",
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: Icon(Icons.person),
            labelText: "Name",
            hintText: "Enter ur Name"),
      ),
    );
  }

  Widget _inputCalories() {
    return Container(
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onSaved: (val) => _calories = val ?? "",
        style: TextStyle(fontWeight: FontWeight.bold),
        validator: (val) =>
            (val != null && val.isNotEmpty && double.tryParse(val) != null)
                ? null
                : "Issue in Calories",
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: Icon(Icons.person),
            labelText: "Calories",
            hintText: "Enter a Calories"),
      ),
    );
  }

  Widget _formPage() {
    return Form(
        key: _formKey,
        child: Column(children: [_inputName(), _inputCalories()]));
  }

  Widget _fabSaveDataOnLocal() {
    return FloatingActionButton.extended(
        onPressed: _saveDataLocal,
        label: Text("Save Data Local"),
        icon: Icon(Icons.save_rounded));
  }

  /* Widget _fabSaveDataOnServer() {
    return FloatingActionButton.extended(
        onPressed: _saveDataServer,
        label: Text("Save Data On Server"),
        icon: Icon(Icons.save_outlined));
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _formPage(),
      floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
        _fabSaveDataOnLocal(),
        SizedBox(height: 15),
        //_fabSaveDataOnServer()
      ]),
    );
  }

  void _saveDataLocal() async {
    final FormState? _formState = _formKey.currentState;
    if (_formState != null && _formState.validate()) {
      //IS Valid
      _formState.save();
      try {
        Foods _food = Foods(
            idLocal: await _getValidID(),
            idServer: null,
            name: _name,
            calories: double.tryParse(_calories));
        await _insertDataToDB(_food);
        snackMessage(message: "Saved :D", context: context);
        Navigator.of(context).pop();
      } catch (error) {
        snackMessage(
            message: "${error.toString()}", context: context, isError: true);
      }
    } else {
      //IS not Valid
      snackMessage(
          message: "Issiue Inside the Form", context: context, isError: true);
    }
  }

  void _saveDataServer() async {
    final FormState? _formStateServer = _formKey.currentState;
    if (_formStateServer != null && _formStateServer.validate()) {
      //IS Valid
      _formStateServer.save();
      try {
        Map<String, dynamic> _jsonFood = {
          "name": _name,
          "calories": double.tryParse(_calories)
        };

        http.Response _response = await http.post(Uri.parse(Uris().foodApi),
            body: json.encode(_jsonFood),
            headers: {"Content-Type": "application/json"},
            encoding: Encoding.getByName("utf-8"));

        if (_response.statusCode == 201) {
          snackMessage(message: "Saved :D", context: context);
          Navigator.of(context).pop();
        } else {
          final errorServer =
              await json.decode(utf8.decode(_response.bodyBytes));
          print(errorServer);
          snackMessage(
              message: "${errorServer.toString()}",
              context: context,
              isError: true);
        }
      } catch (error) {
        snackMessage(
            message: "${error.toString()}", context: context, isError: true);
      }
    } else {
      //IS not Valid
      snackMessage(
          message: "Issiue Inside the Form", context: context, isError: true);
    }
  }

  Future<void> _insertDataToDB(Foods food) async {
    final Database? db = await DatabaseHelper.db.database;
    await db!.insert("food", food.toMapSQL());
  }

  Future<int> _getValidID() async {
    final Database? db = await DatabaseHelper.db.database;
    List<Map> list = await db!.rawQuery("select MAX(idLocal) from food;");
    return (list != null &&
            list.isNotEmpty &&
            list.first["MAX(idLocal)"] != null)
        ? list.first["MAX(idLocal)"] + 1
        : 1;
  }
}
