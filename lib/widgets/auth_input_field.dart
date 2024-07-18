import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthInputFieldController extends GetxController {
  RxBool isPasswordVisible = false.obs;

  void toggleVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}

class AuthInputField extends StatelessWidget {
  static final AuthInputFieldController authInputFieldController =
      Get.put(AuthInputFieldController());

  AuthInputField({
    super.key,
    required this.label,
    required this.onSave,
    this.minLength = 5,
  });

  final String label;
  final int minLength;
  final Function(String) onSave;

  final int maxLength = 50;

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
    if (label.toLowerCase() == "password" ||
        label.toLowerCase() == "confirm password") {
      return IconButton(
        onPressed: () {
          authInputFieldController.toggleVisibility();
        },
        icon: Icon(
          authInputFieldController.isPasswordVisible.value
              ? Icons.visibility_off
              : Icons.visibility,
        ),
      );
    }
    return null;
  }

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(
        () => TextFormField(
          decoration: InputDecoration(
            label: Text(
              label,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            filled: true,
            fillColor: Theme.of(context).colorScheme.onInverseSurface,
            labelStyle: Theme.of(context).textTheme.labelMedium,
            prefixIcon: getPrefixIcon(label),
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
              return '${label} can\'t be empty!';
            }

            if (value.trim().length > maxLength) {
              return '${label} can\'t be more than $maxLength!';
            }

            if (value.trim().length < minLength) {
              return 'Enter a valid ${label}!';
            }

            if (label.toLowerCase() == 'email' &&
                !EmailValidator.validate(value.trim())) {
              return 'Enter a valid ${label}!';
            }
            return null;
          },
          obscureText: !authInputFieldController.isPasswordVisible.isTrue,
          onSaved: (value) {
            onSave(value!);
          },
        ),
      ),
    );
  }
}
