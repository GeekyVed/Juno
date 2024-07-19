import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Duration splashTime = Duration(
    milliseconds: 2750,
  );

  FutureOr getNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first-checkin') == true || prefs.getBool('first-checkin') == null) {
      Get.offNamed("/onboarding");
    } else if (prefs.getBool('logged-in') == true) {
      Get.offNamed("/home");
    } else {
      Get.offNamed("/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(splashTime, getNextScreen);

    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: deviceHeight * 0.37,
            ),
            Text(
              "Juno",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(
              height: deviceHeight * 0.37,
            ),
            Text(
              "Connect. Move. Save.",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
