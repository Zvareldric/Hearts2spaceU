import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/services/url_opener.dart';
import '../domain/voting_campaign.dart';
import '../domain/voting_repository.dart';

/// Fetches voting campaigns from a hosted JSON file.
///
/// Hosted, not bundled: votes open and close all year, and a vote missed
/// because the app hadn't shipped yet would defeat the point of the feature.
class HttpVotingRepository implements VotingRepository {
  HttpVotingRepository({http.Client? client, this.url = _defaultUrl})
    : _client = client ?? http.Client();

  static const _defaultUrl =
      'https://raw.githubusercontent.com/Zvareldric/Hearts2spaceU/main/data/voting.json';

  static const timeout = Duration(seconds: 10);

  final http.Client _client;
  final String url;

  @override
  Future<List<VotingCampaign>> getCampaigns() async {
    final response = await _client.get(Uri.parse(url)).timeout(timeout);

    if (response.statusCode != 200) {
      throw http.ClientException(
        'Failed to load the votes (HTTP ${response.statusCode})',
        Uri.parse(url),
      );
    }

    return parseCampaigns(utf8.decode(response.bodyBytes));
  }

  /// Parses the raw JSON string into [VotingCampaign]s.
  ///
  /// Pure and exposed so it can be unit-tested without any network.
  static List<VotingCampaign> parseCampaigns(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('voting.json must contain a JSON array.');
    }
    return decoded
        .map((item) => _campaignFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static VotingCampaign _campaignFromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    if (!UrlOpener.isSafe(url)) {
      throw FormatException('Voting url must be an https URL: $url');
    }

    final opensAt = json['opensAt'] as String?;

    return VotingCampaign(
      id: json['id'] as String,
      title: json['title'] as String,
      organizer: json['organizer'] as String,
      url: url,
      // Required by the schema: a campaign with no deadline could never be
      // hidden once it expired.
      closesAt: DateTime.parse(json['closesAt'] as String),
      opensAt: opensAt == null ? null : DateTime.parse(opensAt),
      note: json['note'] as String?,
    );
  }
}
