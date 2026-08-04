import '../api/api_client.dart';

/// Sube archivos (portadas, PDFs) al backend y devuelve su URL pública.
/// Reemplaza a Supabase Storage.
class UploadService {
  final _api = ApiClient.instance;

  /// Sube los bytes de un archivo y devuelve la URL pública resultante.
  Future<String> uploadBook(List<int> bytes, String filename) {
    return _api.uploadFile(bytes, filename, folder: 'books');
  }

  Future<String> uploadCover(List<int> bytes, String filename) {
    return _api.uploadFile(bytes, filename, folder: 'covers');
  }
}
