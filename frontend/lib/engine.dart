// engine.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = dotenv.env['BASE_URL'] ?? "https://no-url.ngrok-free.app";

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

Future<Map<String, dynamic>> continuarHistoriaConOpciones(
  String nombre,
  String historiaActual,
  String eleccion, {
  required int interaccionActual,
  required int interaccionesTotales,
}) async {
  final Uri url = Uri.parse("$baseUrl/continuar");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "nombre": nombre,
      "historia": historiaActual,
      "opcion": eleccion,
      "interaccion_actual": interaccionActual,
      "interacciones_totales": interaccionesTotales,
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
