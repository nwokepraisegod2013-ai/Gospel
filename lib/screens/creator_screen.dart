import 'package:flutter/material.dart';
import 'package:gospel_stream/widgets/glass_card.dart';

class CreatorScreen extends StatelessWidget {
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Creator Studio',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload videos, music, books and manage your audience.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _uploadCard(
                  context,
                  'Upload video',
                  'Share sermons, worship sessions, or Gospel stories',
                  Icons.videocam,
                ),
                const SizedBox(height: 16),
                _uploadCard(
                  context,
                  'Upload music',
                  'Add songs, devotionals, and audio messages',
                  Icons.music_note,
                ),
                const SizedBox(height: 16),
                _uploadCard(
                  context,
                  'Upload book',
                  'Publish devotionals and PDF resources',
                  Icons.menu_book,
                ),
                const SizedBox(height: 16),
                _insightsCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return GlassCard(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.2),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white10,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload content',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This demo shows the creator workflow. Connect a real upload service for production.',
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Start upload'),
                    ),
                  ],
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Create'),
        ),
      ),
    );
  }

  Widget _insightsCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Creator insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('Views'), Text('12.4K')],
            ),
            const Divider(color: Colors.white12, height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('New followers'), Text('1.1K')],
            ),
            const Divider(color: Colors.white12, height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('Live sessions'), Text('8')],
            ),
          ],
        ),
      ),
    );
  }
}
