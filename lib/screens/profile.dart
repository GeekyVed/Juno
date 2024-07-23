import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:juno/assistants/assistant_methods.dart';
import 'package:juno/global.dart';
import 'package:juno/models/phone_info.dart';
import 'package:juno/widgets/profile_alert.dart';
import 'package:juno/widgets/profile_image_picker.dart';
import 'package:juno/widgets/profile_input_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, dynamic> _originalValues = {};
  Map<String, dynamic> _editedValues = {};

  @override
  void initState() {
    super.initState();
    var phoneNumber = PhoneInfo.fromJson(jsonDecode(
      userModelCurrentInfo!.phone!,
    ));

    _originalValues = {
      'Name': userModelCurrentInfo!.name!,
      'Phone': phoneNumber,
      'Address': userModelCurrentInfo!.address!,
    };
    _editedValues = Map.from(_originalValues);
  }

  bool areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;

      final value1 = map1[key];
      final value2 = map2[key];

      if (key == 'Phone') {
        if (value1 is! PhoneInfo || value2 is! PhoneInfo) {
          return false;
        }
        final phoneInfo1 = value1 as PhoneInfo;
        final phoneInfo2 = value2 as PhoneInfo;
        // Compare PhoneInfo properties here (e.g., countryISOCode, countryCode, number)
        if (phoneInfo1.countryISOCode != phoneInfo2.countryISOCode ||
            phoneInfo1.countryCode != phoneInfo2.countryCode ||
            phoneInfo1.number != phoneInfo2.number) {
          return false;
        }
      } else {
        if (value1 is String && value2 is String) {
          if (value1 != value2) return false;
        } else {
          if (value1 != value2) return false;
        }
      }
    }

    return true;
  }

  Future<void> showChangesDialogAlert() {
    return Get.dialog(
      ProfileAlertDialog(
        editedValues: _editedValues,
        originalValues: _originalValues,
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        Fluttertoast.showToast(
          msg: 'Profile updated successfully!',
          backgroundColor: Colors.green,
          fontSize: 18,
        );
        setState(() {
          AssistantMethods.readCurrentOnlineUserInfo();
        });
      }
    });
  }

  void handleFormSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (areMapsEqual(_editedValues, _originalValues)) {
        Fluttertoast.showToast(
          msg: "No Changes Made",
          backgroundColor: Colors.red,
        );
        return;
      }
      showChangesDialogAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            "Profile Section",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Center(child: ImagePickerButton()),
                const SizedBox(
                  height: 30,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ProfileInputField(
                        label: "Name",
                        onSave: (value) {
                          _editedValues['Name'] = value;
                        },
                        initialValue: _originalValues['Name']!,
                      ),
                      ProfileInputField(
                        label: "Phone",
                        onSave: (value) {
                          PhoneNumber enteredNum =
                              PhoneNumber.fromCompleteNumber(
                                  completeNumber: value);
                          //Adding plus in country Code
                          PhoneNumber modified = PhoneNumber(
                              countryISOCode: enteredNum.countryISOCode,
                              countryCode: "+${enteredNum.countryCode}",
                              number: enteredNum.number);
                          PhoneInfo phone = PhoneInfo.fromPhoneNumber(modified);
                          _editedValues['Phone'] = phone;
                        },
                        initialValue: _originalValues['Phone'].getjustNumber(),
                      ),
                      ProfileInputField(
                        label: "Address",
                        onSave: (value) {
                          _editedValues['Address'] = value;
                        },
                        initialValue: _originalValues['Address']!,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    firebaseAuth
                        .sendPasswordResetEmail(
                            email: userModelCurrentInfo!.email!)
                        .then((_) {
                      Fluttertoast.showToast(
                        msg: "Send Recovery mail!",
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }).catchError((e) {
                      Fluttertoast.showToast(
                        msg: "Error Occurred: $e",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    });
                  },
                  style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.blue)),
                  child: Text(
                    "Change Password",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                ElevatedButton(
                  onPressed: handleFormSave,
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Text(
                    "Update Information",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
