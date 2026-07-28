import 'package:flutter/material.dart';

import '../features/awards/presentation/pages/award_detail_page.dart';
import '../features/awards/presentation/pages/awards_page.dart';
import '../features/gallery/presentation/pages/album_page.dart';
import '../features/gallery/presentation/pages/albums_page.dart';
import '../features/gallery/presentation/pages/photo_viewer_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/latest_updates/presentation/pages/latest_updates_page.dart';
import '../features/latest_updates/presentation/pages/update_detail_page.dart';
import '../features/official_information/presentation/pages/member_detail_page.dart';
import '../features/official_information/presentation/pages/member_list_page.dart';
import '../features/schedule/presentation/pages/event_detail_page.dart';
import '../features/schedule/presentation/pages/schedule_page.dart';
import '../features/streaming_hub/presentation/pages/streaming_hub_page.dart';
import 'app_routes.dart';

/// Central place that maps route names to screens.
///
/// Add a `case` per feature route. For heavier navigation needs, this is the
/// natural spot to swap in a package like `go_router` later.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.memberList:
        return MaterialPageRoute(builder: (_) => const MemberListPage());
      case AppRoutes.memberDetail:
        final memberId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MemberDetailPage(memberId: memberId),
        );
      case AppRoutes.schedule:
        return MaterialPageRoute(builder: (_) => const SchedulePage());
      case AppRoutes.eventDetail:
        final eventId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EventDetailPage(eventId: eventId),
        );
      case AppRoutes.latestUpdates:
        return MaterialPageRoute(builder: (_) => const LatestUpdatesPage());
      case AppRoutes.updateDetail:
        final updateId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => UpdateDetailPage(updateId: updateId),
        );
      case AppRoutes.streamingHub:
        return MaterialPageRoute(builder: (_) => const StreamingHubPage());
      case AppRoutes.awards:
        return MaterialPageRoute(builder: (_) => const AwardsPage());
      case AppRoutes.awardDetail:
        final awardId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AwardDetailPage(awardId: awardId),
        );
      case AppRoutes.gallery:
        return MaterialPageRoute(builder: (_) => const AlbumsPage());
      case AppRoutes.album:
        final albumId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => AlbumPage(albumId: albumId));
      case AppRoutes.photoViewer:
        final (albumId, index) = settings.arguments as (String, int);
        return MaterialPageRoute(
          builder: (_) =>
              PhotoViewerPage(albumId: albumId, initialIndex: index),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
