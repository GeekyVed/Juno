import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class AuthInputField extends StatefulWidget {
  AuthInputField({
    super.key,
    required this.label,
    required this.onSave,
    this.minLength = 5,
  });

  final String label;
  final int minLength;
  final Function(String) onSave;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  final int maxLength = 50;

  bool isPasswordVisible = false;

  void toggleVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Icon getPrefixIcon(String label) {
    switch (label.toLowerCase()) {
      case 'name':
        return const Icon(
          Icons.person,
        );
      case 'email':
        return const Icon(
          Icons.email,
        );

      case 'address':
        return const Icon(
          Icons.location_on,
        );
      case 'password':
        return const Icon(
          Icons.password,
        );
      case 'confirm password':
        return const Icon(
          Icons.password,
        );
      default:
        return const Icon(
          Icons.info,
        );
    }
  }

  IconButton? suffixButtonForPassword() {
    if (widget.label.toLowerCase() == "password" ||
        widget.label.toLowerCase() == "confirm password") {
      return IconButton(
        onPressed: () {
          toggleVisibility();
        },
        icon: Icon(
          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
        ),
      );
    }
    return null;
  }

  @override
  build(BuildContext context) {
    final bool isPassword = widget.label.toLowerCase() == "password" ||
        widget.label.toLowerCase() == "confirm password";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          label: Text(
            widget.label,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          filled: true,
          fillColor: Theme.of(context).colorScheme.onInverseSurface,
          labelStyle: Theme.of(context).textTheme.labelMedium,
          prefixIcon: getPrefixIcon(widget.label),
          prefixIconColor: Theme.of(context).colorScheme.onSurface,
          suffixIcon: suffixButtonForPassword(),
          suffixIconColor: Theme.of(context).colorScheme.onSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              18,
            ),
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '${widget.label} can\'t be empty!';
          }

          if (value.trim().length > maxLength) {
            return '${widget.label} can\'t be more than $maxLength!';
          }

          if (value.trim().length < widget.minLength) {
            return 'Enter a valid ${widget.label}!';
          }

          if (widget.label.toLowerCase() == 'email' &&
              !EmailValidator.validate(value.trim())) {
            return 'Enter a valid ${widget.label}!';
          }
          return null;
        },
        obscureText: isPassword && !isPasswordVisible,
        onSaved: (value) {
          widget.onSave(value!.trim());
        },
      ),
    );
  }
}
