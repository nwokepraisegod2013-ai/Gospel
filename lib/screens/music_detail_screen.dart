import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:gospel_stream/models/content_item.dart';
import 'package:gospel_stream/services/app_state.dart';
import 'package:gospel_stream/widgets/glass_card.dart';
import 'package:provider/provider.dart';

class MusicDetailScreen extends StatefulWidget {
  const MusicDetailScreen({super.key});

  @override
  State<MusicDetailScreen> createState() => _MusicDetailScreenState();
}

class _MusicDetailScreenState extends State<MusicDetailScreen> {
  late final AudioPlayer _player;
  final TextEditingController _commentController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      state.refreshChat();
      _initializeAudio(state.currentVideo);
    });
  }

  Future<void> _initializeAudio(ContentItem? content) async {
    final url = content?.contentUrl;
    if (url == null || url.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      await _player.setUrl(url);
    } catch (e) {
      debugPrint('Audio load failed: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final content = state.currentVideo;

    if (content == null) {
      return const Scaffold(body: Center(child: Text('Content not available')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1724),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(content.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      content.thumbnailUrl,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(content.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(content.subtitle,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Chip(
                          label:
                              Text('${state.likedByVideo[content.id]} likes')),
                      const SizedBox(width: 10),
                      Chip(label: Text('${content.views} plays')),
                      const SizedBox(width: 10),
                      if (state.favorites.contains(content.id))
                        const Chip(label: Text('Favorite'))
                    ],
                  ),
                  const SizedBox(height: 20),
                  _playerSection(state, content),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Song features',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text(
                        content.description ??
                            'A powerful worship music track with joyful arrangements.',
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _featureChip('High-quality streaming'),
                        _featureChip('Share & save'),
                        _featureChip('Lyrics support'),
                        _featureChip('Playlist ready'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Comments',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: state.chat.isEmpty
                          ? const Center(
                              child: Text(
                                  'No comments yet. Start the conversation!',
                                  style: TextStyle(color: Colors.white54)),
                            )
                          : ListView.builder(
                              itemCount: state.chat.length,
                              itemBuilder: (context, index) {
                                final comment = state.chat[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blueGrey,
                                        child: Text(comment.author[0]),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(comment.author,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Text(
                                                  _formatTimestamp(
                                                      comment.timestamp),
                                                  style: const TextStyle(
                                                      color: Colors.white38,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(comment.message,
                                                style: const TextStyle(
                                                    color: Colors.white70)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            onSubmitted: (value) {
                              state.sendMessage(value);
                              _commentController.clear();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            state.sendMessage(_commentController.text);
                            _commentController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16)),
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerSection(AppState state, ContentItem content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final current = snapshot.data ?? Duration.zero;
              final total = _player.duration ?? content.duration;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: current.inSeconds
                        .toDouble()
                        .clamp(0, total.inSeconds.toDouble()),
                    max: total.inSeconds.toDouble().clamp(1, double.infinity),
                    onChanged: (value) =>
                        _player.seek(Duration(seconds: value.toInt())),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(current),
                          style: const TextStyle(color: Colors.white70)),
                      Text(_formatDuration(total),
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () =>
                  _player.setVolume((_player.volume - 0.1).clamp(0.0, 1.0)),
              icon: const Icon(Icons.volume_down, color: Colors.white),
            ),
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing = playerState?.playing ?? false;
                return CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white),
                    onPressed: () {
                      if (playing) {
                        _player.pause();
                      } else {
                        _player.play();
                      }
                    },
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () =>
                  _player.setVolume((_player.volume + 0.1).clamp(0.0, 1.0)),
              icon: const Icon(Icons.volume_up, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => state.toggleFavorite(content.id),
              icon: Icon(state.favorites.contains(content.id)
                  ? Icons.favorite
                  : Icons.favorite_border),
              label: const Text('Favorite'),
            ),
            ElevatedButton.icon(
              onPressed: () => state.addToPlaylist(content.id),
              icon: const Icon(Icons.playlist_add),
              label: const Text('Add to playlist'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _featureChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white12,
      labelStyle: const TextStyle(color: Colors.white70),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
