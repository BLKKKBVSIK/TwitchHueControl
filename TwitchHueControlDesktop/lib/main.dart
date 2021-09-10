import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitch Hue Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HueApplication(),
    );
  }
}

class HueApplication extends StatefulWidget {
  const HueApplication({Key? key}) : super(key: key);

  @override
  State<HueApplication> createState() => _HueApplicationState();
}

class _HueApplicationState extends State<HueApplication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.red,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.blue,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.green,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
