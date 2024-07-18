import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Duration splashTime = Duration(
    milliseconds: 2750,
  );

  @override
  Widget build(BuildContext context) {
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
