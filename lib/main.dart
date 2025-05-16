import 'package:administration_emergency/Presentation/Auth_Pages/LoginPage.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
   MediaKit.ensureInitialized();
  runApp(const MyApp());
   doWhenWindowReady(() {
    final win = appWindow;
    win.maximize(); // Start in full-screen mode
    win.alignment = Alignment.center;
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff0D3082)),
      ),
      home: Loginpage(),
    );
  }
}

