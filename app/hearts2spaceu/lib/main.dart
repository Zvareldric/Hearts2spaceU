import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // ProviderScope is the root store for all Riverpod providers; every widget
  // below it can read them. It must wrap the whole app.
  runApp(const ProviderScope(child: App()));
}
