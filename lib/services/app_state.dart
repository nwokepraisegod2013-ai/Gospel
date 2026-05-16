import 'package:flutter/material.dart';
import 'package:gospel_stream/models/chat_message.dart';
import 'package:gospel_stream/models/content_item.dart';
import 'package:gospel_stream/services/backend_service.dart';

class AppState extends ChangeNotifier {
  int selectedIndex = 0;
  String selectedVideoId = 'video_1';
  bool isLoading = false;
  String? errorMessage;

  final List<ContentItem> content = [
    ContentItem(
      id: 'video_1',
      title: 'Worship Night Live',
      subtitle: 'Praise and devotion from the Gospel family',
      type: ContentType.video,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=900&q=80',
      author: 'Faith Media',
      likes: 2580,
      views: 16000,
      isLive: true,
      duration: const Duration(minutes: 90),
    ),
    ContentItem(
      id: 'music_1',
      title: 'Hope & Harmony',
      subtitle: 'Contemporary gospel worship mix',
      type: ContentType.music,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1511376777868-611b54f68947?auto=format&fit=crop&w=900&q=80',
      author: 'Blessed Voices',
      likes: 1420,
      views: 8200,
      isLive: false,
      duration: const Duration(minutes: 4, seconds: 20),
    ),
    ContentItem(
      id: 'book_1',
      title: 'Grace Through Psalms',
      subtitle: 'Devotional reflections for daily growth',
      type: ContentType.book,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1529655683826-aba9b3e77383?auto=format&fit=crop&w=900&q=80',
      author: 'Anna Bright',
      likes: 890,
      views: 3300,
      isLive: false,
      duration: const Duration(minutes: 0),
    ),
    ContentItem(
      id: 'live_1',
      title: 'Sunday Prayer Room',
      subtitle: 'Join the family live from Lagos',
      type: ContentType.live,
      thumbnailUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
      author: 'Global Church',
      likes: 460,
      views: 2400,
      isLive: true,
      duration: const Duration(minutes: 120),
    ),
  ];

  final List<ChatMessage> chat = [
    ChatMessage(
      id: 'c1',
      author: 'Miriam',
      message: 'Blessed worship!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ChatMessage(
      id: 'c2',
      author: 'Joseph',
      message: 'So inspiring 🔥',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  final Map<String, int> likedByVideo = {
    'video_1': 2580,
    'music_1': 1420,
    'book_1': 890,
    'live_1': 460,
  };

  void updateTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void selectVideo(String id) {
    selectedVideoId = id;
    notifyListeners();
  }

  ContentItem? get currentVideo => content.firstWhere(
        (item) => item.id == selectedVideoId,
        orElse: () => content.first,
      );

  List<ContentItem> get videos => content
      .where(
        (item) =>
            item.type == ContentType.video || item.type == ContentType.live,
      )
      .toList();
  List<ContentItem> get music =>
      content.where((item) => item.type == ContentType.music).toList();
  List<ContentItem> get books =>
      content.where((item) => item.type == ContentType.book).toList();

  /// Initialize app: fetch content and chat from backend
  Future<void> initializeApp() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Fetch content from backend
      final backendContent = await BackendService.fetchContent();
      if (backendContent.isNotEmpty) {
        content.clear();
        content.addAll(backendContent);
        selectedVideoId = content.first.id;
      }
    } catch (e) {
      errorMessage = 'Failed to load content: $e';
      debugPrint('Error initializing app: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh chat for current video
  Future<void> refreshChat() async {
    try {
      final messages = await BackendService.fetchMessages(selectedVideoId);
      chat.clear();
      chat.addAll(messages);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching chat: $e');
    }
  }

  /// Like content with backend sync
  Future<void> toggleLike(String id) async {
    // Optimistic update
    likedByVideo[id] = (likedByVideo[id] ?? 0) + 1;
    notifyListeners();

    try {
      await BackendService.likeContent(id);
    } catch (e) {
      // Revert on error
      likedByVideo[id] = (likedByVideo[id] ?? 1) - 1;
      notifyListeners();
      debugPrint('Error liking content: $e');
    }
  }

  /// Send message with backend sync
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Optimistic update
    final tempMessage = ChatMessage(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      author: 'You',
      message: text.trim(),
      timestamp: DateTime.now(),
    );
    chat.add(tempMessage);
    notifyListeners();

    try {
      final sentMessage =
          await BackendService.postMessage(selectedVideoId, text.trim());
      // Replace temp message with real one
      final index = chat.indexOf(tempMessage);
      if (index >= 0) {
        chat[index] = sentMessage;
      }
    } catch (e) {
      // Remove temp message on error
      chat.remove(tempMessage);
      debugPrint('Error sending message: $e');
    }
    notifyListeners();
  }
}
