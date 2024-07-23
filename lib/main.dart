import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:juno/firebase_options.dart';
import 'package:juno/screens/forgot_password.dart';
import 'package:juno/screens/home.dart';
import 'package:juno/screens/login.dart';
import 'package:juno/screens/onboarding.dart';
import 'package:juno/screens/precise_pickup_location.dart';
import 'package:juno/screens/profile.dart';
import 'package:juno/screens/register.dart';
import 'package:juno/screens/search_places.dart';
import 'package:juno/screens/splash.dart';
import 'package:juno/themes/dark.dart';
import 'package:juno/themes/light.dart';
import 'package:juno/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await registerControllers();
  await dotenv.load(fileName: '.env');
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
        '/home': (context) =>  HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/forgotPassword': (context) => ForgotPasswordScreen(),
        '/searchPlaces' : (context) => SearchPlacesScreen(),
        '/precisePickupLocation' : (context) => PrecisePickupLocationScreen(),
         '/profile' : (context) => ProfileScreen(),
      },
      initialRoute: '/splash',
    );
  }
}
