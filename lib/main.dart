import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String PREFS_LAST = "PREFS_LAST";
const String PREFS_LIST = "PREFS_LIST";
const String PREFS_VALUE = "PREFS_VALUE_";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: "Counter"),
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
  String counterName;
  List<String> counters = new List();
  Future<SharedPreferences> getPrefs() => SharedPreferences.getInstance();

  // active Counter Methods //

  void incCounter() {
    setState(() {
      _counter++;
      saveCounter();
    });
  }

  void decCounter() {
    setState(() {
      _counter--;
      saveCounter();
    });
  }

  void resetCounter() {
    setState(() {
      _counter = 0;
      saveCounter();
    });
  }

  // Shared Preferences Stuff //

  Future<String> getLastCounter() async {
    SharedPreferences prefs = await getPrefs();
    return prefs.getString(PREFS_LAST) ?? null;
  }

  Future<List<String>> getAllCounters() async {
    final SharedPreferences prefs = await getPrefs();
    return prefs.getStringList(PREFS_LIST) ?? null;
  }

  Future<int> getCounterValue(String counterName) async {
    final SharedPreferences prefs = await getPrefs();
    return prefs.getInt(PREFS_VALUE + counterName) ?? null;
  }

  //Counter init, load usw. //

  void initData() async {
    String lastCounter = await getLastCounter();
    lastCounter != null ? loadCounter(lastCounter) : addCounter("Counter 1");
    counters = await getAllCounters();
  }

  void loadCounter(String name) async {
    counterName = name;
    _counter = await getCounterValue(name);
    setState(() {});
  }

  void addCounter(String name) {
    setState(() {
      counterName = name != null ? name : "Counter ${getNextCounterNumber()}";
      _counter = 0;
      counters.add(counterName);
    });
    saveCounter();
    saveCounterList();
  }

  void saveCounter() async {
    SharedPreferences prefs = await getPrefs();
    await prefs.setString(PREFS_LAST, counterName);
    await prefs.setInt(PREFS_VALUE + counterName, _counter);
  }

  void saveCounterList() async {
    SharedPreferences prefs = await getPrefs();
    await prefs.setStringList(PREFS_LIST, counters);
  }

  void deleteCounter() {
    //TODO Implement
  }

  //Helper Methods //

  String getNextCounterNumber() {
    List<int> values = new List();
    for (int i = 0; i < counters.length; i++) {
      if (counters[i].contains("Counter ")) {
        values.add(int.parse(counters[i].substring(7)));
      }
    }
    return values.length != 0 ? "${values.reduce(max) + 1}" : "0";
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$counterName"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              addCounter(null);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _confirmDialog("Do you really want to reset this Counter?", resetCounter);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              _confirmDialog("Do you really want to delete this Counter permanently?\n(Not implemented)", deleteCounter);
            },
          ),
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
                        onPressed: incCounter,
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
                        onPressed: decCounter,
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
            child: ListView(
              children: List.generate(counters.length, (index) {
                return Container(
                  height: 50,
                  child: MaterialButton(
                    shape: Border.all(width: 1, color: Colors.black),
                    onPressed: () {
                      loadCounter(counters[index]);
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text("${counters[index]}"),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
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
}
