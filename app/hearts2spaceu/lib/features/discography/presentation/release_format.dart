import '../domain/release.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _typeLabels = {
  Release.typeSingle: 'Single',
  Release.typeMiniAlbum: 'Mini album',
  Release.typeAlbum: 'Album',
};

/// The one-line subtitle for a release: its format and when it came out.
///
/// Degrades honestly rather than guessing. A release whose format is not
/// recorded shows just the date; one with only a year shows just the year. It
/// never prints a day the source did not give (docs/specs/discography.md §4).
String formatReleaseMeta(Release release) {
  final parts = <String>[
    ?_typeLabels[release.type],
    switch (release.releaseDate) {
      final date? => '${_months[date.month - 1]} ${date.day}, ${date.year}',
      _ => '${release.year}',
    },
  ];
  return parts.join(' · ');
}
