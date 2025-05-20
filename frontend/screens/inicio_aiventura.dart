// screens/inicio_cuento.dart

import 'package:flutter/material.dart';
import '../engine.dart';

class InicioCuentoScreen extends StatefulWidget {
  final String userName;
  final int interacciones;

  const InicioCuentoScreen({super.key, required this.userName, required this.interacciones});

  @override
  State<InicioCuentoScreen> createState() => _InicioCuentoScreenState();
}

class _InicioCuentoScreenState extends State<InicioCuentoScreen> {
  final TextEditingController _lineaController = TextEditingController();
  String? _error;
  bool _cargando = false;
  String? _historia;
  List<String>? _opciones;

  Future<void> _enviarLinea() async {
    final linea = _lineaController.text.trim();
    if (linea.isEmpty) {
      setState(() => _error = "Por favor escribe una idea para comenzar.");
      return;
    }

    setState(() {
      _error = null;
      _cargando = true;
      _historia = null;
      _opciones = null;
    });

    try {
      final resultado = await generarHistoriaConOpciones(widget.userName, linea);

      setState(() {
        _historia = resultado['historia'];
        _opciones = resultado['opciones'];
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _historia = "Ocurrió un error: $e";
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tu cuento comienza")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Hola ${widget.userName}, escribe la primera línea de tu cuento:"),
              const SizedBox(height: 20),
              TextField(
                controller: _lineaController,
                decoration: const InputDecoration(hintText: "Ej. Mi perro vio un duende..."),
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _enviarLinea,
                child: const Text("Continuar"),
              ),
              const SizedBox(height: 30),
              if (_cargando) const CircularProgressIndicator(),
              if (_historia != null) ...[
                const Text("Primera parte de tu cuento:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(_historia!),
              ],
              const SizedBox(height: 20),
              if (_opciones != null)
                Column(
                  children: _opciones!.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final opcion = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Elegiste la opción $index')),
                          );
                        },
                        child: Text("Opción $index: $opcion"),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
