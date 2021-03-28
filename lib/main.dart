import 'package:flutter/material.dart';

import 'package:splashscreen/splashscreen.dart';

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
      image: new Image.asset('assets/Logo5.png'), // #1b0753
      backgroundColor: Colors.black87,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 120.0,
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

  @override
  void initState() {
    super.initState();
  }

  Container imzButton(String itext, Color icolor, IconData iicon) {
    return Container(
      width: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.2,
        decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            spreadRadius: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.005,
            blurRadius: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.005,
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.25),
          bottomRight: Radius.circular(25.25)),
        border: Border(
          top: BorderSide(width: 1.0, color: icolor),
          left: BorderSide(width: 1.0, color: icolor),
          right: BorderSide(width: 1.0, color: icolor),
          bottom: BorderSide(width: 1.0, color: icolor),
        ),
      ),
      child:  Column(
        children: [
          Container(
            width: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.15,
            height: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.1,
            child: IconButton(
              iconSize: 50,
              icon: Icon(iicon),
              color: icolor,
              onPressed: () { },
            ),
          ),
          Text(
            itext,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: icolor),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return  Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar( // Here we create one to set status bar color
            backgroundColor: Colors.black, // Set any color of status bar you want; or it defaults to your theme's primary color
          )
        ),
      body: ListView(
        children: <Widget>[
          
        Container(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.1,
          decoration: BoxDecoration(
            color: Colors.black54,
            image: const DecorationImage(
              image: AssetImage('assets/Logo5.png'),
              scale: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black87.withOpacity(0.7),
                spreadRadius: 10,
                blurRadius: 10,
              ),
            ],
          ),
        ),

        
        Container(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.75,
          color: Colors.black87,
        ),

        Container(
          height: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.15,
          decoration: BoxDecoration(
            color: Colors.black54.withOpacity(0),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                spreadRadius: 10,
                blurRadius: 10,
              ),
            ],
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              imzButton('New Image', Colors.blueGrey.shade700, Icons.photo),
              Container(width: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.02),
              imzButton('Quick Save', Colors.blueAccent.shade700, Icons.save),
              Container(width: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.02),
              imzButton('Apply Filters', Colors.lightBlueAccent.shade700, Icons.science),
              Container(width: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.02),
              imzButton('Pro-Editor', Colors.brown.shade700, Icons.handyman),
              Container(width: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.02),
              imzButton('Compress <1MB', Colors.teal.shade700, Icons.save_alt),
            ],
          ),
        ),

      ]),
    );
  }
  @override
  Widget build(BuildContext context) {

    return  _buildImage(context);
  }
}
