import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:usa_zipcode_address_lookup/usa_zipcode_address_lookup.dart';

import 'data/auth_repository.dart';
import 'data/story_repository.dart';
import 'data/family_repository.dart';
import 'data/question_repository.dart';
import 'data/user_repository.dart';
import 'data/timeline_repository.dart';
import 'data/discovery_repository.dart';
import 'data/location_catalog.dart';
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: ink,
          primary: ink,
          secondary: terracotta,
          surface: parchment,
        ),
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
        cardTheme: CardThemeData(
          color: Color(0xfffffbf4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xfffffbf4),
          indicatorColor: Color(0xffdbe6df),
        ),
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
          headlineMedium: TextStyle(
            fontFamily: 'Georgia',
            color: Color(0xfff5f1e8),
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Georgia',
            color: Color(0xfff5f1e8),
          ),
          titleLarge: TextStyle(
            fontFamily: 'Georgia',
            color: Color(0xfff5f1e8),
          ),
          titleMedium: TextStyle(color: Color(0xfff5f1e8)),
          bodyLarge: TextStyle(color: Color(0xffe2e9e5)),
          bodyMedium: TextStyle(color: Color(0xffd2ded8)),
        ),
        cardTheme: CardThemeData(
          color: Color(0xff1b2d30),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
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
    this.storyId,
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
  final String? storyId;
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
  void _openStory(Story story) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => StoryDetail(story: story)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Slice3Explore(onStoryTap: _openStory),
      CreatePage(
        onStoryCreated: (story) {
          setState(() {
            if (Firebase.apps.isEmpty ||
                FirebaseAuth.instance.currentUser == null) {
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

class Slice3Explore extends StatefulWidget {
  const Slice3Explore({super.key, required this.onStoryTap});
  final ValueChanged<Story> onStoryTap;
  @override
  State<Slice3Explore> createState() => _Slice3ExploreState();
}

class _Slice3ExploreState extends State<Slice3Explore> {
  final _repository = const DiscoveryRepository();
  var _map = true;
  var _mode = DiscoveryMode.community;
  var _filters = const DiscoveryFilters();
  var _showFilters = false;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stories = _repository.stories(mode: _mode, filters: _filters);
    final timeline = _repository.timeline(mode: _mode, filters: _filters);
    final clusters = _repository.clusters(stories);
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
          'Explore the stories held by a place and its people.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 14),
        const Card(
          child: ListTile(
            leading: Icon(Icons.auto_awesome_outlined),
            title: Text('Today’s question'),
            subtitle: Text(
              'What is a meal that takes you back to a particular place or person?',
            ),
          ),
        ),
        const SizedBox(height: 18),
        SegmentedButton<DiscoveryMode>(
          segments: const [
            ButtonSegment(
              value: DiscoveryMode.community,
              label: Text('Community'),
            ),
            ButtonSegment(value: DiscoveryMode.family, label: Text('Family')),
          ],
          selected: {_mode},
          onSelectionChanged: (v) => setState(() => _mode = v.first),
        ),
        const SizedBox(height: 12),
        SearchBar(
          controller: _search,
          hintText: 'Search stories, places, people',
          leading: const Icon(Icons.search),
          onChanged: (v) =>
              setState(() => _filters = _filters.copyWith(query: v)),
          trailing: [
            IconButton(
              tooltip: 'Show filters',
              onPressed: () => setState(() => _showFilters = !_showFilters),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        if (_showFilters) _filterPanel(),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              icon: Icon(Icons.map_outlined),
              label: Text('Map'),
            ),
            ButtonSegment(
              value: false,
              icon: Icon(Icons.timeline_outlined),
              label: Text('Timeline'),
            ),
          ],
          selected: {_map},
          onSelectionChanged: (v) => setState(() => _map = v.first),
        ),
        const SizedBox(height: 12),
        if (stories.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.search_off),
              title: Text('No stories match these filters'),
              subtitle: Text('Try widening your search or filters.'),
            ),
          )
        else if (_map) ...[
          Semantics(
            label: 'Accessible story list',
            header: true,
            child: const Text(
              'Story locations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          ...clusters.entries.map(
            (entry) => Card(
              child: ExpansionTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(
                  '${entry.key} · ${entry.value.length} ${entry.value.length == 1 ? 'story' : 'stories'}',
                ),
                subtitle: const Text('Grouped nearby stories'),
                children: entry.value
                    .map(
                      (s) => ListTile(
                        title: Text(s.title),
                        subtitle: Text('${s.date} · ${s.visibility}'),
                        onTap: () => widget.onStoryTap(s),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ] else ...[
          Semantics(
            label: 'Accessible timeline story list',
            header: true,
            child: const Text(
              'Timeline',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...timeline.entries.map(
            (entry) => Card(
              child: ExpansionTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(entry.key),
                subtitle: Text(
                  '${entry.value.length} ${entry.value.length == 1 ? 'story' : 'stories'}',
                ),
                children: entry.value
                    .map(
                      (s) => ListTile(
                        title: Text(s.title),
                        subtitle: Text(
                          '${s.type} · ${s.evidence} · ${s.visibility}',
                        ),
                        onTap: () => widget.onStoryTap(s),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _filterPanel() => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _choice('Type', _filters.type, [
            'All',
            'Family',
            'Local',
            'Cultural',
          ]),
          _choice('Evidence', _filters.evidence, [
            'All',
            'Oral account',
            'Firsthand memory',
            'Unverified story',
          ]),
          _choice('Visibility', _filters.visibility, [
            'All',
            'Public',
            'Family',
            'Private',
          ]),
        ],
      ),
    ),
  );

  Widget _choice(String label, String value, List<String> values) =>
      DropdownButton<String>(
        value: value,
        hint: Text(label),
        items: values
            .map((v) => DropdownMenuItem(value: v, child: Text('$label: $v')))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(
            () => _filters = label == 'Type'
                ? _filters.copyWith(type: v)
                : label == 'Evidence'
                ? _filters.copyWith(evidence: v)
                : _filters.copyWith(visibility: v),
          );
        },
      );
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, required this.onStoryTap});
  final ValueChanged<Story> onStoryTap;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _map = false;
  final bool _live = Firebase.apps.isNotEmpty;
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final stories = _filter == 'All'
        ? mockStories
        : mockStories.where((s) => s.type == _filter).toList();
    final firebaseReady = Firebase.apps.isNotEmpty;
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
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: Firebase.apps.isEmpty
                      ? const Stream<
                          QuerySnapshot<Map<String, dynamic>>
                        >.empty()
                      : QuestionRepository().watchRecentQuestions(),
                  builder: (context, snapshot) {
                    final question =
                        snapshot.data?.docs.firstOrNull?.data()['prompt']
                            as String?;
                    return Text(
                      question ?? 'What is a meal that takes you back to a particular place or person?',
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
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
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 12,
          children: [
            Text(
              _map ? 'History map' : 'Recent stories',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                if (!firebaseReady)
                  FilterChip(
                    label: const Text('Offline sample'),
                    selected: !_live,
                    onSelected: (_) {},
                  ),
                const SizedBox(width: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.view_agenda_outlined),
                      label: Text('Feed'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.map_outlined),
                      label: Text('Map'),
                    ),
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
          firebaseReady ? LiveStoryMap(filter: _filter) : const MapPreview()
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
          if (firebaseReady) ...[
            if (FirebaseAuth.instance.currentUser != null)
              LiveOwnStoryFeed(onStoryTap: widget.onStoryTap, filter: _filter),
            LiveStoryFeed(onStoryTap: widget.onStoryTap, filter: _filter),
            const TimelineLive(),
          ] else
            ...stories.map(
              (story) => StoryCard(
                story: story,
                onTap: () => widget.onStoryTap(story),
              ),
            ),
        ],
      ],
    );
  }
}

class LiveStoryFeed extends StatelessWidget {
  const LiveStoryFeed({
    super.key,
    required this.onStoryTap,
    required this.filter,
  });

  final ValueChanged<Story> onStoryTap;
  final String filter;

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
          children: snapshot.data!.docs
              .where(
                (doc) =>
                    filter == 'All' ||
                    (doc.data()['storyType'] as String? ?? '').toLowerCase() ==
                        filter.toLowerCase(),
              )
              .map((doc) {
                final data = doc.data();
                final story = Story(
                  storyId: doc.id,
                  title: data['title'] as String? ?? 'Untitled story',
                  description: data['description'] as String? ?? '',
                  type: data['storyType'] as String? ?? 'Personal',
                  evidence: data['evidenceType'] as String? ?? 'Oral account',
                  date: 'A recent memory',
                  location: 'Location not added',
                  creator:
                      data['creatorId'] as String? ?? 'Kindred storyteller',
                  visibility: data['visibility'] as String? ?? 'Public',
                );
                return StoryCard(story: story, onTap: () => onStoryTap(story));
              })
              .toList(),
        );
      },
    );
  }
}

class LiveOwnStoryFeed extends LiveStoryFeed {
  const LiveOwnStoryFeed({
    super.key,
    required super.onStoryTap,
    required super.filter,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreStoryRepository().watchStoriesForCreator(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        final stories = snapshot.data!.docs
            .where((doc) {
              final data = doc.data();
              return filter == 'All' ||
                  (data['storyType'] as String? ?? '').toLowerCase() ==
                      filter.toLowerCase();
            })
            .map((doc) => _storyFromDocument(doc))
            .toList();
        if (stories.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Column(
            children: [
              const ListTile(
                title: Text(
                  'Your stories',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Private posts stay with you and listed family members',
                ),
              ),
              ...stories.map(
                (story) => ListTile(
                  title: Text(story.title),
                  subtitle: Text('${story.visibility} · ${story.date}'),
                  onTap: () => onStoryTap(story),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Story _storyFromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  return Story(
    storyId: doc.id,
    title: data['title'] as String? ?? 'Untitled story',
    description: data['description'] as String? ?? '',
    type: data['storyType'] as String? ?? 'Personal',
    evidence: data['evidenceType'] as String? ?? 'Oral account',
    date:
        (data['date'] as Map<String, dynamic>?)?['start'] as String? ??
        'Unknown',
    location: (data['locations'] as List?)?.isNotEmpty == true
        ? ((data['locations'] as List).first as Map<String, dynamic>)['label']
                  as String? ??
              'Location not added'
        : 'Location not added',
    creator: data['creatorId'] as String? ?? 'Kindred storyteller',
    visibility: data['visibility'] as String? ?? 'Private',
  );
}

class LiveStoryMap extends StatelessWidget {
  const LiveStoryMap({super.key, required this.filter});
  final String filter;
  @override
  Widget build(BuildContext context) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreStoryRepository().watchPublicStories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ListTile(
              leading: Icon(Icons.cloud_off),
              title: Text('Live map unavailable'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final count = snapshot.data!.docs
              .where(
                (doc) =>
                    filter == 'All' ||
                    (doc.data()['storyType'] as String? ?? '').toLowerCase() ==
                        filter.toLowerCase(),
              )
              .length;
          return Container(
            height: 360,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$count live stories\nMap coordinates will render here',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );
}

class TimelineLive extends StatelessWidget {
  const TimelineLive({super.key});
  @override
  Widget build(BuildContext context) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: TimelineRepository().watchEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ListTile(
              leading: Icon(Icons.cloud_off),
              title: Text('Timeline unavailable'),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
          return Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text(
                    'Timeline',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...snapshot.data!.docs
                    .take(5)
                    .map(
                      (doc) => ListTile(
                        leading: const Icon(Icons.event_outlined),
                        title: Text(
                          doc.data()['title'] as String? ?? 'A timeline event',
                        ),
                        subtitle: Text(
                          doc.data()['description'] as String? ?? '',
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      );
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
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .35),
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
    appBar: AppBar(
      title: const Text('Story'),
      actions: [
        if (story.storyId != null)
          IconButton(
            tooltip: 'Edit story',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editStory(context),
          ),
      ],
    ),
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
        if (story.storyId != null) EvidenceLive(storyId: story.storyId!),
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

  Future<void> _editStory(BuildContext context) async {
    final title = TextEditingController(text: story.title);
    final description = TextEditingController(text: story.description);
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit story'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (
              title.text.trim(),
              description.text.trim(),
            )),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null ||
        result.$1.isEmpty ||
        story.storyId == null ||
        !context.mounted) {
      return;
    }
    try {
      await FirestoreStoryRepository().updateStoryWithHistory(
        storyId: story.storyId!,
        previousTitle: story.title,
        previousDescription: story.description,
        changes: {'title': result.$1, 'description': result.$2},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story updated; original content preserved.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save changes. Check your connection and retry.',
            ),
          ),
        );
      }
    }
  }
}

class EvidenceLive extends StatelessWidget {
  const EvidenceLive({super.key, required this.storyId});
  final String storyId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreStoryRepository().watchEvidence(storyId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Evidence unavailable'),
              subtitle: Text(
                'You may not have permission to view this evidence.',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Card(
            child: ListTile(title: Text('No evidence attached yet')),
          );
        }
        final items = snapshot.data!.docs.map((doc) {
          final data = doc.data();
          final description = [
            data['caption'],
            data['sourceNote'],
          ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');
          return ListTile(
            leading: Icon(
              data['kind'] == 'photograph'
                  ? Icons.photo_outlined
                  : Icons.description_outlined,
            ),
            title: Text(
              data['fileName'] as String? ??
                  data['kind'] as String? ??
                  'Evidence',
            ),
            subtitle: description.isEmpty ? null : Text(description),
            trailing: PopupMenuButton<String>(
              tooltip: 'Evidence actions',
              onSelected: (action) async {
                final repository = FirestoreStoryRepository();
                if (action == 'delete') {
                  await repository.deleteEvidence(
                    storyId,
                    doc.id,
                    storagePath: data['storagePath'] as String?,
                  );
                } else if (action == 'edit' && context.mounted) {
                  final caption = await _editEvidence(
                    context,
                    data['caption'] as String? ?? '',
                  );
                  if (caption != null) {
                    await repository.updateEvidence(storyId, doc.id, {
                      'caption': caption,
                    });
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit caption')),
                PopupMenuItem(value: 'delete', child: Text('Delete evidence')),
              ],
            ),
          );
        }).toList();
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                title: Text(
                  'Evidence',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorderItem: (oldIndex, newIndex) async {
                  final ids = snapshot.data!.docs.map((doc) => doc.id).toList();
                  final id = ids.removeAt(oldIndex);
                  ids.insert(newIndex, id);
                  await FirestoreStoryRepository().reorderEvidence(
                    storyId,
                    ids,
                  );
                },
                children: items
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (entry) => KeyedSubtree(
                        key: ValueKey(snapshot.data!.docs[entry.key].id),
                        child: entry.value,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<String?> _editEvidence(
    BuildContext context,
    String initial,
  ) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit caption'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Caption'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
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
  final _evidenceFile = TextEditingController();
  final _evidenceCaption = TextEditingController();
  final _evidenceSource = TextEditingController();
  String _type = 'Family';
  String _evidence = 'Oral account';
  String _visibility = 'Public';
  String _status = 'published';
  final List<PlatformFile> _pickedFiles = [];
  String _dateConfidence = 'approximate';
  String _dateShape = 'single';
  final _dateStart = TextEditingController();
  final _dateEnd = TextEditingController();
  String _locationPrecision = '';
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _zipCode = TextEditingController();
  final _citySearch = TextEditingController();
  final _stateSearch = TextEditingController();
  String _region = 'Northeast';
  bool _lookingUpZip = false;
  String? _locationError;
  final List<Map<String, dynamic>> _locations = [];
  bool _publishing = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _evidenceFile.dispose();
    _evidenceCaption.dispose();
    _evidenceSource.dispose();
    _dateStart.dispose();
    _dateEnd.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _zipCode.dispose();
    _citySearch.dispose();
    _stateSearch.dispose();
    super.dispose();
  }

  void _resetLocationInputs() {
    _latitude.clear();
    _longitude.clear();
    _zipCode.clear();
    _citySearch.clear();
    _stateSearch.clear();
    _region = 'Northeast';
    _locationError = null;
  }

  Future<void> _addLocation() async {
    setState(() => _locationError = null);
    switch (_locationPrecision) {
      case 'exact':
        final lat = double.tryParse(_latitude.text.trim());
        final lng = double.tryParse(_longitude.text.trim());
        if (lat == null || lng == null) {
          setState(
            () => _locationError = 'Enter valid latitude and longitude only.',
          );
          return;
        }
        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
          setState(() => _locationError = 'Latitude/longitude out of range.');
          return;
        }
        setState(() {
          _locations.add({
            'label': '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
            'latitude': lat,
            'longitude': lng,
            'precision': 'exact',
          });
          _resetLocationInputs();
        });
        return;
      case 'neighborhood':
        final zip = _zipCode.text.trim();
        if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(zip)) {
          setState(() => _locationError = 'Enter a 5-digit US ZIP code only.');
          return;
        }
        setState(() => _lookingUpZip = true);
        try {
          final resolved = await _lookupUsZip(zip.split('-').first);
          if (!mounted) return;
          setState(() {
            _locations.add({
              'label':
                  '${resolved.city}, ${resolved.stateCode.isEmpty ? resolved.stateName : resolved.stateCode} $zip',
              'precision': 'neighborhood',
              'zipCode': zip,
              'city': resolved.city,
              'state': resolved.stateName,
              'stateCode': resolved.stateCode,
            });
            _resetLocationInputs();
            _lookingUpZip = false;
          });
        } catch (error) {
          if (!mounted) return;
          setState(() {
            _lookingUpZip = false;
            _locationError =
                'ZIP lookup failed. Check the code and try again.';
          });
        }
        return;
      case 'city':
        final city = _citySearch.text.trim();
        if (city.isEmpty) {
          setState(() => _locationError = 'Choose or type a city only.');
          return;
        }
        setState(() {
          _locations.add({'label': city, 'precision': 'city', 'city': city});
          _resetLocationInputs();
        });
        return;
      case 'region':
        final state = _stateSearch.text.trim();
        if (state.isEmpty) {
          setState(
            () => _locationError = 'Pick a region and search a state.',
          );
          return;
        }
        setState(() {
          _locations.add({
            'label': '$_region · $state',
            'precision': 'region',
            'region': _region,
            'state': state,
          });
          _resetLocationInputs();
        });
        return;
      default:
        setState(() => _locationError = 'Choose a location precision first.');
    }
  }

  /// Uses usa_zipcode_address_lookup on mobile; Zippopotam on web (package is not web-ready).
  Future<({String city, String stateName, String stateCode})> _lookupUsZip(
    String zip,
  ) async {
    if (!kIsWeb) {
      final found = await USAZipCodeAddressLookup.searchZipcode(zip);
      return (
        city: found.city.trim().isEmpty ? 'Unknown city' : found.city.trim(),
        stateName: found.stateName.trim(),
        stateCode: found.stateCode.trim(),
      );
    }
    final response = await http.get(
      Uri.parse('https://api.zippopotam.us/us/$zip'),
    );
    if (response.statusCode != 200) {
      throw StateError('ZIP not found');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final places = data['places'] as List<dynamic>?;
    if (places == null || places.isEmpty) {
      throw StateError('ZIP not found');
    }
    final place = places.first as Map<String, dynamic>;
    return (
      city: (place['place name'] as String?)?.trim() ?? 'Unknown city',
      stateName: (place['state'] as String?)?.trim() ?? '',
      stateCode: (place['state abbreviation'] as String?)?.trim() ?? '',
    );
  }

  Future<void> _pickDate(TextEditingController target) async {
    var selected = DateTime.tryParse(target.text) ?? DateTime(1968, 1, 1);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SizedBox(
        height: 330,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose a date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      target.text =
                          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _dateConfidence == 'exact'
                  ? CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selected,
                      minimumDate: DateTime(1000),
                      maximumDate: DateTime(2100),
                      onDateTimeChanged: (value) => selected = value,
                    )
                  : CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.monthYear,
                      initialDateTime: selected,
                      minimumDate: DateTime(1000),
                      maximumDate: DateTime(2100),
                      onDateTimeChanged: (value) =>
                          selected = DateTime(value.year, value.month),
                    ),
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() {});
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
          initialValue: _type,
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
          initialValue: _evidence,
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
          initialValue: _visibility,
          decoration: const InputDecoration(
            labelText: 'Who can see it?',
            helperText: 'Public: everyone. Private: you and your family members. Family/Invited: listed people only.',
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
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _status,
          decoration: const InputDecoration(
            labelText: 'Save state',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'draft', child: Text('Save as draft')),
            DropdownMenuItem(value: 'published', child: Text('Publish now')),
          ],
          onChanged: (v) => setState(() => _status = v!),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _dateConfidence,
                decoration: const InputDecoration(
                  labelText: 'Confidence',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'approximate',
                    child: Text('Approximate'),
                  ),
                  DropdownMenuItem(value: 'exact', child: Text('Exact')),
                ],
                onChanged: (v) => setState(() => _dateConfidence = v!),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _dateShape,
                decoration: const InputDecoration(
                  labelText: 'Period',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'single', child: Text('Date')),
                  DropdownMenuItem(value: 'range', child: Text('Date range')),
                ],
                onChanged: (v) => setState(() => _dateShape = v!),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Approximate dates use month and year only. Exact dates include the day.',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _dateStart,
          readOnly: true,
          onTap: () => _pickDate(_dateStart),
          decoration: const InputDecoration(
            labelText: 'Date or year',
            hintText: 'Scroll to choose',
            border: OutlineInputBorder(),
          ),
        ),
        if (_dateShape == 'range') ...[
          const SizedBox(height: 10),
          TextField(
            controller: _dateEnd,
            readOnly: true,
            onTap: () => _pickDate(_dateEnd),
            decoration: const InputDecoration(
              labelText: 'End date or year',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _locationPrecision.isEmpty ? null : _locationPrecision,
          decoration: const InputDecoration(
            labelText: 'Location precision',
            helperText:
                'Exact = lat/long only · Neighborhood = ZIP only · City = city only · Region = region + state',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'exact', child: Text('Exact')),
            DropdownMenuItem(
              value: 'neighborhood',
              child: Text('Neighborhood'),
            ),
            DropdownMenuItem(value: 'city', child: Text('City')),
            DropdownMenuItem(value: 'region', child: Text('Region')),
          ],
          onChanged: (v) => setState(() {
            _locationPrecision = v!;
            _resetLocationInputs();
          }),
        ),
        if (_locationPrecision == 'exact') ...[
          const SizedBox(height: 10),
          TextField(
            controller: _latitude,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Latitude only',
              hintText: 'e.g. 42.3314',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _longitude,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Longitude only',
              hintText: 'e.g. -83.0458',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (_locationPrecision == 'neighborhood') ...[
          const SizedBox(height: 10),
          TextField(
            controller: _zipCode,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ZIP code only',
              hintText: 'e.g. 48201',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (_locationPrecision == 'city') ...[
          const SizedBox(height: 10),
          Autocomplete<String>(
            optionsBuilder: (value) =>
                LocationCatalog.citiesMatching(value.text),
            onSelected: (value) => _citySearch.text = value,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              if (controller.text != _citySearch.text &&
                  _citySearch.text.isNotEmpty &&
                  controller.text.isEmpty) {
                controller.text = _citySearch.text;
              }
              controller.addListener(() => _citySearch.text = controller.text);
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'City only',
                  hintText: 'Search Detroit, Miami, San Antonio…',
                  border: OutlineInputBorder(),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    maxWidth: 420,
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: options
                        .map(
                          (city) => ListTile(
                            title: Text(city),
                            onTap: () => onSelected(city),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (_locationPrecision == 'region') ...[
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _region,
            decoration: const InputDecoration(
              labelText: 'Region',
              border: OutlineInputBorder(),
            ),
            items: LocationCatalog.regions
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _region = v!),
          ),
          const SizedBox(height: 10),
          Autocomplete<String>(
            optionsBuilder: (value) =>
                LocationCatalog.statesMatching(value.text),
            onSelected: (value) => _stateSearch.text = value,
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              controller.addListener(
                () => _stateSearch.text = controller.text,
              );
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'State (search)',
                  hintText: 'Type e.g. Mich',
                  border: OutlineInputBorder(),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    maxWidth: 360,
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: options
                        .map(
                          (state) => ListTile(
                            title: Text(state),
                            onTap: () => onSelected(state),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (_locationError != null) ...[
          const SizedBox(height: 8),
          Text(
            _locationError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (_locations.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _locations.length; i++)
                InputChip(
                  label: Text(
                    '${_locations[i]['precision']}: ${_locations[i]['label']}',
                  ),
                  onDeleted: () => setState(() => _locations.removeAt(i)),
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _lookingUpZip ? null : _addLocation,
          icon: _lookingUpZip
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_location_alt_outlined),
          label: Text(
            _lookingUpZip
                ? 'Looking up ZIP…'
                : 'Add location (${_locations.length})',
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Evidence details (metadata only)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Attach one photo or document now. Audio and video remain deferred.',
                  ),
                  TextField(
                    controller: _evidenceFile,
                    decoration: const InputDecoration(
                      labelText: 'File name (optional)',
                    ),
                  ),
                  TextField(
                    controller: _evidenceCaption,
                    decoration: const InputDecoration(
                      labelText: 'Caption (optional)',
                    ),
                  ),
                  TextField(
                    controller: _evidenceSource,
                    decoration: const InputDecoration(
                      labelText: 'Source note (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        withData: true,
                        type: FileType.custom,
                        allowedExtensions: [
                          'jpg',
                          'jpeg',
                          'png',
                          'pdf',
                          'doc',
                          'docx',
                        ],
                      );
                      if (result != null && mounted) {
                        setState(
                          () => _pickedFiles
                            ..clear()
                            ..addAll(
                              result.files.where((file) => file.bytes != null),
                            ),
                        );
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      _pickedFiles.isEmpty
                          ? 'Choose photos or documents'
                          : '${_pickedFiles.length} file(s) selected',
                    ),
                  ),
                  if (_pickedFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Selected files',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ..._pickedFiles.asMap().entries.map((entry) {
                      final file = entry.value;
                      final isImage =
                          file.extension != null &&
                          [
                            'jpg',
                            'jpeg',
                            'png',
                          ].contains(file.extension!.toLowerCase());
                      return ListTile(
                        leading: isImage && file.bytes != null
                            ? Image.memory(
                                file.bytes!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.insert_drive_file_outlined),
                        title: Text(file.name),
                        subtitle: Text(
                          '${((file.size) / 1024).toStringAsFixed(0)} KB',
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove file',
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _pickedFiles.removeAt(entry.key)),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          icon: const Icon(Icons.attach_file),
          label: const Text('Add evidence details later'),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _publishing
              ? null
              : () async {
                  final navigator = Navigator.of(context);
                  if (_title.text.trim().isEmpty) return;
                  if (Firebase.apps.isNotEmpty &&
                      FirebaseAuth.instance.currentUser == null) {
                    navigator.push(
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                    );
                    return;
                  }
                  setState(() => _publishing = true);
                  final user = Firebase.apps.isEmpty
                      ? null
                      : FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final storyId = await FirestoreStoryRepository()
                        .createStory(
                          creatorId: user.uid,
                          title: _title.text.trim(),
                          description: _description.text.trim().isEmpty
                              ? 'A new Kindred story.'
                              : _description.text.trim(),
                          storyType: _type.toLowerCase(),
                          evidenceType: _evidence.toLowerCase().replaceAll(
                            ' ',
                            '_',
                          ),
                          visibility: _visibility.toLowerCase(),
                          status: _status,
                          sourceNotes: _evidenceSource.text,
                          date: _dateStart.text.trim().isEmpty
                              ? null
                              : {
                                  'kind': _dateConfidence,
                                  'start': _dateStart.text.trim(),
                                  if (_dateShape == 'range' &&
                                      _dateEnd.text.trim().isNotEmpty)
                                    'end': _dateEnd.text.trim(),
                                },
                          locations: _locations,
                        );
                    for (final pickedFile in _pickedFiles) {
                      final extension = pickedFile.extension?.toLowerCase();
                      final isDocument = [
                        'pdf',
                        'doc',
                        'docx',
                      ].contains(extension);
                      await FirestoreStoryRepository().uploadEvidenceWithRetry(
                        storyId: storyId.id,
                        uploadedBy: user.uid,
                        kind: isDocument ? 'document' : 'photograph',
                        fileName: pickedFile.name,
                        bytes: pickedFile.bytes!,
                        mimeType: isDocument
                            ? 'application/octet-stream'
                            : 'image/${extension == 'jpg' ? 'jpeg' : extension}',
                        sourceNote: _evidenceSource.text,
                        order: _pickedFiles.indexOf(pickedFile),
                      );
                    }
                    if (_pickedFiles.isEmpty &&
                        (_evidenceFile.text.trim().isNotEmpty ||
                            _evidenceCaption.text.trim().isNotEmpty ||
                            _evidenceSource.text.trim().isNotEmpty)) {
                      await FirestoreStoryRepository().addEvidence(
                        storyId: storyId.id,
                        uploadedBy: user.uid,
                        kind: _evidence.toLowerCase().replaceAll(' ', '_'),
                        fileName: _evidenceFile.text,
                        caption: _evidenceCaption.text,
                        sourceNote: _evidenceSource.text,
                      );
                    }
                    // Binary media is intentionally deferred while Firestore is the only active data store.
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
                  if (!mounted) return;
                  setState(() => _publishing = false);
                  navigator.pop();
                },
          child: Text(
            _publishing
                ? 'Saving…'
                : _status == 'draft'
                ? 'Save draft'
                : 'Publish story',
          ),
        ),
      ],
    ),
  );
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
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FamilyRepository().watchPublicFamilies(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ListTile(
              leading: Icon(Icons.cloud_off),
              title: Text('Families unavailable'),
              subtitle: Text('Check your connection or permissions.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Text('No public family groups yet.');
          }
          return Column(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data();
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: const CircleAvatar(
                    child: Icon(Icons.people_outline),
                  ),
                  title: Text(
                    data['name'] as String? ?? 'Unnamed family',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['description'] as String? ??
                        'A public collection of stories.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            }).toList(),
          );
        },
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
      StreamBuilder<User?>(
        stream: Firebase.apps.isEmpty
            ? const Stream<User?>.empty()
            : AuthRepository().watchAuthState(),
        builder: (context, authSnapshot) {
          final uid = authSnapshot.data?.uid;
          if (uid == null) {
            return const Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Story keeper'),
                subtitle: Text('Sign in to load your profile.'),
              ),
            );
          }
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: UserRepository().watchProfile(uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const ListTile(
                  leading: Icon(Icons.cloud_off),
                  title: Text('Profile unavailable'),
                );
              }
              final data = snapshot.data?.data();
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    data?['displayName'] as String? ?? 'Story keeper',
                  ),
                  subtitle: Text(
                    data?['preferredLanguage'] as String? ?? 'English',
                  ),
                ),
              );
            },
          );
        },
      ),
      const SizedBox(height: 12),
      StreamBuilder<User?>(
        stream: Firebase.apps.isEmpty
            ? const Stream<User?>.empty()
            : AuthRepository().watchAuthState(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
              ),
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
      SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.system, label: Text('System')),
          ButtonSegment(value: ThemeMode.light, label: Text('Light')),
          ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
        ],
        selected: {themeMode},
        onSelectionChanged: (selection) => onThemeChanged(selection.first),
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
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = AuthRepository();
      if (_register) {
        await auth.register(
          email: _email.text.trim(),
          password: _password.text,
        );
      } else {
        await auth.signIn(email: _email.text.trim(), password: _password.text);
      }
      if (mounted) Navigator.pop(context);
    } on GoogleOnlyAccountException {
      if (mounted) {
        setState(
          () => _error = 'User signed up with Google. Use the “Continue with Google” option instead.',
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      }
    } on FirebaseAuthException catch (error) {
      setState(() => _error = error.message ?? error.code);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthRepository().signInWithGoogle();
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = error.message ?? error.code);
    } on GoogleSignInException catch (error) {
      if (mounted) {
        setState(() => _error = error.description ?? error.code.name);
      }
    } on UnsupportedError catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() => _error = 'Google sign-in failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_register ? 'Create account' : 'Sign in')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(
            _busy ? 'Please wait…' : (_register ? 'Create account' : 'Sign in'),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _busy ? null : _signInWithGoogle,
          icon: const Icon(Icons.login),
          label: const Text('Continue with Google'),
        ),
        if (!_register)
          TextButton(
            onPressed: _busy ? null : _resetPassword,
            child: const Text('Forgot password?'),
          ),
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() => _register = !_register),
          child: Text(
            _register
                ? 'Already have an account? Sign in'
                : 'New to Kindred? Create an account',
          ),
        ),
      ],
    ),
  );
}
