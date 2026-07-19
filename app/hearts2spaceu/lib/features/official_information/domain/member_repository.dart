import 'member.dart';

/// Contract for retrieving official member information.
///
/// The domain layer declares *what* it needs; it does not care *where* the
/// data comes from. Implementations live in the data layer, which keeps the
/// state and presentation layers independent of the data source — the
/// Data Source Boundary described in docs/04.
abstract interface class MemberRepository {
  /// Loads all members.
  ///
  /// Throws if the underlying source cannot be read or parsed; the caller
  /// (a Riverpod provider) turns that into an error state. A dedicated
  /// failure type is intentionally deferred (ADR-001) until error handling
  /// grows more complex.
  Future<List<Member>> getMembers();
}
