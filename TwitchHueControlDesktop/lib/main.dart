import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Twitch Hue Control');
    setWindowMinSize(const Size(1100, 700));
    setWindowMaxSize(Size.infinite);
  }
  runApp(const Application());
}
