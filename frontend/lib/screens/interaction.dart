import 'package:flutter/material.dart';

class InteractionScreen extends StatelessWidget {
  final String historia;
  final List<String> opciones;
  final void Function(String) onSeleccion;

  const InteractionScreen({
    super.key,
    required this.historia,
    required this.opciones,
    required this.onSeleccion,
  });

  @override
  Widget build(BuildContext context) {
    final fondo = const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFF0F0C29),
        Color(0xFF302B63),
        Color(0xFF24243E),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("✨ Tu historia continua..."),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: fondo),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                historia,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¿Cómo deseas que continúe tu historia?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...opciones.map(
              (opcion) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => onSeleccion(opcion),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black38,
                  ),
                  child: Text(opcion),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
