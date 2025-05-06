import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/auth/auth_wrapper.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zic_flutter/core/providers/theme_provider.dart';
import 'package:zic_flutter/core/services/chat_socket_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  String baseUrl = dotenv.env['BASE_URL'] ?? '';
  try {
    await ChatSocketService().connect(baseUrl); // Wait for connection
  } catch (e) {
    debugPrint('Failed to connect to WebSocket: $e');
  }

  // Forțează orientarea portrait (opțional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
