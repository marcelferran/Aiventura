// screens/interaction.dart

import 'package:flutter/material.dart';
import '../engine.dart';
import 'intro.dart';

class InteractionCountScreen extends StatefulWidget {
  final String userName;
  const InteractionCountScreen({super.key, required this.userName});

  @override
  State<InteractionCountScreen> createState() => _InteractionCountScreenState();
}

class _InteractionCountScreenState extends State<InteractionCountScreen> {
  final _countController = TextEditingController();
  String? _error;

  void _proceed() async {
    final count = int.tryParse(_countController.text.trim());
    if (count == null || count < 3 || count > 5) {
      setState(() {
        _error = "Solo puedes elegir entre 3 y 5 interacciones.";
      });
      return;
    }

    final intro = await obtenerIntroduccion(widget.userName, count);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntroScreen(
          mensaje: intro,
          userName: widget.userName,
          interacciones: count,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(title: const Text("¿Cuántas interacciones quieres?")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Hola ${widget.userName}, ¿cuántas interacciones quieres en tu historia? (3 a 5)"),
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _proceed,
              child: const Text("Iniciar historia"),
            )
          ],
        ),
      ),
    );
  }
}
