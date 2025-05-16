// continuacion.dart — restaurado al estado funcional, PDF con DALL·E conservado

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ContinuacionScreen extends StatefulWidget {
  final String userName;
  final String historiaAcumulada;
  final String opcionSeleccionada;
  final int interaccionActual;
  final int interaccionesTotales;

  const ContinuacionScreen({
    super.key,
    required this.userName,
    required this.historiaAcumulada,
    required this.opcionSeleccionada,
    required this.interaccionActual,
    required this.interaccionesTotales,
  });

  @override
  State<ContinuacionScreen> createState() => _ContinuacionScreenState();
}

class _ContinuacionScreenState extends State<ContinuacionScreen> {
  String? _nuevaHistoria;
  List<String> _opciones = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _generarContinuacion();
  }

  Future<void> _generarContinuacion() async {
    setState(() => _cargando = true);

    final response = await http.post(
      Uri.parse("${dotenv.env['BASE_URL']}/continuar"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": widget.userName,
        "historia": widget.historiaAcumulada,
        "opcion": widget.opcionSeleccionada,
        "interaccion_actual": widget.interaccionActual,
        "interacciones_totales": widget.interaccionesTotales
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nuevaHistoria = data['historia'];
        _opciones = List<String>.from(data['opciones'] ?? []);
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
      throw Exception("Error al continuar historia");
    }
  }

  Future<void> _generarPDF() async {
    final response = await http.post(
      Uri.parse("${dotenv.env['BASE_URL']}/generar_pdf"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "titulo": "Mi cuento mágico",
        "autor": widget.userName,
        "historia": "${widget.historiaAcumulada}\n\n${_nuevaHistoria ?? ''}"
      }),
    );

    if (response.statusCode == 200) {
      final mensaje = jsonDecode(response.body)['mensaje'];
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("✅ PDF generado"),
            content: Text(mensaje),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
            ],
          ),
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("❌ Error"),
            content: Text("Error al generar el PDF: ${response.body}"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
            ],
          ),
        );
      }
    }
  }

  void _seleccionarOpcion(String opcionElegida) {
    final nuevaHistoriaAcumulada = "${widget.historiaAcumulada}\n\n${_nuevaHistoria ?? ''}";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContinuacionScreen(
          userName: widget.userName,
          historiaAcumulada: nuevaHistoriaAcumulada,
          opcionSeleccionada: opcionElegida,
          interaccionActual: widget.interaccionActual + 1,
          interaccionesTotales: widget.interaccionesTotales,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esFinal = _opciones.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Continuación del cuento")),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_nuevaHistoria != null)
                    Text(_nuevaHistoria!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  if (esFinal)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "🎉 Fin del cuento. ¡Esperamos que te haya gustado!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _generarPDF,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Generar cuento en PDF"),
                        )
                      ],
                    ),
                  if (!esFinal && _opciones.isNotEmpty)
                    ..._opciones.map(
                      (op) => ElevatedButton(
                        onPressed: () => _seleccionarOpcion(op),
                        child: Text(op),
                      ),
                    )
                ],
              ),
            ),
    );
  }
}