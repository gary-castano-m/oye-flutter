import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';
import 'session_service.dart';

/// Cliente único para hablar con la API de Render.
/// Junta lo que en el Corte 3 hacían RetrofitClient, AuthInterceptor y ApiCallback:
///  - arma la dirección completa,
///  - agrega `Authorization: Bearer <token>` a las peticiones privadas,
///  - espera hasta 70 s,
///  - y convierte los errores en mensajes en español.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();
  final SessionService _sesion = SessionService.instance;

  Future<dynamic> get(String ruta, {Map<String, String?>? query}) =>
      _enviar('GET', ruta, query: query);

  Future<dynamic> post(String ruta, {Object? body}) =>
      _enviar('POST', ruta, body: body);

  Future<dynamic> put(String ruta, {Object? body}) =>
      _enviar('PUT', ruta, body: body);

  Future<void> delete(String ruta) => _enviar('DELETE', ruta);

  /// Petición liviana para despertar Render mientras se ve el splash.
  Future<void> despertar() => _enviar('GET', 'v3/api-docs', decodificar: false);

  Future<dynamic> _enviar(
    String metodo,
    String ruta, {
    Map<String, String?>? query,
    Object? body,
    bool decodificar = true,
  }) async {
    // Los filtros vacíos o nulos no se envían (igual que @Query con null en Retrofit).
    final parametros = <String, String>{};
    query?.forEach((clave, valor) {
      if (valor != null && valor.trim().isNotEmpty) parametros[clave] = valor.trim();
    });
    var uri = Uri.parse('${ApiConfig.baseUrl}$ruta');
    if (parametros.isNotEmpty) uri = uri.replace(queryParameters: parametros);

    final peticion = http.Request(metodo, uri);
    peticion.headers['Accept'] = 'application/json';
    if (body != null) {
      peticion.headers['Content-Type'] = 'application/json; charset=utf-8';
      peticion.body = jsonEncode(body);
    }

    // Las rutas /api/auth/ son públicas: no llevan token.
    final token = await _sesion.leerToken();
    if (token != null && !ruta.startsWith('api/auth/')) {
      peticion.headers['Authorization'] = 'Bearer $token';
    }

    final reloj = Stopwatch()..start();
    final http.Response respuesta;
    try {
      final enviada = await _http.send(peticion).timeout(ApiConfig.timeout);
      respuesta = await http.Response.fromStream(enviada).timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder. Intenta de nuevo.');
    } catch (_) {
      throw const ApiException('No se pudo conectar con el servidor. Revisa tu conexión a internet.');
    }

    // Igual que el nivel BASIC del Corte 3: método, ruta, código y tiempo. Nunca el token.
    debugPrint('API $metodo /${uri.path.substring(1)} -> ${respuesta.statusCode} (${reloj.elapsedMilliseconds} ms)');

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      if (!decodificar || respuesta.bodyBytes.isEmpty) return null;
      return jsonDecode(utf8.decode(respuesta.bodyBytes));
    }
    throw ApiException(_mensajeDeError(respuesta), codigo: respuesta.statusCode);
  }

  /// Mismos mensajes que ApiCallback del Corte 3.
  static String _mensajeDeError(http.Response respuesta) {
    final mensajeApi = _leerMensajeDeLaApi(respuesta);
    switch (respuesta.statusCode) {
      case 400:
        return mensajeApi ?? 'Hay datos inválidos.';
      case 401:
        return mensajeApi ?? 'Tu sesión no es válida. Vuelve a iniciar sesión.';
      case 403:
        return 'No tienes permiso para hacer esto.';
      case 404:
        return 'No se encontró lo que buscas.';
      case 409:
        return mensajeApi ?? 'Ese dato ya existe.';
      default:
        if (respuesta.statusCode >= 500) {
          return 'El servidor tuvo un problema. Intenta más tarde.';
        }
        return 'Error ${respuesta.statusCode}';
    }
  }

  /// Lee {"status":..., "message":"..."} del cuerpo de error, si viene.
  static String? _leerMensajeDeLaApi(http.Response respuesta) {
    try {
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (datos is Map<String, dynamic>) {
        final mensaje = datos['message']?.toString().trim();
        if (mensaje != null && mensaje.isNotEmpty) return mensaje;
      }
    } catch (_) {
      // El cuerpo no era JSON: se usa el mensaje genérico.
    }
    return null;
  }
}
