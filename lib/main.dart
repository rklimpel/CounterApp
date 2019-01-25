import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        accentColor: Colors.deepOrangeAccent,
      ),
      home: MyHomePage(title: 'Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child:Container(
            width: 160,
            height: 160,
            child: RaisedButton(
              color: Colors.blue,
              child: Center(
                child: Text(
                  "+",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 100,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              onPressed: _incrementCounter,
              shape: new RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(360)),
            ),
          ),
        ),
      ),
    );
  }
}
