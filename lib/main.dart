import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/auth/auth_wrapper.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/search_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()), // Încarcă userul la startup
        ChangeNotifierProvider(create: (_) => ChatRoomsProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProxyProvider2<ChatRoomsProvider, FriendsProvider, SearchProvider>(
          create: (context) => SearchProvider([], []),
          update: (context, chatRoomsProvider, friendsProvider, previousSearchProvider) {
            return SearchProvider(
              chatRoomsProvider.rooms,
              friendsProvider.friends,
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
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
          statusBarColor: AppTheme.backgroundColor(context), // Status bar color
          statusBarIconBrightness: AppTheme.isDark(context) ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: AppTheme.backgroundColor(context), // Navigation bar color
          systemNavigationBarIconBrightness: AppTheme.isDark(context) ? Brightness.light : Brightness.dark,
        ),
        child: AuthWrapper(),
      ),
    );
  }
}