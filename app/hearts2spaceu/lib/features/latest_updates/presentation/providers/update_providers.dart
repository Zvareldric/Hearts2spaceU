import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/http_update_repository.dart';
import '../../domain/latest_first.dart';
import '../../domain/update.dart';
import '../../domain/update_repository.dart';

/// Provides the [UpdateRepository] implementation.
///
/// The feature depends on this provider — not the concrete class — so tests can
/// `override` it with a fake repository and never touch the network.
final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  return HttpUpdateRepository();
});

/// Loads updates and exposes them newest-first as an [AsyncValue].
///
/// The provider stays thin: it fetches, then delegates ordering to the pure
/// `latestFirst`. Identical in shape to the schedule's provider even though the
/// data now comes over the network — the Data Source Boundary at work.
final latestUpdatesProvider = FutureProvider<List<Update>>(
  (ref) async {
    final repository = ref.watch(updateRepositoryProvider);
    final all = await repository.getUpdates();
    return latestFirst(all);
  },
  // No automatic retry, matching the rest of the app: the UI offers an
  // explicit Retry, which is predictable and already a familiar pattern.
  // Network failures *are* transient, so this is worth revisiting if they
  // turn out to be common (see the spec's Evolution Notes).
  retry: (_, _) => null,
);
