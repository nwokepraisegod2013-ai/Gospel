import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gospel_stream/services/app_state.dart';
import 'package:gospel_stream/widgets/glass_card.dart';

class CreatorScreen extends StatelessWidget {
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isAuthenticated = state.isAuthenticated;

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
          Text(
            isAuthenticated
                ? 'Welcome back, ${state.currentUserDisplayName}. Manage uploads, audience tools, and performance insights in one place.'
                : 'Login to publish content, track performance, and grow your creator community.',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          _creatorStats(state),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _sectionTitle('Publish content'),
                const SizedBox(height: 14),
                _publishGrid(context),
                const SizedBox(height: 24),
                _sectionTitle('Studio tools'),
                const SizedBox(height: 14),
                if (!isAuthenticated) _authPrompt(context),
                _studioToolCard(
                  title: 'Release music & audio',
                  subtitle:
                      'Upload singles, albums, and devotional audio tracks.',
                  icon: Icons.music_note,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                _studioToolCard(
                  title: 'Content analytics',
                  subtitle:
                      'Measure views, likes, and audience growth across uploads.',
                  icon: Icons.bar_chart,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                _insightsCard(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _creatorStats(AppState state) {
    return Row(
      children: [
        _statBlock('Uploads', '${state.content.length}'),
        const SizedBox(width: 14),
        _statBlock(
          'Likes',
          '${state.likedByVideo.values.fold<int>(0, (sum, value) => sum + value)}',
        ),
        const SizedBox(width: 14),
        _statBlock('Chats', '${state.chat.length}'),
      ],
    );
  }

  Widget _statBlock(String title, String value) {
    return Expanded(
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  Widget _publishGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.92,
      children: [
        _publishCard(
          context,
          title: 'Video',
          subtitle: 'Share sermons, talks, and studio sessions.',
          icon: Icons.videocam,
          color: Colors.indigo,
          uploadType: 'video',
        ),
        _publishCard(
          context,
          title: 'Music',
          subtitle: 'Publish worship tracks and audio devotionals.',
          icon: Icons.music_note,
          color: Colors.pinkAccent,
          uploadType: 'music',
        ),
        _publishCard(
          context,
          title: 'Book',
          subtitle: 'Upload devotionals, ebooks, and study guides.',
          icon: Icons.menu_book,
          color: Colors.orange,
          uploadType: 'book',
        ),
        _publishCard(
          context,
          title: 'Live',
          subtitle: 'Schedule sessions and stream in real time.',
          icon: Icons.wifi_tethering,
          color: Colors.greenAccent,
          uploadType: 'video',
        ),
      ],
    );
  }

  Widget _publishCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String uploadType,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withAlpha((0.18 * 255).round()),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 18),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _showUploadSheet(context, uploadType),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: color,
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authPrompt(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white70),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Sign in to unlock creator publishing, analytics, and audience tools.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Go to Profile tab to login or register.')),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studioToolCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withAlpha((0.18 * 255).round()),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightsCard(AppState state) {
    final totalLikes =
        state.likedByVideo.values.fold<int>(0, (sum, value) => sum + value);
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
            _insightRow('Total uploads', '${state.content.length}'),
            const Divider(color: Colors.white12, height: 28),
            _insightRow('Total likes', '$totalLikes'),
            const Divider(color: Colors.white12, height: 28),
            _insightRow('Active chats', '${state.chat.length}'),
            const Divider(color: Colors.white12, height: 28),
            _insightRow('Live streams',
                '${state.content.where((item) => item.isLive).length}'),
          ],
        ),
      ),
    );
  }

  Widget _insightRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _showUploadSheet(BuildContext context, String uploadType) {
    final state = context.read<AppState>();
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final descriptionController = TextEditingController();
    final thumbnailController = TextEditingController();
    final contentUrlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 0.08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        var isSubmitting = false;
        String? submitError;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload ${uploadType[0].toUpperCase()}${uploadType.substring(1)}',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Ready to publish your latest creation? Fill the details and submit.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Colors.blueAccent.withAlpha((0.18 * 255).round()),
                          child: Icon(
                            uploadType == 'music'
                                ? Icons.music_note
                                : uploadType == 'book'
                                    ? Icons.menu_book
                                    : Icons.videocam,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Title is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: subtitleController,
                            decoration:
                                const InputDecoration(labelText: 'Subtitle'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: descriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: thumbnailController,
                            decoration: const InputDecoration(
                                labelText: 'Thumbnail URL'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Thumbnail URL is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: contentUrlController,
                            decoration:
                                const InputDecoration(labelText: 'Content URL'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Content URL is required'
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          if (submitError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                submitError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side:
                                        const BorderSide(color: Colors.white12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () async {
                                          if (!formKey.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          setModalState(() {
                                            isSubmitting = true;
                                            submitError = null;
                                          });

                                          final navigator =
                                              Navigator.of(context);
                                          final messenger =
                                              ScaffoldMessenger.of(context);

                                          final success =
                                              await state.createContent(
                                            title: titleController.text.trim(),
                                            subtitle:
                                                subtitleController.text.trim(),
                                            description: descriptionController
                                                .text
                                                .trim(),
                                            type: uploadType,
                                            thumbnailUrl:
                                                thumbnailController.text.trim(),
                                            contentUrl: contentUrlController
                                                .text
                                                .trim(),
                                            duration: 10000,
                                          );

                                          if (success) {
                                            navigator.pop();
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${uploadType[0].toUpperCase()}${uploadType.substring(1)} uploaded successfully',
                                                ),
                                              ),
                                            );
                                          } else {
                                            setModalState(() {
                                              submitError =
                                                  state.errorMessage ??
                                                      'Upload failed';
                                              isSubmitting = false;
                                            });
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isSubmitting
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Publish'),
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
            );
          },
        );
      },
    );
  }
}
