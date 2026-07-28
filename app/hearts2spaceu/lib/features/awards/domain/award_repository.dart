import 'award.dart';

/// Contract for retrieving the group's achievements.
///
/// Declares *what* is needed; the data layer decides *where* it comes from
/// (the Data Source Boundary, docs/04).
abstract interface class AwardRepository {
  /// Loads every award. Throws if the source cannot be read or parsed.
  Future<List<Award>> getAwards();
}
