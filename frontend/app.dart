<<<<<<< HEAD
// app.dart

import 'package:flutter/material.dart';
import 'screens/welcome.dart';

class AiventuraApp extends StatelessWidget {
  const AiventuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIventura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Comic Sans MS',
      ),
      home: const WelcomeScreen(),
    );
  }
=======
// app.dart

import 'package:flutter/material.dart';
import 'screens/welcome.dart';

class AiventuraApp extends StatelessWidget {
  const AiventuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIventura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Comic Sans MS',
      ),
      home: const WelcomeScreen(),
    );
  }
>>>>>>> 5ad1b3d80e97aa7485ad972537c33f044823b445
}