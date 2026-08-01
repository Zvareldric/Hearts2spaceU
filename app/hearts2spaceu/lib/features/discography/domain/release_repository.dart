import 'release.dart';

/// The contract the Discography feature depends on.
///
/// Presentation talks to this, never to a concrete implementation, so the data
/// source can move (asset → network) without the UI noticing.
abstract interface class ReleaseRepository {
  Future<List<Release>> getReleases();
}
