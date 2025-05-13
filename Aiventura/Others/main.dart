// main.dart combinado con pantalla de bienvenida y colores personalizados

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AiventuraApp());
}

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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡Bienvenido a AIventura!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                'Crea cuentos mágicos ilustrados con ayuda de la inteligencia artificial. Presiona el botón para comenzar.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserInfoScreen(),
                    ),
                  );
                },
                child: const Text('Empezar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(title: const Text("Tu aventura empieza aquí")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("¿Cómo te llamas?", style: TextStyle(fontSize: 20)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Tu nombre'),
            ),
            const SizedBox(height: 20),
            const Text("¿Cuántos años tienes?", style: TextStyle(fontSize: 20)),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Tu edad'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final age = _ageController.text.trim();
                if (name.isNotEmpty && age.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractionCountScreen(userName: name),
                    ),
                  );
                }
              },
              child: const Text("Continuar"),
            )
          ],
        ),
      ),
    );
  }
}

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

Future<String> obtenerIntroduccion(String nombre, int interacciones) async {
  const String apiUrl = "https://f173-35-236-208-235.ngrok-free.app/introduccion";

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "nombre": nombre,
      "interacciones": interacciones,
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['mensaje'] ?? "Respuesta vacía.";
  } else {
    throw Exception('Error al obtener mensaje: ${response.body}');
  }
}

Future<Map<String, dynamic>> generarHistoriaConOpciones(String nombre, String inicioUsuario) async {
  const String apiUrl = "https://f173-35-236-208-235.ngrok-free.app/inicio";

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "nombre": nombre,
      "inicio": inicioUsuario,
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return {
      "historia": json['historia'],
      "opciones": List<String>.from(json['opciones']),
    };
  } else {
    throw Exception('Error generando historia: ${response.body}');
  }
}