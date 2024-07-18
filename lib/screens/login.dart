import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/widgets/auth_google_btn.dart';
import 'package:juno/widgets/auth_input_field.dart';
import 'package:juno/widgets/auth_screen_img.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  String? email;
  String? password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  void saveFormData() {
    //Firebase Stuff
    Get.toNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthScreenImg(),
                SizedBox(
                  height: deviceHeight * 0.015,
                ),
                Text(
                  "L O G I N",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(
                  height: deviceHeight * 0.015,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      AuthInputField(
                        label: "Email",
                        onSave: (val) {
                          email = val;
                        },
                      ),
                      AuthInputField(
                        label: "Password",
                        onSave: (val) {
                          password = val;
                        },
                        minLength: 8,
                      ),
                      SizedBox(
                        height: deviceHeight * 0.025,
                      ),
                      ElevatedButton(
                        onPressed: saveFormData,
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: Text(
                          "Login",
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.008,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password!",
                          style: GoogleFonts.quicksand(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).colorScheme.onSurface,
                              thickness: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          TextButton(
                            onPressed: () {
                              Get.toNamed('/register');
                            },
                            child: Text(
                              "Don't have an Account!",
                              style: GoogleFonts.quicksand(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).colorScheme.onSurface,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: deviceHeight * 0.01,
                      ),
                      const AuthGoogleBtn(
                        label: "Sign In with Google",
                      ),
                      SizedBox(
                        height: deviceHeight * 0.05,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
