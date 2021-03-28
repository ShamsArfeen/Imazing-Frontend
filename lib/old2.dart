import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> docPaths;
  final picker = ImagePicker();
  File imagefile;

  void buttonpress() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery); // source can be camera
    if (pickedFile != null) {
      imagefile = File(pickedFile.path);

    } else {
      print('No image selected.');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var painterObj = OpenPainter();
    painterObj.setImage(imagefile);

    
    return Scaffold(
      appBar: AppBar(
        title: Text('hello world'),
        backgroundColor: Color(0xFF444444),
      ),
      body: ListView(children: <Widget>[
        Text(
          'hello world 2',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, height: 2),
        ),
        //Image.file(imagefile),

        Container(
          width: 100,
          height: 700,
          child: CustomPaint(
            painter: painterObj,
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: buttonpress,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class OpenPainter extends CustomPainter {
  File image;

  Future<ImageInfo> getImage(String path) async {
    Completer<ImageInfo> completer = Completer();
    var img = new NetworkImage(path);
    img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info,bool _){
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo;
  }

  void setImage(File arg) {
    image = arg;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff63aa65)
      ..strokeWidth = 1;
    //list of points
    var points = [Offset(50, 50),
      Offset(0, 0),
      Offset(380, 175),
      Offset(200, 175),
      Offset(150, 105),
      Offset(300, 75),
      Offset(320, 200),
      Offset(350, 390),
      Offset(89, 125)];
    //draw points on canvas
    Image timage = Image.file(image);
    //timage.
    canvas.drawImage(timage.image., Offset(0,0), paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}