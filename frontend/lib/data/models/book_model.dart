/// Modelo para libros en la biblioteca
class BookModel {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String? coverUrl;
  final String fileUrl;
  final String? format;
  final List<String>? categories;
  final DateTime? publishedDate;
  final DateTime? createdAt;
  final String? createdBy;
  final String? category;
  final String? isbn;
  final int? year;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.coverUrl,
    required this.fileUrl,
    this.format,
    this.categories,
    this.publishedDate,
    this.createdAt,
    this.createdBy,
    this.category,
    this.isbn,
    this.year,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      coverUrl: json['cover_url'],
      fileUrl: json['file_url'],
      format: json['format'],
      categories: json['categories'] != null ? List<String>.from(json['categories']) : null,
      publishedDate: json['published_date'] != null ? DateTime.parse(json['published_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      createdBy: json['created_by'],
      category: json['category'],
      isbn: json['isbn'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'cover_url': coverUrl,
      'file_url': fileUrl,
      'format': format,
      'categories': categories,
      'published_date': publishedDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'category': category,
      'isbn': isbn,
      'year': year,
    };
  }
}

/// Formatos de archivo soportados
enum BookFormat { pdf, epub }