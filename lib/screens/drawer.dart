import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  Future<void> _handleLogout() async {
    try {
      // Updating Auth Status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("logged-in", false);
      await firebaseAuth.signOut();

      // Navigate to login screen and remove all previous routes
      Get.offAllNamed('/login');
    } catch (e) {
      print("Error during logout: $e");
      // Optionally show an error message to the user
      Fluttertoast.showToast(
        msg: "Error: Failed to logout. Please try again.",
        backgroundColor: Colors.red,
      );
    }
  }

  ImageProvider? _getUserImage() {
    if (userModelCurrentInfo?.imageurl != null && userModelCurrentInfo?.imageurl != "Not Defined") {
      return NetworkImage(userModelCurrentInfo!.imageurl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 65,
          ),
          Center(
            child: 
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.lightBlue,
                    backgroundImage: _getUserImage(),
                    child: _getUserImage() == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 50,
                          )
                        : null,
                  ),
                ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              userModelCurrentInfo?.name ?? "User Name",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            title: Text(
              "Edit Profile",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.blue,
                  ),
            ),
            leading: const Icon(
              Icons.edit,
              color: Colors.blue,
            ),
            onTap: () {
              Get.toNamed('/profile');
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              "Your Trips",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.map,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            onTap: () {
              // Handle Your Trips action
            },
          ),
          ListTile(
            title: Text(
              "Payment",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.payment,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            onTap: () {
              // Handle Payment action
            },
          ),
          ListTile(
            title: Text(
              "Notifications",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            onTap: () {
              // Handle Notifications action
            },
          ),
          ListTile(
            title: Text(
              "Promos",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.local_offer,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            onTap: () {
              // Handle Promos action
            },
          ),
          ListTile(
            title: Text(
              "Help",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.help,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            onTap: () {
              // Handle Help action
            },
          ),
          ListTile(
            title: Text(
              "Free Trips",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.card_giftcard,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            onTap: () {
              // Handle Free Trips action
            },
          ),
          const SizedBox(
            height: 260,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 17.0,
              horizontal: 20,
            ),
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                textStyle: GoogleFonts.quicksand(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: Text(
                "Logout",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
