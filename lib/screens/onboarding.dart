import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/data/models/onboarding_screen_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static List<OnboardingScreenInfo> onboardingScreens = [
    OnboardingScreenInfo(
      0,
      "lib/assets/images/ride_together.jpg",
      "Ride Together, Save Together",
      "Experience the convenience of smart commuting, making your daily travels easier and more economical.",
    ),
    OnboardingScreenInfo(
      1,
      "lib/assets/images/match_and_go.jpg",
      "Match and Go",
      "Quickly find your ideal ride with our seamless matching system, ensuring a hassle-free journey every time.",
    ),
    OnboardingScreenInfo(
      2,
      "lib/assets/images/save_and_connect.jpg",
      "Reduce Costs, Increase Connections",
      "Enjoy affordable rides while forging new friendships and expanding your social network.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;

    return PageView.builder(
      itemCount: onboardingScreens.length,
      itemBuilder: (context, index) => Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: deviceHeight * 0.4,
                width: double.infinity,
                child: Image.asset(
                  onboardingScreens[index].imgURL,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: deviceHeight * 0.14,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      onboardingScreens[index].title,
                      style: GoogleFonts.quicksand(
                          fontSize: 26,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: deviceHeight * 0.03,
                    ),
                    Text(
                      onboardingScreens[index].subtitle,
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                    SizedBox(
                      height: deviceHeight * 0.055,
                    ),
                    if (index == 2)
                      ElevatedButton(
                        onPressed: () async {
                           SharedPreferences prefs = await SharedPreferences.getInstance();
                           prefs.setBool('first-checkin', false);
                           Get.offNamed('/register');
                        },
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: Text(
                          "Get Started",
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: onboardingScreens
                    .map((ele) => Container(
                          margin: EdgeInsets.all(12),
                          height: 13,
                          width: ele.idx == index ? 25 : 13,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(
                              100,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(
                height: deviceHeight * 0.06,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
