import 'dart:convert';

import 'package:fcm_custom_sender/main.dart';
import 'package:flutter/material.dart';

class Controller extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  Map<String, dynamic> result = {};

  List<CustomForm> formList = [];

  Controller() {
    debugPrint('Controller initialize');
    _initForm();
  }

  void _initForm() {
    formList.insert(0, CustomForm(index: 0, isAddRemove: true));
    notifyListeners();
  }

  void addWidget(context, CustomForm model, index) {
    model.isAddRemove = false;
    int value = (model.index! + 1);
    _showSnackBar(context, 'Add index :: $value');
    formList.add(CustomForm(index: value, isAddRemove: true));
    notifyListeners();
  }

  void removeWidget(context, CustomForm model) {
    formList.remove(model);
    _showSnackBar(context, 'Remove index :: ${model.index}');
    notifyListeners();
  }

  void onChangeKey(index, key) {
    formList[index].key = key;
    notifyListeners();
  }

  void onChangeValue(index, value) {
    formList[index].value = value;
    notifyListeners();
  }

  void onClear() {
    formList.clear();
    result.clear();
    _initForm();
    notifyListeners();
  }

  void onPressed(context) {
    if (!formKey.currentState!.validate()) {
      _showSnackBar(context, 'Validate Error');
    } else {
      formKey.currentState!.save();
      result.clear();
      for (final entry in formList) {
        if (entry.key != null) {
          result.addAll({entry.key!: entry.value});
        }
      }
      debugPrint("Result :: ${json.encode(result)}");
      _showSnackBar(context, json.encode(result));
    }
    notifyListeners();
  }

  void _showSnackBar(context, message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
