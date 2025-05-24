// path screens/intro_aiventura.dart

import 'package:flutter/material.dart';
import 'inicio_cuento.dart';

class IntroScreen extends StatelessWidget {
  final String mensaje;
  final String userName;
  final int interacciones;

  const IntroScreen({super.key, required this.mensaje, required this.userName, required this.interacciones});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(title: const Text("¡Tu historia comienza!")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mensaje, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InicioCuentoScreen(
                      userName: userName,
                      interacciones: interacciones,
                    ),
                  ),
                );
              },
              child: const Text("Escribir el inicio de mi cuento"),
            )
          ],
        ),
      ),
    );
  }
}
