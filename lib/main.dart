import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'customPainters.dart';
import 'dialogs.dart';
import 'prefsHandler.dart';

//TODO:
// [X] Get first free number for Counter name
// [X] Edit Counter Value with Keyboard
// [X] Edit Counter Name
// [X] Don't create two counters with the same name bitch!
// [X] Creator new inital Counter if every counter is removed

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Count-It',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
      ),
      home: MyHomePage(),
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

  double nameContainerHeight = 60;
  double valueContainerHeight = 160;
  IconData upperButtonIcon = Icons.add;

  bool editCounter = false;
  bool editName = false;

  CounterState counterState = CounterState.count;

  final addCounterTextController = TextEditingController();
  final editCounterTextController = TextEditingController();
  final editCounterValueController = TextEditingController();

  final formKey = GlobalKey<FormState>();

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
    setState(() {
      for (var i = 0; i < counters.length; i++) {
        if (counters[i].name == name) {
          counters[i].value = value;
        }
      }
    });
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
  }

  void loadCounter(String name) async {
    counterName = name;
    counter = await readCounterValue(name);
    setState(() {});
  }

  void addCounter(String name) {
    print(name);
    counterName = (name != null && name != "") ? name : "Counter ${getFreeCounterNumber()}";
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

  String getCounterName(Counter c) => c.name;

  String getFreeCounterNumber() {
    for (int i = 0; i < counters.length + 1; i++) {
      if (!counters.map(getCounterName).contains("Counter $i")) {
        return "$i";
      }
    }
  }

  bool checkNameExists(String name) => counters.map(getCounterName).contains(name);

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    addCounterTextController.dispose();
    editCounterTextController.dispose();
    editCounterValueController.dispose();
    super.dispose();
  }

  void setCounterStateCount() {
    counterState = CounterState.count;
    nameContainerHeight = 60;
    valueContainerHeight = 160;
  }

  Widget counterNameSwapper() {
    if (editName) {
      return TextFormField(
        controller: editCounterTextController,
        textAlign: TextAlign.center,
        enabled: false,
        maxLines: 1,
        style: TextStyle(
          fontSize: 20,
        ),
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
      );
    } else {
      return AutoSizeText(
        "$counterName",
        style: TextStyle(
          fontSize: 20,
        ),
      );
    }
  }

  AppBar myAppbar() => AppBar(
        title: Text("Count-it"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                if (valueContainerHeight == 220) {
                  nameContainerHeight = 60;
                  valueContainerHeight = 160;
                } else {
                  nameContainerHeight = 0;
                  valueContainerHeight = 220;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                if (valueContainerHeight == 0) {
                  nameContainerHeight = 60;
                  valueContainerHeight = 160;
                } else {
                  nameContainerHeight = 220;
                  valueContainerHeight = 0;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              confirmDialog(context, "Do you really want to reset this Counter?", resetCounter);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              confirmDialog(context, "Do you really want to delete this Counter?", deleteThisCounter);
            },
          ),
        ],
      );

  Container myMainBody() => Container(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1),
              ),
              child: Container(
                child: Column(
                  children: <Widget>[
                    AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      color: Colors.indigo,
                      height: nameContainerHeight,
                      child: SizedBox.expand(
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: counterNameSwapper(),
                            ),
                            GestureDetector(
                              onDoubleTap: () {
                                setState(() {
                                  if (valueContainerHeight == 0) {
                                    nameContainerHeight = 60;
                                    valueContainerHeight = 160;
                                  } else {
                                    nameContainerHeight = 220;
                                    valueContainerHeight = 0;
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 25,
                      child: SizedBox.expand(
                        child: CustomPaint(
                          painter: TrianglePainterTopDown(),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      height: valueContainerHeight,
                      color: Colors.white,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
                          child: AutoSizeText(
                            "$counter",
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 80,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: Colors.indigo,
                        child: SizedBox.expand(
                          child: FlatButton(
                            highlightColor: Colors.lightGreen,
                            splashColor: Colors.lightGreen,
                            //highlightedBorderColor: Colors.grey,
                            child: Icon(
                              upperButtonIcon,
                              size: 80,
                            ),
                            onPressed: incCounter,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Colors.indigoAccent,
                        child: Center(
                          child: SizedBox.expand(
                            child: FlatButton(
                              highlightColor: Colors.deepOrange,
                              splashColor: Colors.deepOrange,
                              child: Text(
                                "-",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 80,
                                ),
                              ),
                              onPressed: decCounter,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Drawer myDrawer() => Drawer(
        child: Container(
          child: ListView(
            children: List.generate(counters.length, (index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Dismissible(
                  key: Key(counters[index].name),
                  onDismissed: (direction) {
                    if (counters.length == 1) {
                      Navigator.pop(context);
                    }
                    deleteCounter(counters[index].name);
                  },
                  child: counterListTile(index),
                ),
              );
            }),
          ),
        ),
      );

  Container counterListTile(int index) => Container(
        height: 70,
        child: Stack(
          children: <Widget>[
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1),
              ),
              child: SizedBox.expand(
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 80,
                      color: Colors.indigo,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox.expand(
                          child: Center(
                            child: AutoSizeText(
                              "${counters[index].value}",
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 25,
                      child: CustomPaint(
                        painter: TrianglePainterLeftRight(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              "${counters[index].name}",
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      color: Colors.indigo,
                    )
                  ],
                ),
              ),
            ),
            SizedBox.expand(
              child: FlatButton(
                highlightColor: Colors.indigoAccent.withOpacity(0.3),
                onPressed: () {
                  loadCounter(counters[index].name);
                  Navigator.pop(context);
                },
                child: null,
                color: Colors.transparent,
              ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(),
      body: myMainBody(),
      drawer: myDrawer(),
    );
  }
}

class Counter {
  Counter(this.name, this.value);
  String name;
  int value;
}

enum CounterState {
  editName,
  editValue,
  count,
  add,
}
