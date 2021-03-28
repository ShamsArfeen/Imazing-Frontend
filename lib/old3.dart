import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:pluto_menu_bar/pluto_menu_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
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
    final pickedFile = await picker.getImage(source: ImageSource.gallery); // source can be camera
    if (pickedFile != null) {
      isImageloaded = false;
      final ByteData data = await rootBundle.load(pickedFile.path);
      image = await loadImage( Uint8List.view(data.buffer));
      editor= ImageEditor(image: image);
    }
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer =  Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    if (this.isImageloaded) {
      return  Scaffold(
        appBar: AppBar(
          title: Text('Imazing'),
          backgroundColor: Color(0xFF444444),
        ),
        body: ListView(children: <Widget>[
          PlutoMenuBarDemo(scaffoldKey: globalKey,
            openButton: (){
              openButton();
            },
          ),
          GestureDetector(
            onPanStart: (detailData){
              editor.down(detailData.localPosition);
              globalKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onPanUpdate: (detailData){
              editor.update(detailData.localPosition);
              globalKey.currentContext.findRenderObject().markNeedsPaint();
            },
            child: Container(
              width: 500,
              height: 700,
              child: CustomPaint(
                key: globalKey,
                painter:  editor,
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
          Center(child:  Text('loading')),
        ]),
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    return  _buildImage();
  }
}

class ImageEditor extends CustomPainter {

  ImageEditor({
    this.image,
  });

  ui.Image image;

  int curveCount = 0;
  double brushThickness = 2.5;
  List<List<Offset>> curve = List();

  final Paint painter = new Paint()
    ..color = Colors.blue[400]
    ..style = PaintingStyle.fill
    ..strokeWidth = 5;

  void down(Offset offset){
    List<Offset> tap = new List();
    curve.add(tap);
    curveCount += 1;
    curve[curveCount-1].add(offset);
  }
  void update(Offset offset){
    curve[curveCount-1].add(offset);
  }
  void end(){
    List<Offset> tap = new List();
    curve.add(tap);
    curveCount += 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image,  Offset(0.0, 0.0),  Paint());
    for(List<Offset> icurve in curve) {
      Offset start = icurve[0];
      canvas.drawCircle(start, 2, painter);
      for(Offset offset in icurve){
        canvas.drawLine(start, offset, painter);
        canvas.drawCircle(offset, brushThickness, painter);
        start = offset;
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
  void Function() openButton;

  PlutoMenuBarDemo({
    this.scaffoldKey,
    this.openButton,
  });

  void message(context, String text) {
    if (text == 'Open') {
      print('open button');
      openButton();
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
        onTap: () => message(context, 'Filters'),
        children: [
          MenuItem(
            title: 'filter1',
            onTap: () => message(context, 'filter1'),
          ),
          MenuItem(
            title: 'filter2',
            onTap: () => message(context, 'filter2'),
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