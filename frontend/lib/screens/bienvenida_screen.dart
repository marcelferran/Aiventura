import 'package:flutter/material.dart';
import 'inicio_aiventura.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  int _interacciones = 3;

  void _empezarCuento() {
    final nombre = _nombreController.text.trim();
    if (nombre.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => InicioCuentoScreen(
                userName: nombre,
                interacciones: _interacciones,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fondo = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF150050), Color(0xFF3F0071), Color(0xFF610094)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: fondo),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '¡Bienvenido a Aiventura!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '¿Cómo te llamas?',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Interacciones:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    DropdownButton<int>(
                      value: _interacciones,
                      dropdownColor: Colors.deepPurple.shade700,
                      style: const TextStyle(color: Colors.white),
                      items:
                          [3, 4, 5]
                              .map(
                                (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text('$i'),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _interacciones = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _empezarCuento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black87,
                  ),
                  child: const Text(
                    '¡Comenzar mi cuento!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
