import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class ProfileInputField extends StatefulWidget {
  const ProfileInputField({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onSave,
    this.minLength = 5,
  }) : super(key: key);

  final String label;
  final String initialValue;
  final int minLength;
  final Function(String) onSave;

  @override
  State<ProfileInputField> createState() => _ProfileInputFieldState();
}

class _ProfileInputFieldState extends State<ProfileInputField> {
  final int maxLength = 50;
  bool isEditable = false;

  late String _editedValue;

  @override
  void initState() {
    super.initState();
    _editedValue = widget.initialValue;
  }

  void toggleEdit() {
    setState(() {
      isEditable = !isEditable;
    });
    if (!isEditable) {
      widget.onSave(_editedValue!);
    }
  }

  Icon getPrefixIcon(String label) {
    switch (label.toLowerCase()) {
      case 'name':
        return const Icon(Icons.person);
      case 'email':
        return const Icon(Icons.email);
      case 'address':
        return const Icon(Icons.location_on);
      case 'phone':
        return const Icon(Icons.phone);
      default:
        return const Icon(Icons.info);
    }
  }

  Widget suffixButtonForEdit() {
    return Padding(
      padding: isEditable
          ? EdgeInsets.only(right: 12.0)
          : EdgeInsets.only(right: 0.0),
      child: IconButton(
        onPressed: toggleEdit,
        icon: Icon(
          isEditable ? Icons.done : Icons.edit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isEditable ? editableForm() : nonEditableForm();
  }

  Widget editableForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        initialValue: _editedValue,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: widget.label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          prefixIcon: getPrefixIcon(widget.label),
          prefixIconColor: Theme.of(context).colorScheme.onSurface,
          suffixIcon: suffixButtonForEdit(),
          suffixIconColor: Theme.of(context).colorScheme.onSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: _validateInput,
        onChanged: (value) {
          setState(() {
            _editedValue = value;
          });
        },
      ),
    );
  }

  Widget nonEditableForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            getPrefixIcon(widget.label),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _editedValue,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            suffixButtonForEdit(),
          ],
        ),
      ),
    );
  }

  String? _validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${widget.label} can\'t be empty!';
    }
    if (value.trim().length > maxLength) {
      return '${widget.label} can\'t be more than $maxLength characters!';
    }
    if (value.trim().length < widget.minLength) {
      return 'Enter a valid ${widget.label}!';
    }
    if (widget.label.toLowerCase() == 'email' &&
        !EmailValidator.validate(value.trim())) {
      return 'Enter a valid email address!';
    }
    if (widget.label.toLowerCase() == 'phone' &&
        !_isValidPhoneNumber(value.trim())) {
      return 'Enter a valid phone number!';
    }
    return null;
  }

  bool _isValidPhoneNumber(String phone) {
    // Add your phone number validation logic here
    // This is a simple example, you might want to use a more robust validation
    final phoneRegExp = RegExp(r'^\+?[\d\s()-]{10,}$');
    return phoneRegExp.hasMatch(phone);
  }
}
