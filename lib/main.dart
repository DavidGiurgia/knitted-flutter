import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/auth/auth_wrapper.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zic_flutter/core/services/chat_socket_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  String baseUrl = dotenv.env['BASE_URL'] ?? '';
  try {
    await ChatSocketService().connect(baseUrl); // Wait for connection
  } catch (e) {
    print('Failed to connect to WebSocket: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppTheme.backgroundColor(context),
          statusBarIconBrightness:
              AppTheme.isDark(context) ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: AppTheme.backgroundColor(context),
          systemNavigationBarIconBrightness:
              AppTheme.isDark(context) ? Brightness.light : Brightness.dark,
        ),
        child: const AuthWrapper(),
      ),
    );
  }
}
