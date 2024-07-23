import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:juno/global.dart';
import 'package:juno/models/phone_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGoogleBtn extends StatefulWidget {
  AuthGoogleBtn({
    super.key,
    required this.label,
  });

  final String label;

  @override
  State<AuthGoogleBtn> createState() => _AuthGoogleBtnState();
}

class _AuthGoogleBtnState extends State<AuthGoogleBtn> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : handleGoogleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: EdgeInsets.zero, // Remove default padding
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.blue.shade500,
          borderRadius: BorderRadius.circular(18),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Container(
                height: 50, // Set a fixed height for the button
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/assets/icons/google_logo.jpg',
                      height: 60.0,
                    ),
                    const SizedBox(
                      width: 14,
                    ), // Space between icon and text
                    Expanded(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      width: 24,
                    ), // Balance the button
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await firebaseAuth.signInWithCredential(credential);

        currentUser = userCredential.user;
        if (currentUser != null) {
          await _saveUserData(currentUser!);
          await _updateAuthStatus();
          _showSuccessToast();
          Get.offAllNamed(
              '/home'); // Use offAllNamed to remove all previous routes
        }
      }
    } catch (error) {
      _showErrorToast(error.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveUserData(User user) async {
    final Map<String, String> userMap = {
      "id": user.uid,
      "name": user.displayName ?? "Not Defined",
      "email": user.email ?? "Not Defined",
      "address": "Not Defined",
      "phone": user.phoneNumber != null
          ? jsonEncode(PhoneInfo.fromPhoneNumber(PhoneNumber.fromCompleteNumber(
              completeNumber: user.phoneNumber!)))
          : "Not Defined",
      "imageurl": user.photoURL ?? "Not Defined",
    };

    final DatabaseReference ref = firebaseDatabase.ref().child('users');
    await ref.child(user.uid).set(userMap);
  }

  Future<void> _updateAuthStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged-in", true);
  }

  void _showSuccessToast() {
    Fluttertoast.showToast(
      msg: "Registered Successfully",
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String error) {
    Fluttertoast.showToast(
      msg: "Error Occurred: $error",
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
