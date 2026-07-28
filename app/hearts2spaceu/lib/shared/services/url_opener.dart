import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens links outside the app.
///
/// Lives in `shared/` rather than a feature because four places need it: the
/// Streaming Hub plus the source links on the Update, Event, and Member detail
/// pages. It stays domain-agnostic — it only ever sees a [String].
///
/// Exposed through [urlOpenerProvider] so tests can override it; without that,
/// a widget test tapping a link would try to launch a real browser.
class UrlOpener {
  const UrlOpener();

  /// Opens [url] in the system browser or the owning app.
  ///
  /// Returns `false` when the link is unusable rather than throwing, so the UI
  /// can tell the user instead of failing silently.
  Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !isSafe(url)) return false;

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Whether [url] is safe to hand to the platform.
  ///
  /// Only `https` is allowed. Curated data is trusted, but some links arrive
  /// from hosted JSON, and this keeps `javascript:`, `file:`, and friends from
  /// ever reaching the launcher (docs/specs/streaming-hub.md §6).
  static bool isSafe(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }
}

/// The app-wide [UrlOpener]. Override in tests to avoid launching anything.
final urlOpenerProvider = Provider<UrlOpener>((ref) => const UrlOpener());
