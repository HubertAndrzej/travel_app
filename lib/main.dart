import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/constants/navigator.key.dart';
import 'package:travel_app/firebase_options.dart';
import 'package:travel_app/screens/auth_screen.dart';
import 'package:travel_app/screens/home_screen.dart';
import 'package:travel_app/screens/splash_screen.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 247, 247, 247),
  background: const Color.fromARGB(255, 181, 254, 131),
);

final theme = ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.background,
  colorScheme: colorScheme,
  textTheme: TextTheme(
    bodySmall: GoogleFonts.openSans(
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: GoogleFonts.openSans(
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: GoogleFonts.openSans(
      fontWeight: FontWeight.bold,
    ),
    titleSmall: GoogleFonts.openSans(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.openSans(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.openSans(
      fontWeight: FontWeight.bold,
    ),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey =
      'pk_test_51OVivwLQNcm2Q8ir3pIUvZKWJKtNpK1RyVWG1wSihF7TRX9RDmAvlR1wYZG22YUJmNyhERYgilEJ5dKA1MtOtxJL00G8UrwFME';
  await Stripe.instance.applySettings();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'go4travel',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
