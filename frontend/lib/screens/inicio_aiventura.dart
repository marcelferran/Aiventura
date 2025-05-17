
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'continuacion.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InicioCuentoScreen extends StatefulWidget {
  final String userName;
  final int interacciones;

  const InicioCuentoScreen({
    super.key,
    required this.userName,
    required this.interacciones,
  });

  @override
  State<InicioCuentoScreen> createState() => _InicioCuentoScreenState();
}

class _InicioCuentoScreenState extends State<InicioCuentoScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _cargando = false;

  Future<void> _enviarInicio() async {
    final inicio = _controller.text.trim();
    if (inicio.isEmpty) return;

    setState(() => _cargando = true);

    final baseUrl = dotenv.env['BASE_URL'];
    final url = Uri.parse('$baseUrl/inicio');

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': widget.userName,
          'inicio': inicio,
        }),
      );

      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);
        final historia = data['historia'];
        final opciones = List<String>.from(data['opciones']);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContinuacionScreen(
              userName: widget.userName,
              interacciones: widget.interacciones,
              historiaAcumulada: historia,
              opciones: opciones,
              interaccionActual: 1,
            ),
          ),
        );
      } else {
        _mostrarError("Error ${respuesta.statusCode}");
      }
    } catch (e) {
      _mostrarError("Falló la conexión con el servidor.");
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
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
        title: const Text("✍️ Comienza tu historia"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: fondo),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Hola ${widget.userName}, escribe el inicio de tu cuento:',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Érase una vez...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _cargando
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    onPressed: _enviarInicio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
