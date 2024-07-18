import 'package:flutter/material.dart';

class AuthScreenImg extends StatelessWidget {
  const AuthScreenImg({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: deviceHeight*0.26,
      width: deviceWidth,
      child: Image.asset(
        isDarkMode
            ? "lib/assets/images/sunny_dark.jpg"
            : "lib/assets/images/sunny_light.jpg",
        fit: BoxFit.fill,
      ),
    );
  }
}
