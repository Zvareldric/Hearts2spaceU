import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/shared/services/url_opener.dart';

void main() {
  group('UrlOpener.isSafe', () {
    test('accepts https URLs', () {
      expect(UrlOpener.isSafe('https://open.spotify.com/artist/abc'), isTrue);
      expect(UrlOpener.isSafe('https://x.com/hearts2hearts'), isTrue);
    });

    test('rejects plain http', () {
      // Not a hypothetical: a hosted JSON could carry one, and an http link
      // would be sent in the clear.
      expect(UrlOpener.isSafe('http://example.com'), isFalse);
    });

    test('rejects dangerous schemes', () {
      expect(UrlOpener.isSafe('javascript:alert(1)'), isFalse);
      expect(UrlOpener.isSafe('file:///etc/passwd'), isFalse);
      expect(UrlOpener.isSafe('data:text/html,<script>'), isFalse);
    });

    test('rejects custom app schemes', () {
      // Deep links into apps are a deliberate future step, not something that
      // should slip in through data (see the spec's Evolution Notes).
      expect(UrlOpener.isSafe('spotify:artist:abc'), isFalse);
    });

    test('rejects malformed or hostless URLs', () {
      expect(UrlOpener.isSafe(''), isFalse);
      expect(UrlOpener.isSafe('not a url'), isFalse);
      expect(UrlOpener.isSafe('https://'), isFalse);
    });
  });
}
