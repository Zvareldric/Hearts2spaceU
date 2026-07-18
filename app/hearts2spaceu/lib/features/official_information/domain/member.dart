/// A Hearts2Hearts member shown in the Official Information capability.
///
/// This is a **pure domain entity**: it has no knowledge of JSON, assets, or
/// how it is rendered. Parsing (ISO string → [DateTime]) happens in the data
/// layer; display formatting happens in the presentation layer.
class Member {
  const Member({
    required this.id,
    required this.stageName,
    this.fullName,
    this.birthDate,
    this.positions = const [],
    this.profileImage,
    this.officialProfileUrl,
  });

  /// Stable, unique identifier.
  final String id;

  /// Stage name — the primary label shown in the member list.
  final String stageName;

  /// Full/legal name, when available.
  final String? fullName;

  /// Date of birth. Stored as an ISO date in the source and kept here as a
  /// [DateTime] so the presentation layer alone decides how to format it.
  final DateTime? birthDate;

  /// Roles within the group, e.g. `['Vocalist', 'Dancer']`.
  final List<String> positions;

  /// Reference to a profile image; when null the UI shows a placeholder.
  final String? profileImage;

  /// Link to the member's official profile. Stored for now; opening it is
  /// out of scope for Sprint 1 (that would require url_launcher).
  final String? officialProfileUrl;
}
