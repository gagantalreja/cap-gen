import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';
import 'dart:math' as math;

void main() {
  runApp(
    MaterialApp(
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    new Timer(new Duration(seconds: 5), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Main()),
      );
    });

    return Scaffold(
      body: Center(
        child: Transform.translate(
          offset: Offset(0, 200),
          child: Column(
            children: [
              SvgPicture.asset('./assets/img/logo.svg'),
              SizedBox(height: 50),
              LoadingBumpingLine.square(
                backgroundColor: Colors.black,
                borderColor: Colors.black,
                size: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
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
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36.0),
              bottomRight: Radius.circular(36.0),
            ),
            elevation: 10.0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36.0),
                  bottomRight: Radius.circular(36.0),
                ),
              ),
              child: Transform.scale(
                scale: 1,
                child: Image.asset('./assets/img/design.png'),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -33),
            child: Container(
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Upload()),
                  );
                },
                shape: CircleBorder(),
                color: Colors.blue[700],
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 60.0,
                  ),
                ),
              ),
            ),
          ),
          Transform(
            transform: Matrix4.rotationY(math.pi),
            child: Transform.translate(
              offset: Offset(90, -10),
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
            offset: Offset(150, -15),
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

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  Widget build(BuildContext context) {
    File _image;
    final picker = ImagePicker();

    Future getImageFromCamera() async {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        var formData = FormData();
        formData.files.add(
          MapEntry(
            "Picture",
            await MultipartFile.fromFile(pickedFile.path,
                filename: "pic-name.png"),
          ),
        );
      } else {
        print('No image selected.');
      }
    }

    Future getImageFromGallery() async {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        var formData = FormData();
        formData.files.add(
          MapEntry(
            "Picture",
            await MultipartFile.fromFile(pickedFile.path,
                filename: "pic-name.png"),
          ),
        );
      } else {
        print('No image selected.');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(0, -80),
                  child: Container(
                    margin: EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 10,
                        color: Color.fromRGBO(245, 248, 250, 1),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        './assets/img/man_itis.svg',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 390,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          RaisedButton(
                            onPressed: getImageFromCamera,
                            shape: CircleBorder(),
                            color: Color.fromRGBO(245, 248, 250, 1),
                            child: Container(
                              padding: EdgeInsets.all(30.0),
                              child: Transform.scale(
                                scale: 1.3,
                                child: SvgPicture.asset(
                                  './assets/img/camera.svg',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20.0,
                              letterSpacing: 1.5,
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          RaisedButton(
                            onPressed: getImageFromGallery,
                            shape: CircleBorder(),
                            color: Color.fromRGBO(245, 248, 250, 1),
                            child: Container(
                              padding: EdgeInsets.all(30.0),
                              child: Transform.scale(
                                scale: 1.3,
                                child: SvgPicture.asset(
                                  './assets/img/gallery.svg',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20.0,
                              letterSpacing: 1.5,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 560,
                  left: 150,
                  child: Transform.scale(
                    scale: 3.5,
                    child: Container(
                      height: 80,
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('./assets/img/back.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
