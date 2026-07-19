import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/member.dart';
import '../domain/member_repository.dart';

/// Loads members from a JSON asset bundled with the app.
///
/// Concrete implementation of [MemberRepository] for Sprint 1. It keeps the
/// "how" (asset + JSON) here, so the rest of the app — which only knows the
/// [MemberRepository] contract — stays unchanged if the source later becomes a
/// network API (the Data Source Boundary, docs/04).
class AssetMemberRepository implements MemberRepository {
  const AssetMemberRepository({this.assetPath = _defaultAssetPath});

  static const _defaultAssetPath = 'assets/data/members.json';

  final String assetPath;

  @override
  Future<List<Member>> getMembers() async {
    final raw = await rootBundle.loadString(assetPath);
    return parseMembers(raw);
  }

  /// Parses the raw JSON string into [Member]s.
  ///
  /// Pure and exposed so it can be unit-tested without loading a real asset.
  /// Throws [FormatException] / [TypeError] on malformed data; the caller (a
  /// Riverpod provider) turns that into an error state.
  static List<Member> parseMembers(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('members.json must contain a JSON array.');
    }
    return decoded
        .map((item) => _memberFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Member _memberFromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      stageName: json['stageName'] as String,
      fullName: json['fullName'] as String?,
      birthDate: _parseIsoDate(json['birthDate'] as String?),
      positions: _parseStringList(json['positions']),
      profileImage: json['profileImage'] as String?,
      officialProfileUrl: json['officialProfileUrl'] as String?,
    );
  }

  /// ISO date (`YYYY-MM-DD`) → [DateTime]; null when absent or unparseable.
  static DateTime? _parseIsoDate(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  static List<String> _parseStringList(Object? value) {
    if (value is! List) return const [];
    return value.map((e) => e as String).toList(growable: false);
  }
}
