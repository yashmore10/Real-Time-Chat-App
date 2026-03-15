import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',

      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,

        colorScheme: const ColorScheme.light(
          primary: Color(0xFF5A189A),
          secondary: Color(0xFF7B2CBF),
          tertiary: Color(0xFF9D4EDD),

          background: Color(0xFFF6F7FB),
          surface: Colors.white,

          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.black87,
          onSurface: Colors.black87,
        ),

        scaffoldBackgroundColor: const Color(0xFFF6F7FB),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF5A189A),
          elevation: 0,
          centerTitle: true,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A189A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF7B2CBF),
              foregroundColor: Colors.white,
            ),
      ),

      // 🌙 Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9D4EDD),
          secondary: Color(0xFF7B2CBF),
          tertiary: Color(0xFF5A189A),

          background: Color(0xFF0E0718),
          surface: Color(0xFF1A0F2E),

          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white70,
          onSurface: Colors.white70,
        ),

        scaffoldBackgroundColor: const Color(0xFF0E0718),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF9D4EDD),
          elevation: 0,
          centerTitle: true,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1A0F2E),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B2CBF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF5A189A),
              foregroundColor: Colors.white,
            ),
      ),

      themeMode: ThemeMode.system,

      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (session == null) {
            return const AuthScreen();
          }

          return const ChatScreen();
        },
      ),
    );
  }
}
