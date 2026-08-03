import '../api/api_client.dart';
import '../models/support_request_model.dart';
import 'enum_converter.dart';

/// Servicio para gestionar solicitudes de soporte (vía API HTTP).
class SupportService {
  final _api = ApiClient.instance;

  /// Crea una nueva solicitud de soporte
  Future<bool> createRequest({
    required String title,
    required String description,
    required RequestType type,
  }) async {
    try {
      await _api.post('/support-requests', data: {
        'title': title,
        'description': description,
        'type': EnumConverter.requestTypeToString(type),
      });
      return true;
    } catch (e) {
      print('Error creating support request: $e');
      return false;
    }
  }

  /// Obtiene las solicitudes del usuario actual.
  /// El backend filtra automáticamente (staff ve todas, resto solo las suyas).
  Future<List<SupportRequest>> getUserRequests() async {
    try {
      final data = await _api.getList('/support-requests');
      return data.map(SupportRequest.fromJson).toList();
    } catch (e) {
      print('Error fetching user requests: $e');
      return [];
    }
  }

  /// Obtiene todas las solicitudes (el backend ya valida el rol).
  Future<List<SupportRequest>> getAllRequests() => getUserRequests();

  /// Igual que getAllRequests pero devuelve los mapas crudos (para UIs que
  /// leen `request['users']['name']`, etc.).
  Future<List<Map<String, dynamic>>> getAllRequestsRaw() async {
    try {
      return await _api.getList('/support-requests');
    } catch (e) {
      print('Error fetching requests (raw): $e');
      return [];
    }
  }

  /// Marca una solicitud como resuelta
  Future<bool> markAsResolved(String requestId) async {
    try {
      await _api.patch('/support-requests/$requestId');
      return true;
    } catch (e) {
      print('Error marking request as resolved: $e');
      return false;
    }
  }

  /// Elimina una solicitud
  Future<bool> deleteRequest(String requestId) async {
    try {
      await _api.delete('/support-requests/$requestId');
      return true;
    } catch (e) {
      print('Error deleting request: $e');
      return false;
    }
  }
}
