import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Landing screen of the app. Replace the body with your real home UI.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: const Center(
        child: Text('Welcome to Hearts2SpaceU 👋'),
      ),
    );
  }
}
