import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juno/screens/home.dart';
import 'package:juno/screens/login.dart';
import 'package:juno/screens/onboarding.dart';
import 'package:juno/screens/register.dart';
import 'package:juno/screens/splash.dart';
import 'package:juno/themes/dark.dart';
import 'package:juno/themes/light.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Juno - User',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
      initialRoute: '/splash',
    );
  }
}
