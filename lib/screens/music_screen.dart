import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gospel_stream/screens/music_detail_screen.dart';
import 'package:gospel_stream/services/app_state.dart';
import 'package:gospel_stream/widgets/glass_card.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Worship Music',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Curated gospel tracks and devotional audio, ready for listening and sharing.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          _buildSearch(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _sectionTitle('Top tracks'),
                const SizedBox(height: 14),
                Column(
                  children: state.music
                      .map((item) => _musicRow(context, item))
                      .toList(),
                ),
                const SizedBox(height: 24),
                _sectionTitle('Featured playlists'),
                const SizedBox(height: 14),
                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: state.music
                        .take(5)
                        .map((item) => _playlistCard(context, item))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return const GlassCard(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white70),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search worship songs, artists, playlists...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  Widget _musicRow(BuildContext context, item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              item.thumbnailUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(item.title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle:
              Text(item.author, style: const TextStyle(color: Colors.white70)),
          trailing: IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Colors.white),
            onPressed: () {
              context.read<AppState>().selectVideo(item.id);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const MusicDetailScreen(),
              ));
            },
          ),
        ),
      ),
    );
  }

  Widget _playlistCard(BuildContext context, item) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          context.read<AppState>().selectVideo(item.id);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const MusicDetailScreen(),
          ));
        },
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    item.thumbnailUrl,
                    width: double.infinity,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(item.author,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
