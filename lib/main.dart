import 'package:aiflow/app/app.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SettingsProvider())],
      child: const AiFlow(),
    ),
  );
}
