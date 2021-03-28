import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image/image.dart' as img;

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';


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
          editor = ImageEditor(image: image);//, photo: img.decodeImage(data));
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
          backgroundColor: Color(0xFF444444),
        ),
        body: ListView(
          children: <Widget>[
          PlutoMenuBarDemo(scaffoldKey: globalKey,
            openButton: () => this.openButton(),
            saveButton: () => this.saveButton(),
            filterButton: (String text) => this.filterButton(text),
            
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CustomPaint(
              key: globalKey,
              painter:  editor,
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
    //this.photo,
  });

  void setFilter(String ifilter) {
    filterCurr = ifilter;
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

    if (filterCurr == 'filter1') {
      painter.invertColors = true;
      canvas.drawImage(image,  Offset(0.0, 0.0),  painter);
      canvasRecorder.drawImage(image,  Offset(0.0, 0.0),  painter);
    }

    else if (filterCurr == 'filter2') {
      painter.imageFilter = ui.ImageFilter.blur(sigmaX: image.width/500, sigmaY: image.height/500);
      canvas.drawImage(image,  Offset(0.0, 0.0),  painter);
      canvasRecorder.drawImage(image,  Offset(0.0, 0.0),  painter);
    }

    else if (filterCurr == 'filter3') {

      for (int i=0; i<photo.width; i++) {
        for (int j=0; j<photo.height; j++) {
          int abgr = photo.getPixel(i, j);
          painter.color = Color(abgr);
          canvas.drawPoints(ui.PointMode.points, [Offset(i/1,j/1)], painter);
          canvasRecorder.drawPoints(ui.PointMode.points, [Offset(i/1,j/1)], painter);
          
        }
      }

    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

class PlutoMenuBarDemo extends StatelessWidget {
  final scaffoldKey;
  final void Function() openButton;
  final void Function() saveButton;
  final void Function(String) filterButton;

  PlutoMenuBarDemo({
    this.scaffoldKey,
    this.openButton,
    this.saveButton,
    this.filterButton,
  });

  void message(context, String text) {
    if (text == 'Open') {
      print('open button');
      openButton();
    }
    else if (text == 'Save') {
      print('save button');
      saveButton();
    }
    else if (text == 'filter1') {
      print('filter1 button');
      filterButton(text);
    }
    else if (text == 'filter2') {
      print('filter2 button');
      filterButton(text);
    }
    else if (text == 'filter3') {
      print('filter3 button');
      filterButton(text);
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    

    final snackBar = SnackBar(
      content: Text(text),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  List<MenuItem> getMenus(BuildContext context) {
    return [
      MenuItem(
        title: 'Open',
        icon: Icons.folder_open,
        onTap: () => message(context, 'Open'),
      ),
      MenuItem(
        title: 'Save',
        icon: Icons.save,
        onTap: () => message(context, 'Save'),
      ),
      MenuItem(
        title: 'Tools',
        icon: Icons.apps_outlined,
        onTap: () => message(context, 'Tools'),
        children: [
          MenuItem(
            title: 'tool1',
            onTap: () => message(context, 'tool1'),
          ),
          MenuItem(
            title: 'tool2',
            onTap: () => message(context, 'tool2'),
          ),
        ],
      ),
      MenuItem(
        title: 'Filters',
        icon: Icons.science,
        children: [
          MenuItem(
            title: 'filter1',
            onTap: () => message(context, 'filter1'),
          ),
          MenuItem(
            title: 'filter2',
            onTap: () => message(context, 'filter2'),
          ),
          MenuItem(
            title: 'filter3',
            onTap: () => message(context, 'filter3'),
          ),
        ],
      ),
      MenuItem(
        title: 'Menu 5',
        onTap: () => message(context, 'Menu 5 tap'),
      ),
      MenuItem(
        title: 'Menu 6',
        children: [
          MenuItem(
            title: 'Menu 6-1',
            onTap: () => message(context, 'Menu 6-1 tap'),
          ),
          MenuItem(
            title: 'Menu 6-2',
            onTap: () => message(context, 'Menu 6-2 tap'),
          ),
        ],
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