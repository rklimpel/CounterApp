import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'prefsHandler.dart';

//TODO:
// [X] Get first free number for Counter name
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
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Count-it"),
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
      body: Container(
        color: Colors.black.withAlpha(0),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1),
              ),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.indigo,
                      height: 60,
                      child: SizedBox.expand(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AutoSizeText(
                              "$counterName",
                              style: TextStyle(
                                fontSize: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 25,
                      color: Colors.red,
                      child: SizedBox.expand(
                        child: CustomPaint(
                          painter: TrianglePainterTopDown(),
                        ),
                      ),
                    ),
                    Container(
                      height: 160,
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
                            child: Text(
                              "+",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 80,
                              ),
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
      ),
      drawer: Drawer(
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
                  child: Container(
                    height: 70,
                    child: Stack(
                      children: <Widget>[
                        Card(
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
                                      child: AutoSizeText(
                                        "${counters[index].name}",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
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
    addCounterTextController.clear();
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text("Create new Counter"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: addCounterTextController,
            validator: (val) => checkNameExists(val) ? "You can't use this name" : null,
            decoration: new InputDecoration(
              hintText: "Counter ${getFreeCounterNumber()}",
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              final form = formKey.currentState;
              if (!form.validate()) {
                //Do Nothing
              } else {
                addCounter(addCounterTextController.text);
                Navigator.pop(context);
              }
            },
            child: Text("Ok"),
          )
        ],
      ),
    );
  }

  final formKey = GlobalKey<FormState>();

  void editCounterDialog() {
    editCounterTextController.clear();
    editCounterValueController.clear();
    editCounterTextController.text = counterName;
    editCounterValueController.text = "$counter";
    showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text("Edit Counter"),
        content: Container(
          height: 150,
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: editCounterTextController,
                  autocorrect: false,
                  validator: (val) => checkNameExists(val) && val != counterName ? "You can't use this name" : null,
                ),
                TextField(
                  controller: editCounterValueController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              setState(() {
                final form = formKey.currentState;
                if (!form.validate()) {
                  //Do Nothing
                } else {
                  for (var i = 0; i < counters.length; i++) {
                    if (counters[i].name == counterName) {
                      counters[i].name = editCounterTextController.text;
                    }
                  }
                  counterName = editCounterTextController.text;
                  counter = int.parse(editCounterValueController.text);
                  Navigator.pop(context);
                  saveState();
                }
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

class TrianglePainterTopDown extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint();

    Path trianglePath = new Path();
    trianglePath.moveTo(size.width / 2 - 25, 0);
    trianglePath.lineTo(size.width / 2, 25);
    trianglePath.lineTo(size.width / 2 + 25, 0);
    trianglePath.close();
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height + 2), paint);
    paint.color = Colors.indigo;
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class TrianglePainterLeftRight extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint();

    double tsize = 20;

    Path trianglePath = new Path();
    trianglePath.moveTo(-1, size.height / 2 - tsize);
    trianglePath.lineTo(tsize, size.height / 2);
    trianglePath.lineTo(-1, size.height / 2 + tsize);
    trianglePath.close();
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTRB(5, 0, size.width, size.height), paint);
    paint.color = Colors.indigo;
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
