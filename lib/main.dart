import 'dart:math';

import 'package:flutter/material.dart';

import 'prefsHandler.dart';

//TODO:
// [ ] Get first free number for Counter name
// [X] Edit Counter Value with Keyboard
// [X] Edit Counter Name
// [ ] Don't create two counters with the same name bitch!
// [X] Creator new inital Counter if every counter is removed

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
  int counter = 0;
  String counterName;
  List<Counter> counters = [];

  final addCounterTextController = TextEditingController();
  final editCounterTextController = TextEditingController();
  final editCounterValueController = TextEditingController();

  void incCounter() {
    setState(() {
      counter++;
      saveState();
    });
  }

  void decCounter() {
    setState(() {
      counter--;
      saveState();
    });
  }

  void resetCounter() {
    setState(() {
      counter = 0;
      saveState();
    });
  }

  void updateListValue(String name, int value) {
    for (var i = 0; i < counters.length; i++) {
      if (counters[i].name == name) {
        counters[i].value = value;
      }
    }
  }

  void loadListValues(List<String> names) async {
    counters.clear();
    for (var i = 0; i < names.length; i++) {
      counters.add(Counter(names[i], await readCounterValue(names[i])));
    }
  }

  void initData() async {
    String lastCounter = await readLastCounter();
    Future futureCounterNames = readAllCountersNames();
    futureCounterNames.then((names) => loadListValues(names));

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
    counter = await readCounterValue(name);
    setState(() {});
  }

  void addCounter(String name) {
    print(name);
    counterName = (name != null && name != "") ? name : "Counter ${getFreeCounterName()}";
    counter = 0;
    counters.add(Counter(counterName, counter));
    setState(() {});
    saveState();
  }

  void saveState() async {
    updateListValue(counterName, counter);
    writeCounterValue(counterName, counter);
    writeAllCounterNames(counters);
  }

  void deleteThisCounter() => deleteCounter(counterName);

  void deleteCounter(String name) {
    setState(() {
      deleteCounterValue(name);
      counters.removeWhere((counter) => counter.name == name);
      if (counters.length == 0) {
        Future.delayed(const Duration(milliseconds: 10), () {
          addCounter(null);
        });
      } else if (name == counterName) {
        loadCounter(counters[0].name);
      }
    });
    saveState();
  }

  String getFreeCounterName() {
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
  void dispose() {
    addCounterTextController.dispose();
    super.dispose();
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
              addCounterDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              editCounterDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              confirmDialog("Do you really want to reset this Counter?", resetCounter);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              confirmDialog("Do you really want to delete this Counter permanently?\n(Not implemented)", deleteThisCounter);
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
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Center(
                    child: Text(
                      "$counter",
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
                            color: Colors.grey.withOpacity(0.9),
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
                            color: Colors.grey.withOpacity(0.9),
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
                  if (counters.length == 1) {
                    Navigator.pop(context);
                    print("POP!!!");
                  }
                  deleteCounter(counters[index].name);
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
                                elevation: 0,
                                shape: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 2,
                                )),
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(360),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                                width: 2,
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

  void confirmDialog(String text, void onConfirmed()) {
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

  void addCounterDialog() {
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text("Create new Counter"),
        content: TextField(
          controller: addCounterTextController,
          decoration: new InputDecoration(
            hintText: "Counter ${getFreeCounterName()}",
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              addCounter(addCounterTextController.text);
              Navigator.pop(context);
            },
            child: Text("Ok"),
          )
        ],
      ),
    );
  }

  void editCounterDialog() {
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text("Edit Counter"),
        content: Container(
          height: 100,
          child: Column(
            children: <Widget>[
              TextField(
                controller: editCounterTextController,
                autocorrect: false,
                decoration: new InputDecoration(
                  hintText: "$counterName",
                ),
              ),
              TextField(
                controller: editCounterValueController,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                  hintText: "$counter",
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              setState(() {
                counterName = editCounterTextController.text;
                counter = int.parse(editCounterValueController.text);
                Navigator.pop(context);
                saveState();
              });
            },
            child: Text("Save"),
          )
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
