import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? imageurl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.address,
    required this.phone,
    required this.imageurl,
  });

  UserModel.fromSnapshot(DataSnapshot snapshot) {
    id = (snapshot.value as dynamic)['id'];
    name = (snapshot.value as dynamic)['name'];
    email = (snapshot.value as dynamic)['email'];
    address = (snapshot.value as dynamic)['address'];
    phone = (snapshot.value as dynamic)['phone'];
    imageurl = (snapshot.value as dynamic)['imageurl'];
  }
}
