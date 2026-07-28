import 'official_platform.dart';

/// The categories shown first, in this order. Anything else is grouped last.
const platformCategoryOrder = ['music', 'video', 'social', 'community'];

/// Groups [platforms] by category, ready for a sectioned list.
///
/// Pure and deterministic; never mutates [platforms].
///
/// Within a group the source order is preserved — `platforms.json` is curated,
/// so its ordering is a deliberate editorial choice, not an accident. Known
/// categories come first in [platformCategoryOrder]; unknown ones follow, in
/// the order they first appear, so new data never silently disappears.
Map<String, List<OfficialPlatform>> groupByCategory(
  List<OfficialPlatform> platforms,
) {
  final grouped = <String, List<OfficialPlatform>>{};

  for (final category in platformCategoryOrder) {
    final matches = platforms.where((p) => p.category == category).toList();
    if (matches.isNotEmpty) grouped[category] = matches;
  }

  for (final platform in platforms) {
    if (platformCategoryOrder.contains(platform.category)) continue;
    grouped.putIfAbsent(platform.category, () => []).add(platform);
  }

  return grouped;
}
