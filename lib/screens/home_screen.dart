import 'package:flutter/material.dart';
import 'package:gospel_stream/models/content_item.dart';
import 'package:gospel_stream/screens/video_detail_screen.dart';
import 'package:gospel_stream/services/app_state.dart';
import 'package:gospel_stream/widgets/glass_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.isLoading && state.content.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Gospel Stream...'),
          ],
        ),
      );
    }

    if (state.errorMessage != null && state.content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => state.initializeApp(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gospel Stream',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Watch, listen, read and share inspirational content.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          _buildSearch(context),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _sectionTitle('Trending videos'),
                const SizedBox(height: 14),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.videos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = state.videos[index];
                      return _mediaCard(context, item);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Music for worship'),
                const SizedBox(height: 14),
                Column(
                  children: state.music
                      .map((item) => _listTile(context, item))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Books & devotionals'),
                const SizedBox(height: 14),
                Column(
                  children: state.books
                      .map((item) => _listTile(context, item))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Live sessions'),
                const SizedBox(height: 14),
                ...state.content
                    .where((item) => item.isLive)
                    .map((item) => _liveCard(context, item)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search artists, songs, sermons...',
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

  Widget _mediaCard(BuildContext context, ContentItem item) {
    final state = context.read<AppState>();
    return GestureDetector(
      onTap: () {
        state.selectVideo(item.id);
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const VideoDetailScreen()));
      },
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: Image.network(
                    item.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.pinkAccent,
                            ),
                            const SizedBox(width: 6),
                            Text('${item.likes}'),
                          ],
                        ),
                        Text(
                          item.isLive
                              ? 'Live'
                              : '${item.duration.inMinutes} min',
                          style: TextStyle(
                            color: item.isLive
                                ? Colors.greenAccent
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listTile(BuildContext context, ContentItem item) {
    final state = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.thumbnailUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            item.author,
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Colors.white),
            onPressed: () {
              state.selectVideo(item.id);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VideoDetailScreen()),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _liveCard(BuildContext context, ContentItem item) {
    final state = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: const Icon(
            Icons.wifi_tethering,
            color: Colors.greenAccent,
            size: 32,
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            item.subtitle,
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              state.selectVideo(item.id);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VideoDetailScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Join'),
          ),
        ),
      ),
    );
  }
}
