import '../main.dart';

enum DiscoveryMode { community, family }

class DiscoveryFilters {
  const DiscoveryFilters({
    this.type = 'All',
    this.evidence = 'All',
    this.visibility = 'All',
    this.query = '',
  });
  final String type;
  final String evidence;
  final String visibility;
  final String query;
  DiscoveryFilters copyWith({
    String? type,
    String? evidence,
    String? visibility,
    String? query,
  }) => DiscoveryFilters(
    type: type ?? this.type,
    evidence: evidence ?? this.evidence,
    visibility: visibility ?? this.visibility,
    query: query ?? this.query,
  );
}

class DiscoveryRepository {
  const DiscoveryRepository();

  List<Story> stories({
    DiscoveryMode mode = DiscoveryMode.community,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) {
    final source = mockStories.where(
      (s) => mode == DiscoveryMode.family
          ? s.visibility == 'Family' || s.type == 'Family'
          : true,
    );
    final q = filters.query.trim().toLowerCase();
    return source.where((s) {
      final text = '${s.title} ${s.description} ${s.location} ${s.creator}'
          .toLowerCase();
      return (filters.type == 'All' || s.type == filters.type) &&
          (filters.evidence == 'All' || s.evidence == filters.evidence) &&
          (filters.visibility == 'All' || s.visibility == filters.visibility) &&
          (q.isEmpty || text.contains(q));
    }).toList();
  }

  Map<String, List<Story>> timeline({
    DiscoveryMode mode = DiscoveryMode.community,
    DiscoveryFilters filters = const DiscoveryFilters(),
  }) {
    final groups = <String, List<Story>>{};
    for (final story in stories(mode: mode, filters: filters)) {
      final key = story.date == 'Unknown' ? 'Date uncertain' : story.date;
      groups.putIfAbsent(key, () => []).add(story);
    }
    return groups;
  }

  Map<String, List<Story>> clusters(List<Story> stories) {
    final result = <String, List<Story>>{};
    for (final story in stories) {
      result.putIfAbsent(story.location, () => []).add(story);
    }
    return result;
  }
}
