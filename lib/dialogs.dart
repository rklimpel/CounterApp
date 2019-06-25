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
