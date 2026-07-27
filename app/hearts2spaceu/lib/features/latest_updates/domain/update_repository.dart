import 'update.dart';

/// Contract for retrieving official updates.
///
/// Declares *what* is needed; the data layer decides *where* it comes from.
/// This capability is where that matters most: the implementation fetches over
/// the network, yet nothing above this contract knows or cares — the Data
/// Source Boundary (docs/04).
abstract interface class UpdateRepository {
  /// Loads all updates. Throws if the source cannot be reached or parsed.
  Future<List<Update>> getUpdates();
}
