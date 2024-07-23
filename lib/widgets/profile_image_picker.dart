import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juno/global.dart';
import 'package:firebase_database/firebase_database.dart';

class ImagePickerButton extends StatefulWidget {
  const ImagePickerButton({
    Key? key,
  }) : super(key: key);

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  ImageProvider? _selectedImage;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;
  bool _isImageChanged = false;
  File? _newImageFile;

  ImageProvider? _getUserImage() {
    if (userModelCurrentInfo?.imageurl != null &&
        userModelCurrentInfo?.imageurl != "Not Defined") {
      return NetworkImage(userModelCurrentInfo!.imageurl!);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedImage = _getUserImage();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImageFile = await _picker.pickImage(source: source);
    if (pickedImageFile != null) {
      setState(() {
        _newImageFile = File(pickedImageFile.path);
        _selectedImage = FileImage(_newImageFile!);
        _isImageChanged = true;
      });
    }
    _toggleExpand();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _saveImage() async {
    if (_newImageFile != null) {
      try {
        // Upload image to Firebase Storage
        final ref = FirebaseStorage.instance.ref().child('user_images/${firebaseAuth.currentUser!.uid}.jpg');
        await ref.putFile(_newImageFile!);
        final url = await ref.getDownloadURL();

        // // Update Realtime Database
        DatabaseReference userRef = firebaseDatabase.ref().child("users");
        userRef.child(firebaseAuth.currentUser!.uid).update({
          "imageurl": url
        });

        // Update userModelCurrentInfo
        userModelCurrentInfo!.imageurl = url;

        setState(() {
          _isImageChanged = false;
        });

        Fluttertoast.showToast(
          msg: 'Profile image updated successfully',
          backgroundColor: Colors.green,
          fontSize: 18,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Failed to update profile image',
          backgroundColor: Colors.red,
          fontSize: 18,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        SizedBox(
          width: _isImageChanged ? width * 0.23 : width * 0.33482,
        ),
        if (_isImageChanged)
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.inverseSurface,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: _saveImage,
              icon: Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.inverseSurface,
                size: 20,
              ),
            ),
          ),
        SizedBox(
          width: _isImageChanged ? width * 0.02 : width * 0,
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 4,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.lightBlue,
            backgroundImage: _selectedImage,
            child: _selectedImage == null
                ? const Icon(Icons.person, color: Colors.white, size: 55)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                onPressed: _toggleExpand,
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.inverseSurface,
                  size: 20,
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _animation,
              axis: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(
                        Icons.photo_library,
                        color: Theme.of(context).colorScheme.inverseSurface,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).colorScheme.inverseSurface,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
