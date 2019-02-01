import 'package:flutter/material.dart';

class TrianglePainterTopDown extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint();

    Path trianglePath = new Path();
    trianglePath.moveTo(size.width / 2 - 25, -1);
    trianglePath.lineTo(size.width / 2, 25);
    trianglePath.lineTo(size.width / 2 + 25, -1);
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
