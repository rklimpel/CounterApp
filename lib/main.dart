import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter 1',
      theme: ThemeData(
        brightness: Brightness.dark,
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

  void _incCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decCounter() {
    setState(() {
      _counter--;
    });
  }

  void resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _confirmDialog(String text, void onConfirmed()) {
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text("$text"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("No"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirmed();
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _confirmDialog("Do you really want to reset this Counter?", resetCounter);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: null,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Center(
            child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        "$_counter",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 80,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox.expand(
                      child: OutlineButton(
                        highlightColor: Colors.lightGreen,
                        splashColor: Colors.lightGreen,
                        highlightedBorderColor: Colors.grey,
                        child: Text(
                          "+",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.withOpacity(0.3),
                            fontSize: 80,
                          ),
                        ),
                        onPressed: _incCounter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox.expand(
                      child: OutlineButton(
                        highlightColor: Colors.deepOrange,
                        splashColor: Colors.deepOrange,
                        highlightedBorderColor: Colors.grey,
                        child: Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.withOpacity(0.3),
                            fontSize: 80,
                          ),
                        ),
                        onPressed: _decCounter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
          child: Container(
            child: Text("Counter List..."),
          ),
        ),
      ),
    );
  }
}
