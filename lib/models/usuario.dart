/// Un usuario tal como lo devuelve la API (nunca trae la contraseña).
class Usuario {
  static const String rolAdmin = 'ADMIN';
  static const String rolReviewer = 'REVIEWER';
  static const String rolMember = 'MEMBER';

  final String id;
  final String username;
  final String name;
  final String email;
  final String role;
  final String status;

  const Usuario({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  bool get esAdmin => role == rolAdmin;

  /// Convierte el JSON de la API en un objeto Usuario (lo que hacía Gson en el Corte 3).
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  /// Lo contrario: objeto a JSON, para guardarlo en la sesión.
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'email': email,
        'role': role,
        'status': status,
      };
}
