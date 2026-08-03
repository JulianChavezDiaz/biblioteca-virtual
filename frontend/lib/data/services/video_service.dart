import '../api/api_client.dart';

/// Acceso a videos vía API HTTP (mapas snake_case compatibles con VideoModel).
class VideoService {
  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getVideos({
    String? search,
    String? category,
  }) async {
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (category != null && category.isNotEmpty) query['category'] = category;
    try {
      return await _api.getList('/videos', query: query);
    } catch (e) {
      print('Error fetching videos: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getVideo(String id) async {
    try {
      return await _api.getMap('/videos/$id');
    } catch (e) {
      print('Error fetching video $id: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createVideo(Map<String, dynamic> data) async {
    final res = await _api.post('/videos', data: data);
    return Map<String, dynamic>.from(res as Map);
  }

  Future<void> updateVideo(String id, Map<String, dynamic> data) async {
    await _api.put('/videos/$id', data: data);
  }

  Future<void> deleteVideo(String id) async {
    await _api.delete('/videos/$id');
  }
}
