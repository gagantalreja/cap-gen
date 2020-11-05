import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver/files.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

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
        "https://cap-gen.herokuapp.com/upload",
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
        var r = JsonCodec().decode(resp.toString());
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

    Future getImageFromCamera() async {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        resp = await upload(_image);
        var r = JsonCodec().decode(resp.toString());
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
                  top: 595,
                  left: 133,
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

class _ItemFetcher {
  Dio dio = new Dio();

  Future<String> fetchEmotion(String src) async {
    var response = await dio.get(
      "https://cap-gen.herokuapp.com/get-emotion?image=$src",
      options: Options(
          method: 'GET', responseType: ResponseType.json // or ResponseType.JSON
          ),
    );
    return response.toString();
  }

  Future<String> fetchCaptions(String emotion) async {
    print(emotion);
    var response = await dio.get(
      "https://cap-gen.herokuapp.com/text-gen-app?q=$emotion",
      options: Options(
          method: 'GET', responseType: ResponseType.json // or ResponseType.JSON
          ),
    );
    return response.toString();
  }

  Future<String> fetchTags(String emotion) async {
    var response = await dio.get(
      "https://cap-gen.herokuapp.com/tags-gen-app?q=$emotion",
      options: Options(
          method: 'GET', responseType: ResponseType.json // or ResponseType.JSON
          ),
    );
    return response.toString();
  }

  Future<String> fetchEmoji(String emotion) async {
    var response = await dio.get(
      "https://cap-gen.herokuapp.com/emoji-gen?polarity=$emotion",
      options: Options(
          method: 'GET', responseType: ResponseType.json // or ResponseType.JSON
          ),
    );
    return response.toString();
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
  List<String> captions = [];
  List<String> tags = [
    "#hastag1",
    "#hastag1",
    "#hastag1",
    "#hastag1",
    "#hastag1",
    "#hastag1"
  ];
  List<String> emojis = [
    "#hastag1",
    "#hastag1",
    "#hastag1",
    "#hastag1",
    "#hastag1",
  ];
  bool vis_status = true;
  bool _isLoading = true;
  bool yes = false;
  bool _hasMore = true;
  String dropdownValue = 'Captions';
  String emotion;
  _ItemFetcher fetcher = _ItemFetcher();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasMore = true;
    _getEmotion();
  }

  void _getEmotion() {
    print(widget.src);
    fetcher.fetchEmotion(widget.src).then((String resp) {
      print(resp);
      var r = JsonCodec().decode(resp.toString());
      print(r);
      emotion = r["result"];
      print(emotion);
      setState(() {
        yes = !yes;
      });
      _loadMoreCaptions();
    });
  }

  void _loadMoreCaptions() {
    fetcher.fetchCaptions(emotion).then((String resp) {
      var r = JsonCodec().decode(resp.toString());
      r = r["result"];
      if (r.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          for (var item in r) {
            if (captions.contains(item) == false) captions.add(item);
          }
        });
      }
    });
  }

  void _loadTags() {
    fetcher.fetchTags(emotion).then((String resp) {
      var r = JsonCodec().decode(resp.toString());
      r = r["result"];
      for (var i = 0; i < r.length; i++) {
        tags[i] = r[i];
      }
    });
  }

  void _loadEmojis() {
    fetcher.fetchEmoji(emotion).then((String resp) {
      var r = JsonCodec().decode(resp.toString());
      r = r["result"];
      for (var i = 0; i < r.length; i++) {
        emojis[i] = r[i]["emoji"];
      }
    });
  }

  void copyToClipboard(int index, List<String> array, BuildContext context) {
    Clipboard.setData(new ClipboardData(text: array[index]));
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Caption copied'),
      ),
    );
  }

  List<Widget> createTags(int start, int end, BuildContext context) {
    List<Widget> widgets = <Widget>[];
    _loadTags();
    for (int j = start; j < end; j++) {
      widgets.add(
        Expanded(
          flex: 2,
          child: Container(
            width: 150,
            child: FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () => this.copyToClipboard(j, tags, context),
              child: Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10.0, 15, 0.0),
                  child: Text(
                    "#${tags[j]}",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> createEmojis(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    _loadEmojis();
    for (int j = 0; j < 5; j++) {
      widgets.add(
        Expanded(
          flex: 2,
          child: Container(
            width: 150,
            child: FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () => this.copyToClipboard(j, tags, context),
              child: Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5.0, 15, 5.0),
                  child: Text(
                    "${emojis[j]}",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget build(BuildContext context) {
    var image = widget.image;
    //_getEmotion();
    if (yes) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              height: 330,
              child: Transform.translate(
                offset: Offset(52, 24),
                child: Material(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36.0),
                    bottomRight: Radius.circular(36.0),
                  ),
                  elevation: 10.0,
                  child: Transform.scale(
                    scale: 1.5,
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
            ),
            Column(
              children: [
                Transform.translate(
                  offset: Offset(15, 440),
                  child: Text(
                    "Top Suggestions",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-25, 430),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue,
                    ),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.blue),
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        vis_status = !vis_status;
                      });
                    },
                    items: <String>["Captions", "Hashtags"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: vis_status,
              child: Transform.translate(
                offset: Offset(0, 510),
                child: Container(
                  height: 250.0,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ListView.builder(
                    itemCount: _hasMore ? captions.length + 1 : captions.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= captions.length) {
                        if (!_isLoading) {
                          _loadMoreCaptions();
                        }
                        return Center(
                          child: SizedBox(
                            child: CircularProgressIndicator(),
                            height: 24,
                            width: 24,
                          ),
                        );
                      }
                      return Card(
                        color: Colors.grey[100],
                        margin: EdgeInsets.all(7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          title: Transform.translate(
                            offset: Offset(0, 5),
                            child: Text(
                              captions[index],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          trailing: Transform.translate(
                              offset: Offset(0, 0),
                              child: IconButton(
                                icon: Icon(Icons.content_copy),
                                onPressed: () {
                                  this.copyToClipboard(
                                      index, captions, context);
                                },
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !vis_status,
              child: Transform.translate(
                offset: Offset(0, 480),
                child: Container(
                  height: 250,
                  padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: this.createTags(0, 3, context),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: this.createTags(3, 6, context),
                      ),
                      Transform.translate(
                        offset: Offset(-130, 10),
                        child: Text(
                          "Emojis",
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: this.createEmojis(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
