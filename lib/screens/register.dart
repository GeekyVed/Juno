import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/widgets/auth_google_btn.dart';
import 'package:juno/widgets/auth_input_field.dart';
import 'package:juno/widgets/auth_phone_input.dart';
import 'package:juno/widgets/auth_screen_img.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  String? name;
  String? email;
  String? phone;
  String? address;
  String? password;
  String? confirmPassword;

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
                  "R E G I S T E R",
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
                        label: "Name",
                        onSave: (val) {
                          name = val;
                        },
                      ),
                      AuthInputField(
                        label: "Email",
                        onSave: (val) {
                          email = val;
                        },
                      ),
                      AuthPhoneInput(
                        onSave: (val) {
                          phone = val;
                        },
                      ),
                      AuthInputField(
                        label: "Address",
                        onSave: (val) {
                          address = val;
                        },
                      ),
                      AuthInputField(
                        label: "Password",
                        onSave: (val) {
                          password = val;
                        },
                        minLength: 8,
                      ),
                      AuthInputField(
                        label: "Confirm Password",
                        onSave: (val) {
                          confirmPassword = val;
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
                          "Register",
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
                              Get.toNamed('/login');
                            },
                            child: Text(
                              "Already Have an Account!",
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
                        label: "Sign Up with Google",
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
