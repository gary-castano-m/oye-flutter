import 'usuario.dart';

/// Respuesta del login: el token JWT y los datos del usuario que entró.
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final Usuario user;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
      user: Usuario.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
