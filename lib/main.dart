import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

import 'modules/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(
    const MaterialApp(
      home: HomePage(),
    ),
  );
}
