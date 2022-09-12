import 'dart:convert';

import 'package:fcm_custom_sender/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Controller()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FCM Sender',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (context, data, child) {
        return SelectionArea(
          child: Scaffold(
            appBar: _buildAppBar(data),
            body: _buildBodyForm(data),
            floatingActionButton: _buildFloatingActionButton(data, context),
          ),
        );
      },
    );
  }

  Form _buildBodyForm(Controller data) {
    return Form(
      key: data.formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              padding: const EdgeInsets.all(20),
              shrinkWrap: true,
              itemCount: data.formList.length,
              itemBuilder: (context, index) {
                return _buildItemRow(data, index, context);
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            json.encode(data.result),
            style: const TextStyle(fontFamily: 'Matter'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(
      Controller data, BuildContext context) {
    return FloatingActionButton(
      onPressed: () => data.onPressed(context),
      tooltip: 'Data',
      child: const Icon(Icons.send),
    );
  }

  Row _buildItemRow(Controller data, int index, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            key: ValueKey(data.formList[index].index),
            initialValue: data.formList[index].key,
            controller: data.formList[index].keyController,
            decoration: InputDecoration(
              label: Text('Key ${data.formList[index].index.toString()}'),
              border:
                  const OutlineInputBorder(borderSide: BorderSide(width: 2)),
              hintText: 'Key ${data.formList[index].index}',
              hintStyle: const TextStyle(fontFamily: 'Matter'),
            ),
            style: const TextStyle(fontFamily: 'Matter'),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Key can't empty";
              }
              return null;
            },
            onChanged: (val) => data.onChangeKey(index, val),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            key: ValueKey(data.formList[index].index),
            initialValue: data.formList[index].value,
            controller: data.formList[index].valueController,
            decoration: InputDecoration(
              label: Text('Value ${data.formList[index].index.toString()}'),
              border:
                  const OutlineInputBorder(borderSide: BorderSide(width: 2)),
              hintText: 'Value',
              hintStyle: const TextStyle(fontFamily: 'Matter'),
            ),
            style: const TextStyle(fontFamily: 'Matter'),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Value can't empty";
              }
              return null;
            },
            onChanged: (val) => data.onChangeValue(index, val),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 0,
          fit: FlexFit.tight,
          child: IconButton(
            onPressed: data.formList[index].isAddRemove
                ? () => data.addWidget(context, data.formList[index], index)
                : () => data.removeWidget(context, data.formList[index]),
            icon: data.formList[index].isAddRemove
                ? const Icon(Icons.add_circle_outline)
                : const Icon(Icons.remove_circle_outline),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar(Controller data) {
    return AppBar(
      title: const Text(
        'Flutter FCM Sender',
        style: TextStyle(fontFamily: 'ClashDisplay'),
      ),
      actions: [
        IconButton(
          onPressed: () => data.onClear(),
          icon: const Icon(Icons.cleaning_services_rounded),
        ),
      ],
    );
  }
}

class CustomForm {
  int? index;
  bool isAddRemove;
  String? key;
  String? value;
  TextEditingController? keyController;
  TextEditingController? valueController;

  CustomForm({
    this.index,
    this.isAddRemove = true,
    this.key,
    this.value,
    this.keyController,
    this.valueController,
  });
}
