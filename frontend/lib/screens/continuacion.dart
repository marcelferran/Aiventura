
import 'package:flutter/material.dart';
import 'final_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ContinuacionScreen extends StatefulWidget {
  final String userName;
  final String historiaAcumulada;
  final List<String> opciones;
  final int interaccionActual;
  final int interacciones;

  const ContinuacionScreen({
    super.key,
    required this.userName,
    required this.historiaAcumulada,
    required this.opciones,
    required this.interaccionActual,
    required this.interacciones,
  });

  @override
  State<ContinuacionScreen> createState() => _ContinuacionScreenState();
}

class _ContinuacionScreenState extends State<ContinuacionScreen> {
  bool _cargando = false;

  void _seleccionarOpcion(String opcion) async {
    setState(() => _cargando = true);

    final baseUrl = dotenv.env['BASE_URL'];
    final url = Uri.parse('$baseUrl/continuar');

    final body = json.encode({
      'nombre': widget.userName,
      'historia': widget.historiaAcumulada,
      'opcion': opcion,
      'interaccion_actual': widget.interaccionActual,
      'interacciones_totales': widget.interacciones
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nuevaHistoria = data['historia'] as String;
        final nuevasOpciones = List<String>.from(data['opciones']);

        final historiaCompleta = widget.historiaAcumulada + "\n\n" + nuevaHistoria;

        if (nuevasOpciones.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => FinalStoryScreen(
                historiaCompleta: historiaCompleta,
                onGenerarPDF: () {
                  final urlPDF = Uri.parse('$baseUrl/generar_pdf');
                  http.post(urlPDF,
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'historia': historiaCompleta,
                        'titulo': 'Mi cuento mágico',
                        'autor': widget.userName,
                      }));
                },
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ContinuacionScreen(
                userName: widget.userName,
                historiaAcumulada: historiaCompleta,
                opciones: nuevasOpciones,
                interaccionActual: widget.interaccionActual + 1,
                interacciones: widget.interacciones,
              ),
            ),
          );
        }
      } else {
        _mostrarError('Error ${response.statusCode}');
      }
    } catch (e) {
      _mostrarError('Error de conexión con el servidor.');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fondo = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3F0071), Color(0xFF150050)],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Parte ${widget.interaccionActual}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: fondo),
        padding: const EdgeInsets.all(24),
        child: _cargando
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.historiaAcumulada,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...widget.opciones.map((op) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () => _seleccionarOpcion(op),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          child: Text(op),
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}
