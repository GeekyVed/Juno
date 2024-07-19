import 'package:firebase_database/firebase_database.dart';
import 'package:juno/global.dart';
import 'package:juno/models/user_model.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = await firebaseAuth.currentUser;

    DatabaseReference ref =
        firebaseDatabase.ref().child("users").child(currentUser!.uid);
    ref.once().then((snap) {
      if (snap.snapshot.value != null) {
        DataSnapshot snapshot = snap.snapshot;
        userModelCurrentinfo = UserModel.fromSnapshot(snapshot);
      }
    });
  }
}
