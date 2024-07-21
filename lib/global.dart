import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:juno/models/direction_details_info.dart';
import 'package:juno/models/user_model.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

User? currentUser;

UserModel? userModelCurrentInfo;

String userDropoffAddress = "";

DirectionDetailsInfo? tripDirectionDetailsInfo;