import 'package:flutter/material.dart';
import 'package:retail_bill/history_widget.dart';
import 'package:retail_bill/multi_item_form_widget.dart';
import 'package:retail_bill/new_bill_widget.dart';
import 'package:retail_bill/print_widget.dart';
import 'package:retail_bill/services/app_service.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {  
    init();  
    return MaterialApp(
      title: 'Create Bill',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        // '/': (context) => NewBillWidget(),
        '/': (context) => MultiItemFormWidget(),
        '/history': (context) => HistoryWidget(),
        '/bluetooth': (context) => PrintWidget(),
      },
      // home: MultiItemFormWidget(),
    );
  }

  Future init() async {
    await AppService.instance.onBootUp();
  }
}


