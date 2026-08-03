import '../services/enum_converter.dart';

enum UserRole { admin, bibliotecario, profesor, lector }

/// Modelo para usuarios de la aplicación
class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: EnumConverter.parseUserRole(json['role']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Getters para verificar rol
  bool get isAdmin => role == UserRole.admin;
  bool get isBibliotecario => role == UserRole.bibliotecario;
  bool get isProfesor => role == UserRole.profesor;
  bool get isLector => role == UserRole.lector;
  
  // Permisos específicos
  bool get canUploadContent => isAdmin || isBibliotecario || isProfesor;
  bool get canDeleteContent => isAdmin || isBibliotecario;
  bool get canEditContent => isAdmin || isBibliotecario || isProfesor;  // ✅ Profesor puede editar
  bool get canManageUsers => isAdmin;
  bool get canViewStats => isAdmin || isBibliotecario;
}