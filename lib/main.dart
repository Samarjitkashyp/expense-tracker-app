import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SpendWiseApp(),
    ),
  );
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0C1B),
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.purpleAccent,
          surface: Color(0xFF1E1E2C),
          background: Color(0xFF0F0C1B),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0C1B),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
          ),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
