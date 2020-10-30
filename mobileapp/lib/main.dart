import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:math' as math;

void main() {
  runApp(
    MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => Home(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/main':
            return PageTransition(
              child: Main(),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          case '/upload':
            return PageTransition(
              child: Upload(),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          case '/caption':
            return PageTransition(
              child: Caption(),
              type: PageTransitionType.fade,
              settings: settings,
            );
          default:
            return null;
        }
      },
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
      Navigator.of(context).pushReplacementNamed("/main");
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
                  Navigator.pushNamed(context, "/upload");
                },
                shape: CircleBorder(),
                color: Colors.blue[700],
                child: Container(
                  padding: EdgeInsets.all(
                    10.0,
                  ),
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
    String resp;
    final picker = ImagePicker();

    Future upload(File _image) async {
      Dio dio = new Dio();

      String mimeType = mime(_image.path);
      String mimee = mimeType.split('/')[0];
      String type = mimeType.split('/')[1];

      FormData formdata = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          _image.path,
          filename: basename(_image.path),
          contentType: MediaType(mimee, type),
        )
      });
      var response = await dio.post(
        "http://10.0.2.2:5000/upload",
        data: formdata,
        options: Options(
            method: 'POST',
            responseType: ResponseType.json // or ResponseType.JSON
            ),
      );
      if (response.statusCode == 200) {
        return response.toString();
      } else {
        return null;
      }
    }

    Future getImageFromGallery() async {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        resp = await upload(_image);
      } else {
        print('No image selected.');
      }
    }

    Future getImageFromCamera() async {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        resp = await upload(_image);
        var r = JsonCodec().decode(resp.toString());
        print(r["src"]);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Caption(image: _image, src: r["src"]),
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

class RemoteApi {
  Future getCardList(src) async {
    Dio dio = new Dio();
    var response = await dio.get(
      "http://10.0.2.2:5000/get-result?image=${src}",
      options: Options(
          method: 'POST',
          responseType: ResponseType.json // or ResponseType.JSON
          ),
    );
    if (response.statusCode == 200) {
      return response.toString();
    } else {
      return null;
    }
  }
}

class Caption extends StatefulWidget {
  final File image;
  final String src;
  Caption({Key key, this.image, this.src}) : super(key: key);

  @override
  _CaptionState createState() => _CaptionState();
}

class _CaptionState extends State<Caption> {
  @override
  Widget build(BuildContext context) {
    var image = widget.image;

    Future apiCall() async {
      final resp = await RemoteApi().getCardList(widget.src);
      var r = JsonCodec().decode(resp.toString());
      print(r["result"]["result"]);
    }

    apiCall();

    return Scaffold(
      body: Column(
        children: [
          Transform.translate(
            offset: Offset(0, 24),
            child: Material(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36.0),
                bottomRight: Radius.circular(36.0),
              ),
              elevation: 10.0,
              child: Transform.scale(
                scale: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36.0),
                    bottomRight: Radius.circular(36.0),
                  ),
                  child: Image.file(image),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Transform.translate(
                offset: Offset(-80, 45),
                child: Text(
                  "Top Suggestions",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 25.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(-135, 60),
                child: Text(
                  "Captions",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
