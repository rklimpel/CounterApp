import 'package:flutter/material.dart';

void confirmDialog(BuildContext context, String text, void onConfirmed()) {
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

/*void neweditCounterDialog() {
  editCounterTextController.clear();
  editCounterValueController.clear();
  editCounterTextController.text = counterName;
  editCounterValueController.text = "$counter";
  Dialog dialog = Dialog(
    child: Container(
      color: Colors.white,
      height: 320,
      width: 300,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.indigo,
            height: 50,
            child: SizedBox.expand(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                ),
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
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                height: 60,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 20,
                      color: Colors.indigo,
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Form(
                          key: formKey,
                          child: TextFormField(
                            autovalidate: true,
                            validator: (val) => checkNameExists(val) && val != counterName ? "name already in use" : null,
                            enabled: true,
                            controller: editCounterTextController,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: "counter name",
                              hintText: "$counterName",
                              hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                height: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                height: 60,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 20,
                      color: Colors.indigo,
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: TextFormField(
                          enabled: true,
                          controller: editCounterValueController,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: "counter value",
                            hintText: "$counter",
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              height: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.indigo,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.indigo,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.indigo,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            color: Colors.indigo,
            child: SizedBox.expand(
              child: FlatButton(
                  onPressed: () {
                    final form = formKey.currentState;
                    if (!form.validate()) {
                      //Do Nothing
                    } else {
                      addCounter(addCounterTextController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  )),
            ),
          )
        ],
      ),
    ),
  );
  showDialog(context: context, builder: (BuildContext context) => dialog);
}

void addCounterDialog() {
  addCounterTextController.clear();
  Dialog dialog = Dialog(
    child: Container(
      color: Colors.white,
      height: 260,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.indigo,
            height: 50,
            child: SizedBox.expand(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(icon: Icon(Icons.add), onPressed: () {}),
                ),
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
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                height: 60,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 20,
                      color: Colors.indigo,
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Form(
                          key: formKey,
                          child: TextFormField(
                            autovalidate: true,
                            validator: (val) => checkNameExists(val) ? "name already in use" : null,
                            enabled: true,
                            controller: addCounterTextController,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: "enter new Counter name",
                              hintText: "Counter ${getFreeCounterNumber()}",
                              hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                height: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            color: Colors.indigo,
            child: SizedBox.expand(
              child: FlatButton(
                  onPressed: () {
                    final form = formKey.currentState;
                    if (!form.validate()) {
                      //Do Nothing
                    } else {
                      addCounter(addCounterTextController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  )),
            ),
          )
        ],
      ),
    ),
  );
  showDialog(context: context, builder: (BuildContext context) => dialog);
}*/
