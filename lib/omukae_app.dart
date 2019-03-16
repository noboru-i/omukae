import 'package:flutter/material.dart';
import 'package:omukae/pages/welcome_page.dart';

class OmukaeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omukae',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
    );
  }
}
