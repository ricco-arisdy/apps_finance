import 'package:apps_finance/screen/categoryscreen.dart';
import 'package:apps_finance/screen/homeviewscreen.dart';
import 'package:apps_finance/screen/inputcashflow.dart';
import 'package:flutter/material.dart';

void main() => runApp(FinanceApp());

class FinanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/input': (context) => InputScreen(),
        '/settings': (context) => CategoryScreen(),
      },
    );
  }
}
