import 'package:flutter/material.dart';
import 'package:project/page/edit_profile_page.dart';
import 'package:project/page/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic> userData = {};

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
        });
      }
    }
  }

  Widget _userInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value.isNotEmpty ? value : 'Not available'),
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              bool response = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
              if (response){
                _fetchUserData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: userData['profilePicture'] != null ? NetworkImage(userData['profilePicture']): null,
              child: userData['profilePicture'] == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(height: 20),
            _userInfoTile('Name', userData['name'] ?? ''),
            _userInfoTile('Surname', userData['surname'] ?? ''),
            _userInfoTile('Country', userData['country'] ?? ''),
            _userInfoTile('City', userData['city'] ?? ''),
            _userInfoTile('Phone', userData['phone'] ?? ''),
            _userInfoTile('Birthdate', userData['birthdate'] ?? ''),
            _userInfoTile('Sex', userData['sex'] ?? ''),
          ],
        ),
      ),
    );
  }
}
