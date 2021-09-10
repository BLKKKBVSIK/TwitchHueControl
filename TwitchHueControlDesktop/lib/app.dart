import 'package:flutter/material.dart';
import 'package:twitch_hue_control_desktop/ui/homepage/homepage.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitch Hue Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TwitchHueControl(),
    );
  }
}
