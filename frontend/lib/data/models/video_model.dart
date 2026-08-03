/// Modelo para videos en la biblioteca
class VideoModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String videoId;
  final String category;
  final int? duration;
  final int views;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VideoModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.videoId,
    required this.category,
    this.duration,
    this.views = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      videoId: json['video_id'],
      category: json['category'],
      duration: json['duration'],
      views: json['views'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_id': videoId,
      'category': category,
      'duration': duration,
      'views': views,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}