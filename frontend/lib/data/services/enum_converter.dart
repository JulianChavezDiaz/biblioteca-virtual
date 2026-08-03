import '../models/user_model.dart';
import '../models/support_request_model.dart';

/// Utilidades para conversión de enums
class EnumConverter {
  /// Convierte string a UserRole
  static UserRole parseUserRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'bibliotecario':
        return UserRole.bibliotecario;
      case 'profesor':
        return UserRole.profesor;
      case 'lector':
      default:
        return UserRole.lector;
    }
  }

  /// Convierte UserRole a string
  static String userRoleToString(UserRole role) {
    return role.toString().split('.').last;
  }

  /// Convierte string a RequestType
  static RequestType parseRequestType(String? type) {
    switch (type) {
      case 'ayuda':
        return RequestType.ayuda;
      case 'configuracion':
        return RequestType.configuracion;
      case 'reporte':
        return RequestType.reporte;
      case 'otro':
      default:
        return RequestType.otro;
    }
  }

  /// Convierte RequestType a string
  static String requestTypeToString(RequestType type) {
    return type.toString().split('.').last;
  }

  /// Convierte string a RequestStatus
  static RequestStatus parseRequestStatus(String? status) {
    switch (status) {
      case 'resuelto':
        return RequestStatus.resuelto;
      case 'pendiente':
      default:
        return RequestStatus.pendiente;
    }
  }

  /// Convierte RequestStatus a string
  static String requestStatusToString(RequestStatus status) {
    return status.toString().split('.').last;
  }
}
