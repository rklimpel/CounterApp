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
        brightness: Brightness.light,
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
  List<Counter> counters = [];
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

  Future<List<Counter>> getAllCounters() async {
    final SharedPreferences prefs = await getPrefs();
    List<String> tmpCounterNames = await prefs.getStringList(PREFS_LIST) ?? null;
    List<Counter> tmpCounters = new List();
    for (var i = 0; i < tmpCounterNames.length; i++) {
      tmpCounters.add(Counter(tmpCounterNames[i], await getCounterValue(tmpCounterNames[i])));
    }
    setState(() {
      counters = tmpCounters;
      for (var i = 0; i < counters.length; i++) {
        print("Load Counter $i with name: ${counters[i].name} and value: ${counters[i].value}");
      }
    });
  }

  Future<int> getCounterValue(String counterName) async {
    final SharedPreferences prefs = await getPrefs();
    return prefs.getInt(PREFS_VALUE + counterName) ?? null;
  }

  //Counter init, load usw. //

  void initData() async {
    String lastCounter = await getLastCounter();
    print("Last Counter is: $lastCounter");
    Future futureCounters = getAllCounters();
    futureCounters.then((_) => print(counters.length));

    if (lastCounter != null) {
      loadCounter(lastCounter);
    } else {
      if (counters.length == 0) {
        addCounter("Counter 1");
      }
    }
    ;
  }

  void loadCounter(String name) async {
    counterName = name;
    _counter = await getCounterValue(name);
    print("Counters length: ${counters.length}");
    setState(() {});
  }

  void addCounter(String name) {
    counterName = name != null ? name : "Counter ${getNextCounterNumber()}";
    _counter = 0;
    counters.add(Counter(counterName, _counter));
    setState(() {});
    saveCounter();
    saveCounterList();
  }

  void saveCounter() async {
    SharedPreferences prefs = await getPrefs();
    await prefs.setString(PREFS_LAST, counterName);
    await prefs.setInt(PREFS_VALUE + counterName, _counter);
    await getAllCounters();
  }

  void saveCounterList() async {
    SharedPreferences prefs = await getPrefs();
    await prefs.setStringList(PREFS_LIST, counterListToStringList(counters));
  }

  List<String> counterListToStringList(List<Counter> cs) {
    List<String> ss = [];
    for (var i = 0; i < cs.length; i++) {
      ss.add(cs[i].name);
    }
    return ss;
  }

  void deleteThisCounter() async {
    SharedPreferences prefs = await getPrefs();
    await prefs.remove(counterName);
    saveCounterList();
  }

  void deleteCounter(String name) async {
    SharedPreferences prefs = await getPrefs();
    print(await prefs.remove(name));
    saveCounterList();
  }

  //Helper Methods //

  String getNextCounterNumber() {
    List<int> values = new List();
    for (int i = 0; i < counters.length; i++) {
      if (counters[i].name.contains("Counter ")) {
        values.add(int.parse(counters[i].name.substring(7)));
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
    print(counters.length);
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
              _confirmDialog("Do you really want to delete this Counter permanently?\n(Not implemented)", deleteThisCounter);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Center(
            child: Column(
          children: <Widget>[
            Container(
              width: 200,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Center(
                    child: Text(
                      "$_counter",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            Expanded(
              flex: 4,
              child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: SizedBox.expand(
                      child: FlatButton(
                        highlightColor: Colors.lightGreen,
                        splashColor: Colors.lightGreen,
                        //highlightedBorderColor: Colors.grey,
                        child: Text(
                          "+",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.withOpacity(0.5),
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
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: SizedBox.expand(
                      child: FlatButton(
                        highlightColor: Colors.deepOrange,
                        splashColor: Colors.deepOrange,
                        child: Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.withOpacity(0.5),
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
        child: Container(
          child: ListView(
            children: List.generate(counters.length, (index) {
              return Dismissible(
                key: Key(counters[index].name),
                onDismissed: (direction) {
                  setState(() {
                    counters.removeAt(index);
                    deleteCounter(counters[index].name);
                  });
                },
                child: Container(
                  height: 100,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(58, 0, 8, 0),
                          child: Container(
                            height: 60,
                            width: double.infinity,
                            child: Card(
                              color: Colors.white,
                              elevation: 4,
                              shape: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 0,
                                ),
                                top: BorderSide(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 4,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(360),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                                width: 0.2,
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text("${counters[index].value}"),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Center(
                          child: SizedBox.expand(
                            child: FlatButton(
                              color: Colors.transparent,
                              onPressed: () {
                                loadCounter(counters[index].name);
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(108, 0, 42, 0),
                                child: Text("${counters[index].name}"),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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

class Counter {
  Counter(this.name, this.value);
  String name;
  int value;
}
