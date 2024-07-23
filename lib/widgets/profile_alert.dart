import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:juno/assistants/assistant_methods.dart';
import 'package:juno/global.dart';

class ProfileAlertDialog extends StatelessWidget {
  const ProfileAlertDialog({
    Key? key,
    required this.editedValues,
    required this.originalValues,
  }) : super(key: key);

  final Map<String, dynamic> originalValues;
  final Map<String, dynamic> editedValues;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Confirm Changes',
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...editedValues.keys.map((key) {
              bool hasChanged = originalValues[key] != editedValues[key];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (key.toLowerCase() == "phone")
                    hasChanged
                        ? Column(
                            children: [
                              _buildValueRow(
                                'Original:',
                                originalValues['Phone']!.getjustNumber(),
                                Colors.red,
                                context,
                              ),
                              _buildValueRow(
                                'New:',
                                editedValues['Phone']!.getjustNumber(),
                                Colors.green,
                                context,
                              ),
                            ],
                          )
                        : _buildValueRow(
                            'Unchanged:',
                            originalValues[key]!,
                            Colors.grey,
                            context,
                          ),
                  if (key.toLowerCase() != "phone")
                    hasChanged
                        ? Column(
                            children: [
                              _buildValueRow(
                                'Original:',
                                originalValues[key]!.toString(),
                                Colors.red,
                                context,
                              ),
                              _buildValueRow(
                                'New:',
                                editedValues[key]!.toString(),
                                Colors.green,
                                context,
                              ),
                            ],
                          )
                        : _buildValueRow(
                            'Unchanged:',
                            originalValues[key]!.toString(),
                            Colors.grey,
                            context,
                          ),
                  const SizedBox(height: 15),
                ],
              );
            }),
          ],
        ),
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 19),
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: ()async {
            DatabaseReference userRef = firebaseDatabase.ref().child("users");
            await userRef.child(firebaseAuth.currentUser!.uid).update({
              "name": editedValues["Name"],
              "phone": jsonEncode(editedValues["Phone"]!.toJson()),
              "address": editedValues["Address"]!,
            });

            Get.back(result: true);
          },
          child: const Text('Confirm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildValueRow(
      String label, String value, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
