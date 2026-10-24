import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../features/reminders/presentation/providers/reminder_providers.dart';
import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'widgets/layout/ambient_background.dart';

/// Root widget of the application.
///
/// Wires together theming and routing. Keep this thin — feature logic lives
/// under `features/`.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps scheduled reminders in step with the data for the whole session,
    // not only while the Agenda happens to be open.
    ref.watch(reminderSyncProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      // Wrapping the navigator (not each page) paints the pastel wash once for
      // the whole app: it stays put while routes slide over it, and every
      // Scaffold is transparent so it shows through. See `AmbientBackground`.
      builder: (context, child) =>
          AmbientBackground(child: child ?? const SizedBox.shrink()),
    );
  }
}
