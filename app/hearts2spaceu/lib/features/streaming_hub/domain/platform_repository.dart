import 'official_platform.dart';

/// Contract for retrieving the official channels.
///
/// Declares *what* is needed; the data layer decides *where* it comes from
/// (the Data Source Boundary, docs/04).
abstract interface class PlatformRepository {
  /// Loads all official platforms. Throws if the source cannot be read
  /// or parsed.
  Future<List<OfficialPlatform>> getPlatforms();
}
