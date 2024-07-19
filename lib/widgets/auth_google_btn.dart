import 'package:flutter/material.dart';

class AuthGoogleBtn extends StatelessWidget {
  const AuthGoogleBtn({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {


// Login Butin
// sHARED pREFS



      },
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
        child: Container(
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
                  label,
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
}
