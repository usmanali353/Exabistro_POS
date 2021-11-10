import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin{
  GifController controller;

  @override
  void initState() {
    controller= GifController(vsync: this);
    controller.repeat(min: 0,max: 19,period: Duration(milliseconds: 5000));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: GifImage(
              controller: controller,
              image: AssetImage("assets/loading_gif.gif"),
            ),
          ),
          Center(
            child: Text("Loading...",style:TextStyle(fontSize: 30)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
