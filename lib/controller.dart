import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:fcm_custom_sender/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Controller extends ChangeNotifier {
  late SharedPreferences prefs;
  Map<String, dynamic> oldMap = {};

  final formKey = GlobalKey<FormState>();

  Map<String, dynamic> result = {};

  Map<String, dynamic>? notificationResult;

  List<CustomForm> formList = [];

  late TextEditingController urlEditController;
  late TextEditingController topicEditController;
  late TextEditingController tokenEditController;

  Controller() {
    debugPrint('Controller initialize');
    init();
    urlEditController = TextEditingController();
    topicEditController = TextEditingController();
    tokenEditController = TextEditingController();
  }

  void init() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getString("key1") != null) {
      Map<String, dynamic> mapValue = json
          .decode(prefs.getString("key1").toString()) as Map<String, dynamic>;
      urlEditController.text = mapValue['url'].toString();
      topicEditController.text = mapValue['data']['to'].toString();
      tokenEditController.text =
          mapValue['headers']['Authorization'].toString();

      Map<String, dynamic> notificationValue =
          json.decode(mapValue['data']['notification']) as Map<String, dynamic>;
      int x = 0;

      int currentLength = notificationValue.length;

      notificationValue.forEach((key, value) {
        formList.insert(
            x,
            CustomForm(
              index: x,
              isAddRemove: (currentLength - 1 == x),
              key: key,
              value: value,
            ));
        x = (x + 1);
      });
    } else {
      _initForm();
    }
    notifyListeners();
  }

  void _initForm() async {
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

  void onPressed(context) async {
    // if (!formKey.currentState!.validate()) {
    //   _showSnackBar(context, 'Validate Error');
    // } else {
    formKey.currentState!.save();
    result.clear();
    for (final entry in formList) {
      if (entry.key != null) {
        result.addAll({entry.key!: entry.value});
      }
    }
    debugPrint("Result :: ${json.encode(result)}");
    await sendNotification();
    _showSnackBar(context, json.encode(result));
    // }
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

  Future<void> sendNotification() async {
    String url = urlEditController.text;
    String topic = topicEditController.text;
    String token = tokenEditController.text;

    var headers = {'Content-Type': 'application/json', 'Authorization': token};

    var data = {"to": topic, "notification": json.encode(result)};

    oldMap = {"url": url, "headers": headers, "data": data};

    prefs.setString("key1", json.encode(oldMap));

    http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
    } else {
      debugPrint(response.reasonPhrase);
    }

    notificationResult = {
      "code": response.statusCode,
      "body": response.body,
    };

    notifyListeners();
  }
}
