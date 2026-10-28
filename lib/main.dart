import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'core/theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const FincareApp(),
    ),
  );
}

class FincareApp extends StatelessWidget {
  const FincareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return MaterialApp(
      title: 'FINCARE',
      debugShowCheckedModeBanner: false,  
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: app.themeMode,
      home: !app.ready
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : app.user == null
              ? const LoginScreen()
              : const HomeShell(),
    );
  }
}
