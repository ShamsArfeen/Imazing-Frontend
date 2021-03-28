import 'package:flutter/material.dart';

import 'package:imagebutton/imagebutton.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:image/image.dart' as img;

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';

void main(){
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 5,
      navigateAfterSeconds: new AfterSplash(),
      image: new Image.asset('assets/iceIMAZING.png'), // #1b0753
      backgroundColor: Colors.black87,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 150.0,
      loaderColor: Colors.blue.shade300
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() =>  _MyHomePageState();
}

GlobalKey<_MyHomePageState> globalKey = GlobalKey();

class _MyHomePageState extends State<MyHomePage> {
  ui.Image image;
  bool isImageloaded = true;
  final picker = ImagePicker();
  ImageEditor editor;

  void initState() {
    super.initState();
  }

  Future <Null> openButton() async {
    if (await Permission.photos.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    
      final pickedFile = await picker.getImage(source: ImageSource.gallery); // source can be camera
      if (pickedFile != null) {

        setState(() {
          isImageloaded = false;
        });
        final File imageFile = File(pickedFile.path);
        final Uint8List data = await imageFile.readAsBytes();
        image = await loadImage( data);

        setState(() {
          isImageloaded = true;
          editor = ImageEditor(image: image, photo: img.decodeImage(data));
        });
      } else {
        // User cancelled
      }
    }
  }

  Future <Null> saveButton() async {
    if (await Permission.storage.request().isGranted) {
      final picture = editor.recorder.endRecording();
      final ui.Image img = await picture.toImage(
        (editor.image.width * editor.scale).round(), 
        (editor.image.height * editor.scale).round());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final result =
          await ImageGallerySaver.saveImage(pngBytes.buffer.asUint8List());
      print(result);
    }
  }

  void filterButton(String filter) {
    // sets filterCurr = filter
    
    editor.setFilter(filter);
    globalKey.currentContext.findRenderObject().markNeedsPaint();
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer =  Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage(BuildContext context) {

    if (this.isImageloaded) {
      return  Scaffold(
        appBar: AppBar(
          title: Text('Imazing'),
          backgroundColor: Colors.black87.withOpacity(0.5),
        ),

        body: ListView(
          children: <Widget>[   

          Container(
            width: MediaQuery.of(context).size.width,
            height: (MediaQuery.of(context).size.height - 80)/2,
            color: Colors.black87,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Add a Picture to start',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),

          Container(
            width: MediaQuery.of(context).size.width,
            height: (MediaQuery.of(context).size.height - 80)/2,
            color: Colors.black87,
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.25),
                        bottomRight: Radius.circular(25.25)),
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.white),
                        left: BorderSide(width: 1.0, color: Colors.white),
                        right: BorderSide(width: 1.0, color: Colors.white),
                        bottom: BorderSide(width: 1.0, color: Colors.white),
                      ),
                    ),
                    child: IconButton(
                      iconSize: 50,
                      icon: const Icon(Icons.camera_alt),
                      tooltip: 'Take a new picture',
                      color: Colors.white,
                      onPressed: () { },
                    ),
                  ),
                  
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.25),
                        bottomRight: Radius.circular(25.25)),
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.white),
                        left: BorderSide(width: 1.0, color: Colors.white),
                        right: BorderSide(width: 1.0, color: Colors.white),
                        bottom: BorderSide(width: 1.0, color: Colors.white),
                      ),
                    ),
                    child: IconButton(
                      iconSize: 50,
                      icon: const Icon(Icons.photo),
                      tooltip: 'Open a saved photo',
                      color: Colors.white,
                      onPressed: () { },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    } else {  
      return  Scaffold(
        appBar: AppBar(
          title: Text('Imazing'),
          backgroundColor: Color(0xFF444444),
        ),
        body: ListView(children: <Widget>[
          PlutoMenuBarDemo(scaffoldKey: globalKey),
          Center(child:  Text('loading ...')),
        ]),
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    return  _buildImage(context);
  }
}

class ImageEditor extends CustomPainter {

  double scale;
  int curveCount = 0;
  String filterCurr = '';
  List<List<Offset>> curve = List();
  
  ui.Image image;
  img.Image photo;
  ui.PictureRecorder recorder;
  Canvas canvasRecorder;

  final Float64List transformMatrix = Float64List.fromList(
    [ 1, 0, 0, 0, 
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1]);

  ImageEditor({
    this.image,
    this.photo,
  });

  void setFilter(String ifilter) {
    filterCurr = ifilter;
  }

  int abgrToArgb(int argbColor) {
    int r = 0; //(argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  @override
  void paint(Canvas canvas, Size size) {

    double x = globalKey.currentContext.size.width / image.width;
    double y = globalKey.currentContext.size.height / image.height;

    recorder = new ui.PictureRecorder();
    canvasRecorder = new Canvas(recorder);

    if (x > y) {
      scale = y;
    } else {
      scale = x;
    }

    canvas.scale(scale, scale);
    canvasRecorder.scale(scale, scale);

    Paint painter = new Paint();

    if (filterCurr == 'Invert') {
      painter.invertColors = true;
      canvas.drawImage(image,  Offset(0.0, 0.0),  painter);
      canvasRecorder.drawImage(image,  Offset(0.0, 0.0),  painter);
    }

    else if (filterCurr == 'Blur') {
      painter.imageFilter = ui.ImageFilter.blur(sigmaX: image.width/200, sigmaY: image.height/200);
      canvas.drawImage(image,  Offset(0.0, 0.0),  painter);
      canvasRecorder.drawImage(image,  Offset(0.0, 0.0),  painter);
    }

    else if (filterCurr == 'Antired') {

      canvas.scale(1/scale, 1/scale);
      canvasRecorder.scale(1/scale, 1/scale);

      painter.strokeWidth = 1;
      for (int i=0; i<photo.width*scale; i++) {
        for (int j=0; j<photo.height*scale; j++) {

          int abgr = photo.getPixel((i/scale).round(), (j/scale).round());
          painter.color = Color(abgrToArgb(abgr));
          canvas.drawPoints(ui.PointMode.points, [Offset(i/1,j/1)], painter);
          canvasRecorder.drawPoints(ui.PointMode.points, [Offset(i/1,j/1)], painter);
          
        }
      }
    }
    else {
      canvas.drawImage(image,  Offset(0.0, 0.0),  painter);
      canvasRecorder.drawImage(image,  Offset(0.0, 0.0),  painter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

class PlutoMenuBarDemo extends StatelessWidget {
  final scaffoldKey;

  PlutoMenuBarDemo({
    this.scaffoldKey,
  });

  void message(context, String text) {
    scaffoldKey.currentState.hideCurrentSnackBar();
    

    final snackBar = SnackBar(
      content: Text(text),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  List<MenuItem> getMenus(BuildContext context) {
    return [
      MenuItem(
        title: 'Save As',
        icon: Icons.save,
        onTap: () => message(context, 'Open'),
      ),
      MenuItem(
        title: 'Use Editor',
        icon: Icons.apps_outlined,
        onTap: () => message(context, 'Save'),
      ),
      MenuItem(
        title: 'Filters',
        icon: Icons.science,
        onTap: () => message(context, 'Tools'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          PlutoMenuBar(
            menus: getMenus(context),
          ),
        ],
      ),
    );
  }
}