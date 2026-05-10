import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project/constants/color.dart';
import 'package:project/page/home_page.dart';
import 'package:project/page/profile_page.dart';
import 'package:project/page/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EditProfilePage> {
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic> userData = {};

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();

  String _profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DataSnapshot snapshot = await _database.child('users/${user.uid}').get();
      if (snapshot.exists) {
        setState(() {
          userData = Map<String, dynamic>.from(snapshot.value as Map);
          _nameController.text = userData['name'] ?? '';
          _surnameController.text = userData['surname'] ?? '';
          _countryController.text = userData['country'] ?? '';
          _cityController.text = userData['city'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _birthdateController.text = userData['birthdate'] ?? '';
          _sexController.text = userData['sex'] ?? '';
          _profilePictureUrl = userData['profilePicture'] ?? '';
        });
      }
    }
  }

  Future<String> uploadProfilePic(XFile? image) async{
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref('pp').child(imageName);
    UploadTask uploadTask;
    if (kIsWeb) {
      final bytes = await image!.readAsBytes();
      final blob = html.Blob([bytes]);
      uploadTask = storageRef.putBlob(blob);
    } else {
      final file = File(image!.path);
      uploadTask = storageRef.putFile(file);
    }
    await uploadTask.whenComplete(() => null);
    final url = await storageRef.getDownloadURL();

    return url;
  }

  Future<void> _pickImage(String source) async {
    ImageSource imgSource = ImageSource.gallery;
    if (source == 'camera'){
      imgSource = ImageSource.camera;
    }
    final pickedFile = await picker.pickImage(source: imgSource);
    String newPP = await uploadProfilePic(pickedFile);
    if (pickedFile != null) {
      setState(() {
        _profilePictureUrl = newPP;
      });
      // Upload the image to Firebase Storage and update the user's profile picture URL.
    }
  }

  Future<void> _saveChanges() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _database.child('users/${user.uid}').update({
        'name': _nameController.text,
        'surname': _surnameController.text,
        'country': _countryController.text,
        'city': _cityController.text,
        'phone': _phoneController.text,
        'birthdate': _birthdateController.text,
        'sex': _sexController.text,
        'profilePicture': _profilePictureUrl,
      });
    }
  }

  Widget _buildEditableField(String title, TextEditingController controller) {
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }

  Future _showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
              child: const Text('Photo Gallery'),
              onPressed: () {
                // close the options modal
                Navigator.of(context).pop();
                // get image from gallery
                _pickImage('gallery');
              }),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              _pickImage('camera');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: (){
              _saveChanges();
              Navigator.pop(context, true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _nameController.text = userData['name'] ?? '';
                _surnameController.text = userData['surname'] ?? '';
                _countryController.text = userData['country'] ?? '';
                _cityController.text = userData['city'] ?? '';
                _phoneController.text = userData['phone'] ?? '';
                _birthdateController.text = userData['birthdate'] ?? '';
                _sexController.text = userData['sex'] ?? '';
                _profilePictureUrl = userData['profilePicture'] ?? '';
              });
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Stack(
              fit: StackFit.passthrough,
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _profilePictureUrl != null
                      ? NetworkImage(_profilePictureUrl)
                      : null,
                  child: _profilePictureUrl == null
                      ? Icon(Icons.person, size: 50, color: Colors.grey.shade600)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  child: FractionalTranslation(
                    translation: const Offset(1, 0),
                    child: GestureDetector(
                      onTap: _showOptions,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(Icons.edit, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildEditableField('Name', _nameController),
            _buildEditableField('Surname', _surnameController),
            _buildEditableField('Country', _countryController),
            _buildEditableField('City', _cityController),
            _buildEditableField('Phone', _phoneController),
            _buildEditableField('Birthdate', _birthdateController),
            _buildEditableField('Sex', _sexController),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
