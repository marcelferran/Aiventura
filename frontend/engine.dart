// engine.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "https://f173-35-236-208-235.ngrok-free.app";

Future<String> obtenerIntroduccion(String nombre, int interacciones) async {
  final response = await http.post(
    Uri.parse("$baseUrl/introduccion"),
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
  final response = await http.post(
    Uri.parse("$baseUrl/inicio"),
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
=======
// engine.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "https://f173-35-236-208-235.ngrok-free.app";


Future<String> obtenerIntroduccion(String nombre, int interacciones) async {
  final response = await http.post(
    Uri.parse("$baseUrl/introduccion"),
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
  final response = await http.post(
    Uri.parse("$baseUrl/inicio"),
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

Future<Map<String, dynamic>> continuarHistoriaConOpciones(String nombre, String historiaActual, String eleccion) async {
  const String apiUrl = "https://TU_NGROK_URL.ngrok-free.app/continuar";

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "nombre": nombre,
      "historia": historiaActual,
      "opcion": eleccion,
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return {
      "historia": json['historia'],
      "opciones": List<String>.from(json['opciones']),
    };
  } else {
    throw Exception('Error al continuar historia: ${response.body}');
  }
}
