import 'package:flutter/material.dart';

/// Eight distinct hues, none of them violet, each dark enough that the white
/// initial on top of it clears 3:1 (WCAG's bar for large bold text).
///
/// The pastels these replaced sat between 1.85:1 and 2.36:1 — the initials were
/// barely legible on any of them. Depth, not hue, is what fixed that: these are
/// the same spread of colours taken down until the letter reads.
const _palette = [
  Color(0xFF3296C8), // sky
  Color(0xFFD65C85), // rose
  Color(0xFF289F97), // teal
  Color(0xFFD161B5), // magenta
  Color(0xFF6183D1), // cobalt
  Color(0xFFD77456), // coral
  Color(0xFF36A166), // green
  Color(0xFFBF8022), // amber
];

/// The colour for [memberId], assigned by its rank among [allMemberIds] sorted
/// alphabetically.
///
/// There is no colour in the `Member` domain, and adding one would push a
/// styling decision into curated data. So it is derived — but from *position*,
/// not from a hash of the id.
///
/// That distinction is the whole point. Hashing an id into eight slots collides:
/// with the eight real members, three of them landed on the same blue and two on
/// the same coral, leaving three colours unused and the avatars no longer
/// telling anyone apart. Ranking guarantees every member gets a different colour
/// while there are no more members than palette entries.
///
/// Sorting the ids — rather than taking the order `members.json` happens to list
/// them in — keeps the assignment stable when the Product Owner reorders that
/// file. Adding or removing a member does reshuffle the ones after it
/// alphabetically; that is the accepted cost of guaranteed distinctness.
Color memberColor(String memberId, Iterable<String> allMemberIds) {
  final ranked = allMemberIds.toList()..sort();
  final index = ranked.indexOf(memberId);
  // An id outside the list still gets a stable colour rather than throwing:
  // sum its code units, which is deterministic across launches in a way
  // `String.hashCode` is not.
  if (index < 0) {
    return _palette[memberId.codeUnits.fold(0, (a, b) => a + b) %
        _palette.length];
  }
  return _palette[index % _palette.length];
}

/// The single letter shown on an avatar when there is no photo.
String memberInitial(String stageName) =>
    stageName.isEmpty ? '?' : stageName.characters.first.toUpperCase();
