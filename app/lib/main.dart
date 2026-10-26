import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/auth_repository.dart';
import 'data/evidence_repository.dart';
import 'data/story_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KindredApp());
}

class KindredApp extends StatefulWidget {
  const KindredApp({super.key});

  @override
  State<KindredApp> createState() => _KindredAppState();
}

class _KindredAppState extends State<KindredApp> {
  ThemeMode _themeMode = ThemeMode.light;

  static const parchment = Color(0xfff5ecdd);
  static const ink = Color(0xff173b43);
  static const terracotta = Color(0xffc8543d);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kindred',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ink, primary: ink, secondary: terracotta, surface: parchment),
        useMaterial3: true,
        scaffoldBackgroundColor: parchment,
        fontFamily: 'Avenir',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontFamily: 'Georgia', color: ink),
          headlineSmall: TextStyle(fontFamily: 'Georgia', color: ink),
          titleLarge: TextStyle(fontFamily: 'Georgia', color: ink),
          titleMedium: TextStyle(color: ink),
          bodyLarge: TextStyle(color: Color(0xff38545a)),
        ),
        cardTheme: CardThemeData(color: Color(0xfffffbf4), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18)))),
        navigationBarTheme: const NavigationBarThemeData(backgroundColor: Color(0xfffffbf4), indicatorColor: Color(0xffdbe6df)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff9fc6a7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Avenir',
        scaffoldBackgroundColor: const Color(0xff101d20),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontFamily: 'Georgia', color: Color(0xfff5f1e8)),
          headlineSmall: TextStyle(fontFamily: 'Georgia', color: Color(0xfff5f1e8)),
          titleLarge: TextStyle(fontFamily: 'Georgia', color: Color(0xfff5f1e8)),
          titleMedium: TextStyle(color: Color(0xfff5f1e8)),
          bodyLarge: TextStyle(color: Color(0xffe2e9e5)),
          bodyMedium: TextStyle(color: Color(0xffd2ded8)),
        ),
        cardTheme: CardThemeData(color: Color(0xff1b2d30), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18)))),
      ),
      home: HomeShell(
        themeMode: _themeMode,
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class Story {
  Story({
    required this.title,
    required this.description,
    required this.type,
    required this.evidence,
    required this.date,
    required this.location,
    required this.creator,
    required this.visibility,
    this.isRecording = false,
  });

  final String title;
  final String description;
  final String type;
  final String evidence;
  final String date;
  final String location;
  final String creator;
  final String visibility;
  final bool isRecording;
}

final mockStories = <Story>[
  Story(
    title: 'Sunday noodles near the old railway',
    description:
        'A family recipe and the neighborhood where it became a tradition.',
    type: 'Family',
    evidence: 'Oral account',
    date: '1968',
    location: 'Oakland Chinatown',
    creator: 'Maya Chen',
    visibility: 'Family',
    isRecording: true,
  ),
  Story(
    title: 'The market fire of 1968',
    description: 'Lina remembers the night the neighborhood market burned.',
    type: 'Local',
    evidence: 'Firsthand memory',
    date: '1968',
    location: 'Oakland, California',
    creator: 'Lina Chen',
    visibility: 'Public',
  ),
  Story(
    title: 'The lantern under the bridge',
    description: 'A story passed between neighbors that still needs supporting evidence.',
    type: 'Local',
    evidence: 'Unverified story',
    date: 'Unknown',
    location: 'East Bay',
    creator: 'Maya Chen',
    visibility: 'Private',
  ),
];

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selected = 0;
  final _pages = const ['Explore', 'Create', 'Families', 'Profile'];

  void _openStory(Story story) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => StoryDetail(story: story)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ExplorePage(onStoryTap: _openStory),
      CreatePage(
        onStoryCreated: (story) {
          setState(() {
            if (Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null) {
              mockStories.insert(0, story);
            }
            _selected = 0;
          });
        },
      ),
      const FamiliesPage(),
      ProfilePage(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_selected]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: (index) => setState(() => _selected = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Families',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, required this.onStoryTap});
  final ValueChanged<Story> onStoryTap;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _map = false;
  bool _live = Firebase.apps.isNotEmpty;
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final stories = _filter == 'All'
        ? mockStories
        : mockStories.where((s) => s.type == _filter).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        Text(
          'Kindred',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Small histories, held together.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today’s question',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'What is a meal that takes you back to a particular place or person?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Answer question'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _map ? 'History map' : 'Recent stories',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                FilterChip(
                  label: const Text('Live'),
                  selected: _live,
                  onSelected: (value) => setState(() => _live = value),
                ),
                const SizedBox(width: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, icon: Icon(Icons.view_agenda_outlined), label: Text('Feed')),
                    ButtonSegment(value: true, icon: Icon(Icons.map_outlined), label: Text('Map')),
                  ],
                  selected: {_map},
                  onSelectionChanged: (v) => setState(() => _map = v.first),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_map)
          const MapPreview()
        else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Family', 'Local', 'Cultural']
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (_live)
            LiveStoryFeed(onStoryTap: widget.onStoryTap)
          else
            ...stories.map(
              (story) => StoryCard(story: story, onTap: () => widget.onStoryTap(story)),
            ),
        ],
      ],
    );
  }
}

class LiveStoryFeed extends StatelessWidget {
  const LiveStoryFeed({super.key, required this.onStoryTap});

  final ValueChanged<Story> onStoryTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreStoryRepository().watchPublicStories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_off_outlined),
              title: const Text('Live stories are unavailable'),
              subtitle: Text('${snapshot.error}'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Card(
            child: ListTile(
              title: Text('No public stories yet'),
              subtitle: Text('Be the first to share one.'),
            ),
          );
        }
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data();
            final story = Story(
              title: data['title'] as String? ?? 'Untitled story',
              description: data['description'] as String? ?? '',
              type: data['storyType'] as String? ?? 'Personal',
              evidence: data['evidenceType'] as String? ?? 'Oral account',
              date: 'A recent memory',
              location: 'Location not added',
              creator: data['creatorId'] as String? ?? 'Kindred storyteller',
              visibility: data['visibility'] as String? ?? 'Public',
            );
            return StoryCard(story: story, onTap: () => onStoryTap(story));
          }).toList(),
        );
      },
    );
  }
}

class MapPreview extends StatelessWidget {
  const MapPreview({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 360,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Stack(
      children: [
        Center(
          child: Icon(
            Icons.map_outlined,
            size: 92,
            color: Theme.of(context).colorScheme.primary.withOpacity(.35),
          ),
        ),
        const Positioned(
          top: 70,
          left: 70,
          child: MapPin(label: 'Market fire'),
        ),
        const Positioned(
          top: 180,
          right: 65,
          child: MapPin(label: 'Sunday noodles'),
        ),
        const Positioned(
          bottom: 58,
          left: 110,
          child: MapPin(label: 'Lantern story'),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Text(
            '3 stories in the East Bay',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    ),
  );
}

class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) =>
      Chip(avatar: const Icon(Icons.location_on, size: 18), label: Text(label));
}

class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.story, required this.onTap});
  final Story story;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text(story.type)),
                const Spacer(),
                Text(story.date, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            Text(
              story.title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              story.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(story.location),
                const Spacer(),
                Text(
                  story.evidence,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class StoryDetail extends StatelessWidget {
  const StoryDetail({super.key, required this.story});
  final Story story;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Story')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Chip(label: Text(story.evidence)),
        const SizedBox(height: 12),
        Text(
          story.title,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(story.description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(story.creator),
            subtitle: Text('${story.type} · ${story.visibility}'),
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('When'),
          subtitle: Text(story.date),
        ),
        ListTile(
          leading: const Icon(Icons.place_outlined),
          title: const Text('Where'),
          subtitle: Text(story.location),
        ),
        if (story.isRecording)
          Card(
            child: ListTile(
              leading: const Icon(Icons.graphic_eq),
              title: const Text('Recorded conversation'),
              subtitle: const Text('Original audio is preserved'),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_circle_outline),
              ),
            ),
          ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share story'),
        ),
      ],
    ),
  );
}

class CreatePage extends StatelessWidget {
  const CreatePage({super.key, required this.onStoryCreated});
  final ValueChanged<Story> onStoryCreated;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    children: [
      Text(
        'Create',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text('Give a memory a place to live.'),
      const SizedBox(height: 24),
      _CreateOption(
        icon: Icons.article_outlined,
        title: 'Share a story',
        subtitle: 'Add a memory, local history, or family account.',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryForm(onCreated: onStoryCreated),
          ),
        ),
      ),
      _CreateOption(
        icon: Icons.mic_none_outlined,
        title: 'Record an interview',
        subtitle: 'Capture someone telling their story directly.',
        onTap: () => showDialog(
          context: context,
          builder: (_) => const RecordingDialog(),
        ),
      ),
      _CreateOption(
        icon: Icons.question_answer_outlined,
        title: 'Answer today’s question',
        subtitle: 'Write, photograph, or record a response.',
        onTap: () {},
      ),
    ],
  );
}

class _CreateOption extends StatelessWidget {
  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(subtitle),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class StoryForm extends StatefulWidget {
  const StoryForm({super.key, required this.onCreated});
  final ValueChanged<Story> onCreated;
  @override
  State<StoryForm> createState() => _StoryFormState();
}

class _StoryFormState extends State<StoryForm> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _type = 'Family';
  String _evidence = 'Oral account';
  String _visibility = 'Public';
  final _files = <PlatformFile>[];
  bool _publishing = false;
  double? _uploadProgress;

  Future<void> _pickEvidence() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true, type: FileType.any);
    if (result != null) setState(() => _files.addAll(result.files));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Share a story')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(
            labelText: 'Story title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _description,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'What happened?',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _type,
          decoration: const InputDecoration(
            labelText: 'Story type',
            border: OutlineInputBorder(),
          ),
          items: [
            'Family',
            'Local',
            'Cultural',
            'Personal',
            'Oral',
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => _type = v!),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _evidence,
          decoration: const InputDecoration(
            labelText: 'What kind of history is this?',
            border: OutlineInputBorder(),
          ),
          items: [
            'Firsthand memory',
            'Oral account',
            'Documented fact',
            'Unverified story',
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => _evidence = v!),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _visibility,
          decoration: const InputDecoration(
            labelText: 'Who can see it?',
            border: OutlineInputBorder(),
          ),
          items: [
            'Public',
            'Private',
            'Family',
            'Invited',
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => _visibility = v!),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: _pickEvidence,
          icon: const Icon(Icons.attach_file),
          label: Text(_files.isEmpty ? 'Add photograph, recording, or document' : '${_files.length} evidence file(s) selected'),
        ),
        if (_uploadProgress != null) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _uploadProgress),
          const SizedBox(height: 4),
          Text('${((_uploadProgress ?? 0) * 100).round()}% uploaded'),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _publishing ? null : () async {
            if (_title.text.trim().isEmpty) return;
            if (Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser == null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
              return;
            }
            setState(() => _publishing = true);
            final user = Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser;
            if (user != null) {
              final ref = await FirestoreStoryRepository().createStory(
                creatorId: user.uid,
                title: _title.text.trim(),
                description: _description.text.trim().isEmpty ? 'A new Kindred story.' : _description.text.trim(),
                storyType: _type.toLowerCase(),
                evidenceType: _evidence.toLowerCase().replaceAll(' ', '_'),
                visibility: _visibility.toLowerCase(),
              );
              final storyId = ref.id;
              final evidence = EvidenceRepository();
              for (final file in _files) {
                await evidence.uploadEvidence(storyId: storyId, uploadedBy: user.uid, file: file, kind: _kindFor(file), onProgress: (progress) => setState(() => _uploadProgress = progress.fraction));
              }
            }
            widget.onCreated(
              Story(
                title: _title.text.trim(),
                description: _description.text.trim().isEmpty
                    ? 'A new Kindred story.'
                    : _description.text.trim(),
                type: _type,
                evidence: _evidence,
                date: 'Today',
                location: 'Add a place',
                creator: 'Story Keeper',
                visibility: _visibility,
              ),
            );
            if (mounted) setState(() => _publishing = false);
            Navigator.pop(context);
          },
          child: Text(_publishing ? 'Publishing…' : 'Publish story'),
        ),
      ],
    ),
  );

  String _kindFor(PlatformFile file) {
    final extension = (file.extension ?? '').toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) return 'photograph';
    if (['mp3', 'wav', 'm4a', 'aac'].contains(extension)) return 'audio';
    if (['mp4', 'mov', 'webm'].contains(extension)) return 'video';
    if (extension == 'pdf' || extension == 'doc' || extension == 'docx') return 'document';
    return 'other';
  }
}

class RecordingDialog extends StatefulWidget {
  const RecordingDialog({super.key});
  @override
  State<RecordingDialog> createState() => _RecordingDialogState();
}

class _RecordingDialogState extends State<RecordingDialog> {
  bool recording = false;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Record an interview'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Before recording, make sure everyone agrees to be recorded and understands how this story will be shared.',
        ),
        const SizedBox(height: 20),
        Icon(
          recording ? Icons.stop_circle_outlined : Icons.mic_none_outlined,
          size: 64,
        ),
        const SizedBox(height: 8),
        Text(recording ? 'Recording…' : 'Ready to record'),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
      FilledButton.icon(
        onPressed: () => setState(() => recording = !recording),
        icon: Icon(recording ? Icons.stop : Icons.mic),
        label: Text(recording ? 'Stop' : 'Start'),
      ),
    ],
  );
}

class FamiliesPage extends StatelessWidget {
  const FamiliesPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    children: [
      Text(
        'Families',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text('Public collections, connected by the stories inside them.'),
      const SizedBox(height: 24),
      Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: const CircleAvatar(child: Icon(Icons.people_outline)),
          title: const Text(
            'The Chen Family',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('2 members · 1 shared story'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Create a family group'),
      ),
    ],
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    children: [
      Text(
        'Profile',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 20),
      const Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('Maya Chen'),
          subtitle: Text('Student storyteller'),
        ),
      ),
      const SizedBox(height: 12),
      StreamBuilder<User?>(
        stream: Firebase.apps.isEmpty ? const Stream<User?>.empty() : AuthRepository().watchAuthState(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage())),
              icon: const Icon(Icons.login),
              label: const Text('Sign in or create account'),
            );
          }
          return OutlinedButton.icon(
            onPressed: () => AuthRepository().signOut(),
            icon: const Icon(Icons.logout),
            label: Text('Sign out ${user.email ?? ''}'),
          );
        },
      ),
      const SizedBox(height: 20),
      Text(
        'Appearance',
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      RadioListTile(
        title: const Text('Use system setting'),
        value: ThemeMode.system,
        groupValue: themeMode,
        onChanged: (v) => onThemeChanged(v!),
      ),
      RadioListTile(
        title: const Text('Light'),
        value: ThemeMode.light,
        groupValue: themeMode,
        onChanged: (v) => onThemeChanged(v!),
      ),
      RadioListTile(
        title: const Text('Dark'),
        value: ThemeMode.dark,
        groupValue: themeMode,
        onChanged: (v) => onThemeChanged(v!),
      ),
      const Divider(),
      const ListTile(
        leading: Icon(Icons.lock_outline),
        title: Text('Privacy and sharing'),
        trailing: Icon(Icons.chevron_right),
      ),
      const ListTile(
        leading: Icon(Icons.help_outline),
        title: Text('Help and feedback'),
        trailing: Icon(Icons.chevron_right),
      ),
    ],
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _busy = true; _error = null; });
    try {
      final auth = AuthRepository();
      if (_register) {
        await auth.register(email: _email.text.trim(), password: _password.text);
      } else {
        await auth.signIn(email: _email.text.trim(), password: _password.text);
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      setState(() => _error = error.message ?? error.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email first.');
      return;
    }
    try {
      await AuthRepository().sendPasswordReset(_email.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
    } on FirebaseAuthException catch (error) {
      setState(() => _error = error.message ?? error.code);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_register ? 'Create account' : 'Sign in')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
      const SizedBox(height: 14),
      TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      const SizedBox(height: 20),
      FilledButton(onPressed: _busy ? null : _submit, child: Text(_busy ? 'Please wait…' : (_register ? 'Create account' : 'Sign in'))),
      if (!_register) TextButton(onPressed: _busy ? null : _resetPassword, child: const Text('Forgot password?')),
      TextButton(onPressed: _busy ? null : () => setState(() => _register = !_register), child: Text(_register ? 'Already have an account? Sign in' : 'New to Kindred? Create an account')),
    ]),
  );
}
