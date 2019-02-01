import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'customPainters.dart';
import 'dialogs.dart';
import 'prefsHandler.dart';

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
  double valueContainerHeight = 140;
  IconData upperButtonIcon = Icons.add;
  IconData lowerButtonIcon = Icons.remove;

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
    futureCounterNames.then((names) => names == null ? null : loadListValues(names));

    if (lastCounter != null) {
      loadCounter(lastCounter);
    } else {
      if (counters == null || counters.length == 0) {
        counters = new List();
        addCounter("sample counter");
      } else {
        //TODO???
      }
    }
  }

  void loadCounter(String name) async {
    counterName = name;
    counter = await readCounterValue(name);
    setCounterStateCount();
    setState(() {});
  }

  void addCounter(String name) {
    setState(() {
      counterName = (name != null && name != "") ? name : "Counter ${getFreeCounterNumber()}";
      counter = 0;
      counters.add(Counter(counterName, counter));
    });
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
    setState(() {
      counterState = CounterState.count;
      nameContainerHeight = 60;
      valueContainerHeight = 140;
      upperButtonIcon = Icons.add;
      lowerButtonIcon = Icons.remove;
    });
  }

  void setCounterStateEditName() {
    setState(() {
      counterState = CounterState.editName;
      nameContainerHeight = 200;
      valueContainerHeight = 0;
      upperButtonIcon = Icons.save;
      lowerButtonIcon = Icons.clear;
    });
  }

  void setCounterStateEditValue() {
    setState(() {
      counterState = CounterState.editValue;
      nameContainerHeight = 0;
      valueContainerHeight = 200;
      upperButtonIcon = Icons.save;
      lowerButtonIcon = Icons.clear;
    });
  }

  void setCounterStateAddCounter() {
    setState(() {
      counterState = CounterState.add;
      nameContainerHeight = 200;
      valueContainerHeight = 0;
      upperButtonIcon = Icons.save;
      lowerButtonIcon = Icons.clear;
    });
  }

  Widget counterNameSwapper() {
    if (counterState == CounterState.editName || counterState == CounterState.add) {
      TextEditingController c;
      String hint = "";
      if (counterState == CounterState.editName) {
        editCounterTextController.text = counterName;
        c = editCounterTextController;
      } else if (counterState == CounterState.add) {
        addCounterTextController.clear();
        c = addCounterTextController;
        hint = "Counter ${getFreeCounterNumber()}";
      }

      return Form(
        key: formKey,
        child: TextFormField(
          autofocus: false,
          autocorrect: false,
          autovalidate: true,
          validator: (val) => checkNameExists(val) && val != counterName ? "name already in use" : null,
          controller: c,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 25,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.2),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 3,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: AutoSizeText(
          "$counterName",
          style: TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget counterValueSwapper() {
    if (counterState == CounterState.editValue) {
      editCounterValueController.text = "";
      return TextFormField(
        autofocus: false,
        autocorrect: false,
        controller: editCounterValueController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLines: 1,
        style: TextStyle(
          fontSize: 50,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: "$counter",
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.1),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
        ),
      );
    } else {
      return AutoSizeText(
        "$counter",
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 80,
        ),
      );
    }
  }

  AppBar myAppbar() => AppBar(
        title: Text("Count-it"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: setCounterStateAddCounter,
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
                                if (counterState == CounterState.count) {
                                  setCounterStateEditName();
                                }
                              },
                              onLongPress: () {
                                if (counterState == CounterState.count) {
                                  setCounterStateEditName();
                                }
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
                      child: SizedBox.expand(
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
                                child: counterValueSwapper(),
                              ),
                            ),
                            GestureDetector(
                              onDoubleTap: () {
                                if (counterState == CounterState.count) {
                                  setCounterStateEditValue();
                                }
                              },
                              onLongPress: () {
                                if (counterState == CounterState.count) {
                                  setCounterStateEditValue();
                                }
                              },
                            )
                          ],
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
                            child: Icon(
                              upperButtonIcon,
                              size: 50,
                            ),
                            onPressed: () {
                              final form = formKey.currentState;
                              switch (counterState) {
                                case CounterState.count:
                                  {
                                    incCounter();
                                    break;
                                  }
                                case CounterState.add:
                                  {
                                    if (!form.validate()) {
                                      //Do nothing
                                    } else {
                                      setState(() {
                                        addCounter(addCounterTextController.text);
                                        setCounterStateCount();
                                        saveState();
                                      });
                                    }
                                    break;
                                  }
                                case CounterState.editName:
                                  {
                                    if (!form.validate()) {
                                      //Do Nothing
                                    } else {
                                      for (var i = 0; i < counters.length; i++) {
                                        if (counters[i].name == counterName) {
                                          setState(() {
                                            counters[i].name = editCounterTextController.text;
                                          });
                                        }
                                      }
                                      counterName = editCounterTextController.text;
                                      setCounterStateCount();
                                      saveState();
                                    }
                                    break;
                                  }
                                case CounterState.editValue:
                                  {
                                    counter = int.parse(editCounterValueController.text);
                                    setCounterStateCount();
                                    saveState();
                                    break;
                                  }
                              }
                            },
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
                              child: Icon(
                                lowerButtonIcon,
                                size: 50,
                              ),
                              onPressed: () {
                                switch (counterState) {
                                  case CounterState.count:
                                    {
                                      decCounter();
                                      break;
                                    }
                                  default:
                                    {
                                      setCounterStateCount();
                                      break;
                                    }
                                }
                              },
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
      resizeToAvoidBottomPadding: false,
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
