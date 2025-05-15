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
}