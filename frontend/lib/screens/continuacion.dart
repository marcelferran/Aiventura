// lib/screens/continuacion.dart

import 'package:flutter/material.dart';
import '../engine.dart';

class ContinuacionCuentoScreen extends StatefulWidget {
  final String userName;
  final String historiaActual;
  final String eleccion;
  final int interaccionesTotales;
  final int interaccionActual;

  const ContinuacionCuentoScreen({
    super.key,
    required this.userName,
    required this.historiaActual,
    required this.eleccion,
    required this.interaccionesTotales,
    required this.interaccionActual,
  });

  @override
  State<ContinuacionCuentoScreen> createState() => _ContinuacionCuentoScreenState();
}

class _ContinuacionCuentoScreenState extends State<ContinuacionCuentoScreen> {
  bool _cargando = true;
  String? _nuevaHistoria;
  List<String>? _nuevasOpciones;
  String? _error;

  @override
  void initState() {
    super.initState();
    _continuarHistoria();
  }

  Future<void> _continuarHistoria() async {
    try {
      final resultado = await continuarHistoriaConOpciones(
        widget.userName,
        widget.historiaActual,
        widget.eleccion,
      );

      setState(() {
        _nuevaHistoria = resultado['historia'];
        _nuevasOpciones = resultado['opciones'];
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error al continuar la historia: $e";
        _cargando = false;
      });
    }
  }

  void _seleccionarSiguiente(String opcionElegida) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContinuacionCuentoScreen(
          userName: widget.userName,
          historiaActual: _nuevaHistoria!,
          eleccion: opcionElegida,
          interaccionesTotales: widget.interaccionesTotales,
          interaccionActual: widget.interaccionActual + 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Parte ${widget.interaccionActual} de ${widget.interaccionesTotales}")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Continuación de tu historia:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(_nuevaHistoria!),
                        const SizedBox(height: 30),
                        if (_nuevasOpciones != null)
                          Column(
                            children: _nuevasOpciones!.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final opcion = entry.value;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: () => _seleccionarSiguiente(opcion),
                                  child: Text("Opción $index: $opcion"),
                                ),
                              );
                            }).toList(),
                          )
                      ],
                    ),
                  ),
      ),
    );
  }
}
