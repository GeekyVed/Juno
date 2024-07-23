import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:juno/models/phone_info.dart';

class AuthPhoneInput extends StatelessWidget {
  const AuthPhoneInput({
    super.key,
    required this.onSave,
  });

  final Function(PhoneInfo) onSave;
  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IntlPhoneField(
        decoration: InputDecoration(
          label: const Text(
            "Phone",
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          filled: true,
          fillColor: Theme.of(context).colorScheme.onInverseSurface,
          labelStyle: Theme.of(context).textTheme.labelMedium,
          prefixIcon: const Icon(
            Icons.phone,
          ),
          prefixIconColor: Theme.of(context).colorScheme.onSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              18,
            ),
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          counterText: "",
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.toString().trim().isEmpty) {
            return 'Phone can\'t be empty!';
          }

          return null;
        },
        onSaved: (PhoneNumber? value) {
          onSave(PhoneInfo.fromPhoneNumber(value!));
        },
        initialCountryCode: 'IN',
        style: Theme.of(context).textTheme.labelMedium,
        dropdownTextStyle: Theme.of(context).textTheme.labelMedium,
        pickerDialogStyle: PickerDialogStyle(
          searchFieldInputDecoration: InputDecoration(
            hintText: 'Search country',
            hintStyle: Theme.of(context).textTheme.labelMedium,
          ),
          countryNameStyle: Theme.of(context).textTheme.labelMedium,
          countryCodeStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
