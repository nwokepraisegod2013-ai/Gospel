enum ContentType { video, music, book, live }

class ContentItem {
  final String id;
  final String title;
  final String subtitle;
  final ContentType type;
  final String? description;
  final String? category;
  final String? contentUrl;
  final String thumbnailUrl;
  final String author;
  final int likes;
  final int views;
  final bool isLive;
  final Duration duration;
  final DateTime? createdAt;

  ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.thumbnailUrl,
    required this.author,
    required this.likes,
    required this.views,
    required this.isLive,
    required this.duration,
    this.description,
    this.category,
    this.contentUrl,
    this.createdAt,
  });

  /// Parse from backend JSON response
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'video';
    final contentType = ContentType.values.firstWhere(
      (ct) => ct.name == typeStr,
      orElse: () => ContentType.video,
    );

    final durationMs = json['duration'] as int? ?? 0;
    final durationValue = Duration(milliseconds: durationMs);

    final author = json['author'] is Map
        ? (json['author'] as Map<String, dynamic>)['name'] ?? 'Unknown'
        : json['author'] ?? 'Unknown';

    return ContentItem(
      id: json['_id'] as String? ?? json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      type: contentType,
      description: json['description'] as String?,
      category: json['category'] as String?,
      contentUrl: json['contentUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      author: author.toString(),
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      isLive: json['isLive'] as bool? ?? false,
      duration: durationValue,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'type': type.name,
        'description': description,
        'category': category,
        'thumbnailUrl': thumbnailUrl,
        'contentUrl': contentUrl,
        'duration': duration.inMilliseconds,
        'isLive': isLive,
      };
}
