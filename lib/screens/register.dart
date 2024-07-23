import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/models/phone_info.dart';
import 'package:juno/widgets/auth_google_btn.dart';
import 'package:juno/widgets/auth_input_field.dart';
import 'package:juno/widgets/auth_phone_input.dart';
import 'package:juno/widgets/auth_screen_img.dart';
import 'package:juno/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? name;

  String? email;

  PhoneInfo? phone;

  String? address;

  String? password;

  String? confirmPassword;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;

  bool isLoading = false;

  void saveFormData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(
          msg: "Passwords don't match!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      // Firebase Stuff
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email!, password: password!);

      currentUser = userCredential.user;
      // Saving user data in realtime database
      if (currentUser != null) {
        Map<String, String> userMap = {
          "id": currentUser!.uid,
          "name": name!,
          "email": email!,
          "address": address!,
          "phone": jsonEncode(phone!.toJson()),
          "imageurl": "Not Defined",
        };

        DatabaseReference ref = firebaseDatabase.ref().child('users');
        ref.child(currentUser!.uid).set(userMap);
      }

      // Updating Auth Status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("logged-in", true);

      Fluttertoast.showToast(
        msg: "Registered Successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Get.toNamed('/home');
    } catch (error) {
      Fluttertoast.showToast(
          msg: "Error Occured : ${error}",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Register",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
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
                      AuthGoogleBtn(
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
