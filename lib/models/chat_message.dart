class ChatMessage {
  final String id;
  final String author;
  final String message;
  final DateTime timestamp;
  final String? authorAvatar;
  final String? contentId;

  ChatMessage({
    required this.id,
    required this.author,
    required this.message,
    required this.timestamp,
    this.authorAvatar,
    this.contentId,
  });

  /// Parse from backend JSON response
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map
        ? (json['author'] as Map<String, dynamic>)['name'] ?? 'Unknown'
        : json['author'] ?? 'Unknown';

    final authorAvatar = json['author'] is Map
        ? (json['author'] as Map<String, dynamic>)['avatar'] as String?
        : null;

    final timestamp = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'].toString())
        : json['timestamp'] != null
            ? DateTime.parse(json['timestamp'].toString())
            : DateTime.now();

    return ChatMessage(
      id: json['_id'] as String? ?? json['id'] ?? '',
      author: author.toString(),
      message: json['message'] ?? '',
      timestamp: timestamp,
      authorAvatar: authorAvatar,
      contentId: json['contentId'] as String?,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'contentId': contentId,
      };
}
