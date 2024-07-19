import 'package:flutter/material.dart';
import 'package:juno/global.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [Text(userModelCurrentinfo!.name ?? "null")],
      )),
    );
  }
}
