import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_colors.dart';
import 'package:hearts2spaceu/app/widgets/badges/type_badge.dart';
import 'package:hearts2spaceu/app/widgets/cards/capability_card.dart';
import 'package:hearts2spaceu/features/official_information/presentation/member_palette.dart';

/// WCAG relative luminance.
double _luminance(Color color) {
  double channel(double value) => value <= 0.04045
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// WCAG contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// The member ids shipped in `members.json`, so the avatar colours asserted here
/// are the ones real members actually get.
const _sampleMemberIds = [
  'jiwoo',
  'carmen',
  'yuha',
  'stella',
  'juun',
  'a-na',
  'ian',
  'ye-on',
];

/// Whether [color] sits in the purple band the palette was retired from.
///
/// 250-300°, and only when saturated enough to read as a hue at all — the brand
/// pink lives near 335° (magenta) and must not trip this.
bool _isViolet(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.hue >= 250 && hsl.hue <= 300 && hsl.saturation > 0.10;
}

/// Composites [fg] at its own alpha over an opaque [bg].
///
/// Badge tints are translucent, so their real contrast depends on what shows
/// through. Asserting the raw tint would measure a colour no user ever sees.
Color _composite(Color fg, Color bg) {
  final a = fg.a;
  return Color.from(
    alpha: 1,
    red: fg.r * a + bg.r * (1 - a),
    green: fg.g * a + bg.g * (1 - a),
    blue: fg.b * a + bg.b * (1 - a),
  );
}

void main() {
  const white = Color(0xFFFFFFFF);

  // A glass card over the ambient wash: white at 55% on the pale sky base. This
  // is the surface accent text and badges actually sit on.
  final glass = _composite(
    const Color(0x8CFFFFFF),
    AppColors.ambientBase.first,
  );

  group('primaryStrong carries text', () {
    // Every accent label, "See all", active tab, and solid CTA uses this token.
    // If it ever drifts light, all of them fail at once and silently.
    test('meets AA on white', () {
      expect(
        _contrast(AppColors.primaryStrong, white),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('meets AA on a glass card', () {
      // The stricter of the two, and the one most often forgotten: accent labels
      // sit on glass far more often than on pure white.
      expect(
        _contrast(AppColors.primaryStrong, glass),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('white text on it meets AA — it is also a solid CTA fill', () {
      expect(
        _contrast(white, AppColors.primaryStrong),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('primary is a fill, not an ink', () {
    test('the brand tint is too light to carry text', () {
      // Documents intent rather than guarding a bug: this asserts *why*
      // primaryStrong has to exist. If someone lightens primaryStrong to match
      // primary, the group above fails and points here.
      expect(_contrast(AppColors.primary, white), lessThan(3));
    });

    test('ink reads clearly on a primary fill', () {
      expect(
        _contrast(AppColors.ink, AppColors.primary),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('body text', () {
    test('ink meets AA on the ambient background', () {
      expect(_contrast(AppColors.ink, glass), greaterThanOrEqualTo(4.5));
    });

    test('inkSoft meets AA on a glass card', () {
      expect(_contrast(AppColors.inkSoft, glass), greaterThanOrEqualTo(4.5));
    });

    test('inkMuted meets AA on a glass card', () {
      // Section labels, dates, captions — secondary, but still text. The plum
      // this replaced sat at 3.5:1 and had never met the bar.
      expect(_contrast(AppColors.inkMuted, glass), greaterThanOrEqualTo(4.5));
    });

    test('navIdle clears 3:1 — an unselected tab must still be visible', () {
      // An icon, so 1.4.11's 3:1 applies rather than 4.5:1. The old tint was
      // 1.7:1: effectively invisible unless you knew where to look.
      expect(_contrast(AppColors.navIdle, glass), greaterThanOrEqualTo(3));
    });

    test('secondaryStrong clears the 3:1 bar for the saved heart', () {
      // A lower bar than the text tokens above, deliberately: this colour is
      // only ever the filled heart icon, and WCAG 1.4.11 asks 3:1 of a non-text
      // control rather than 4.5:1. It sits at 3.1:1, so it passes — but only
      // just, which is why it must not migrate into text. The token's own doc
      // comment says so.
      expect(
        _contrast(AppColors.secondaryStrong, white),
        greaterThanOrEqualTo(3),
      );
    });
  });

  group('type badges', () {
    // Every badge label is 9.5px bold — small text, so the 4.5:1 bar applies,
    // not the 3:1 large-text one. The tints copied from the source design put
    // six of the seven between 2.9:1 and 4.0:1 until the foregrounds were taken
    // down; this is what keeps them there.
    for (final entry in typeBadgeStyles.entries) {
      test('${entry.key} label meets AA on its own tint', () {
        final tint = _composite(entry.value.background, glass);
        expect(
          _contrast(entry.value.foreground, tint),
          greaterThanOrEqualTo(4.5),
          reason:
              '${entry.key}: ${entry.value.label} is unreadable on its badge',
        );
      });
    }

    test('no badge tint is the retired lavender', () {
      // #D9C6FF is out of the palette; `concert` used to carry it.
      for (final entry in typeBadgeStyles.entries) {
        expect(
          entry.value.background.toARGB32() & 0x00FFFFFF,
          isNot(0xD9C6FF),
          reason: '${entry.key} still uses the retired lavender',
        );
      }
    });
  });

  group('member avatars', () {
    // The avatar is a coloured circle with the member's initial in white. At 64
    // and 96 px the letter is large bold text, so the bar is 3:1 — the pastels
    // these replaced sat between 1.85:1 and 2.36:1 and failed every one.
    for (final id in _sampleMemberIds) {
      test('the initial is legible on $id\'s colour', () {
        final colour = memberColor(id, _sampleMemberIds);
        expect(
          _contrast(white, colour),
          greaterThanOrEqualTo(3),
          reason: 'white initial unreadable on $colour',
        );
      });
    }

    test('no avatar colour is violet', () {
      for (final id in _sampleMemberIds) {
        expect(
          _isViolet(memberColor(id, _sampleMemberIds)),
          isFalse,
          reason: '$id got a violet avatar',
        );
      }
    });

    test('every member gets a different colour', () {
      // The whole reason the colour is ranked rather than hashed. Hashing eight
      // ids into eight slots collided: three members shared one blue, two more
      // shared a coral, and three palette entries went unused — which left the
      // avatars unable to tell anyone apart.
      final assigned = [
        for (final id in _sampleMemberIds) memberColor(id, _sampleMemberIds),
      ];

      expect(assigned.toSet().length, _sampleMemberIds.length);
    });

    test('a colour survives the roster being reordered', () {
      // Ranking sorts the ids, so the Product Owner shuffling members.json must
      // not repaint anybody.
      final shuffled = _sampleMemberIds.reversed.toList();

      for (final id in _sampleMemberIds) {
        expect(
          memberColor(id, shuffled),
          memberColor(id, _sampleMemberIds),
          reason: '$id changed colour when the roster order changed',
        );
      }
    });

    test('an unknown id still gets a colour instead of throwing', () {
      expect(
        () => memberColor('not-a-member', _sampleMemberIds),
        returnsNormally,
      );
    });
  });

  group('no violet anywhere in the palette', () {
    // The brand is sky blue + blossom pink. Pink lives around 330-340°, which is
    // magenta, not violet — the band checked here is the 250-300° purple family
    // the palette used to be built on.
    final tokens = <String, Color>{
      'primary': AppColors.primary,
      'primaryStrong': AppColors.primaryStrong,
      'secondary': AppColors.secondary,
      'secondaryStrong': AppColors.secondaryStrong,
      'ink': AppColors.ink,
      'inkSoft': AppColors.inkSoft,
      'inkMuted': AppColors.inkMuted,
      'onPrimary': AppColors.onPrimary,
      'navIdle': AppColors.navIdle,
      'surfaceTint': AppColors.surfaceTint,
      'outline': AppColors.outline,
      'background': AppColors.background,
      'shadowTint': AppColors.shadowTint,
      'darkBackground': AppColors.darkBackground,
      'darkSurface': AppColors.darkSurface,
      'darkSurfaceTint': AppColors.darkSurfaceTint,
      'darkOutline': AppColors.darkOutline,
      'darkInk': AppColors.darkInk,
      'darkInkMuted': AppColors.darkInkMuted,
      'darkOnPrimary': AppColors.darkOnPrimary,
    };

    tokens.forEach((name, color) {
      test('$name is not violet', () {
        expect(
          _isViolet(color),
          isFalse,
          reason: '$name is in the 250-300° band',
        );
      });
    });

    test('no ambient blob is violet', () {
      for (final blob in AppColors.ambientBlobs) {
        expect(_isViolet(blob), isFalse);
      }
    });

    test('no badge tint or label is violet', () {
      for (final entry in typeBadgeStyles.entries) {
        expect(_isViolet(entry.value.background), isFalse, reason: entry.key);
        expect(_isViolet(entry.value.foreground), isFalse, reason: entry.key);
      }
    });
  });

  group('the retired lavender is gone', () {
    // The brand is sky blue + blossom pink. #D9C6FF was the old primary and it
    // lingered in the ambient wash and the Members tile after the swap.
    const retired = 0xD9C6FF;

    test('no ambient blob uses it', () {
      for (final blob in AppColors.ambientBlobs) {
        expect(blob.toARGB32() & 0x00FFFFFF, isNot(retired));
      }
    });

    test('the wash is built from primary and secondary only', () {
      // Two sky, two pink — so the background cannot drift off-brand again.
      expect(
        AppColors.ambientBlobs.contains(AppColors.primary),
        isTrue,
        reason: 'the sky blob should be the brand primary itself',
      );
      expect(AppColors.ambientBlobs.contains(AppColors.secondary), isTrue);
    });

    test('no capability gradient uses it', () {
      const gradients = <List<Color>>[
        CapabilityGradients.members,
        CapabilityGradients.discography,
        CapabilityGradients.music,
        CapabilityGradients.statistics,
        CapabilityGradients.updates,
        CapabilityGradients.awards,
        CapabilityGradients.voting,
      ];
      for (final gradient in gradients) {
        for (final stop in gradient) {
          expect(stop.toARGB32() & 0x00FFFFFF, isNot(retired));
        }
      }
    });

    test('the hero gradient is primary → secondary', () {
      expect(AppColors.heroGradient, [AppColors.primary, AppColors.secondary]);
    });
  });

  group('dark palette', () {
    test('darkInk meets AA on the dark surface', () {
      expect(
        _contrast(AppColors.darkInk, AppColors.darkSurface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('darkPrimary meets AA on the dark surface', () {
      // In dark mode the light brand tint *is* the readable one — the roles
      // invert, which is why this is asserted separately.
      expect(
        _contrast(AppColors.darkPrimary, AppColors.darkSurface),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}
