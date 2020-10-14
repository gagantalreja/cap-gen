import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(
    MaterialApp(
      home: Main(),
    ),
  );
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 370,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Transform.scale(
              scale: 1,
              child: Image.asset('./assets/img/design.png'),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: Offset(0, -51),
              child: Material(
                shape: CircleBorder(),
                elevation: 30.0,
                child: CircleAvatar(
                  radius: 45.0,
                  backgroundColor: Colors.blue[600],
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      print('hello');
                    },
                    iconSize: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Transform(
            transform: Matrix4.rotationY(math.pi),
            child: Transform.translate(
              offset: Offset(90, -20),
              child: Icon(
                Icons.format_quote,
                size: 70,
                color: Color.fromRGBO(29, 161, 242, 0.2),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-10, -10),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: Text(
                  'We generate captions so that you focus on smiling :)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Montserrat',
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(150, 0),
            child: Icon(
              Icons.format_quote,
              size: 70,
              color: Color.fromRGBO(29, 161, 242, 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
