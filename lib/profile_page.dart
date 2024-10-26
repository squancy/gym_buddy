import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>> getUserData() async {
    // First get the ID of the user currently logged in 
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final String? userID = await prefs.getString('userID');
    await prefs.setBool('loggedIn', false);

    final FirebaseFirestore db = FirebaseFirestore.instance;
    final users = db.collection('users');
    final settingsDocRef = db.collection('user_settings').doc(userID);

    final QuerySnapshot userWithUID = await users.where('id', isEqualTo: userID).get();
    final user = userWithUID.docs[0].data() as Map<String, dynamic>;

    final usettings = await settingsDocRef.get();
    final userSettings = usettings.data() as Map<String, dynamic>;

    return {
      'username': user['username'],
      'displayUsername': userSettings['display_username'],
      'bio': userSettings['bio'],
      'profilePicPath': userSettings['profile_pic_path']
    };
  }

  final _spinkit = SpinKitFadingCircle(color: Colors.white, size: 25);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getUserData(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
            final String username = data['username'];
            final String displayUsername = data['displayUsername'];
            final String bio = data['bio'];
            final String profilePicPath = data['profilePicPath']; // will be used later

            return ListView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayUsername, style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold
                              )),
                              Text("@$username")
                            ],
                          ),
                          Image.asset('assets/default_profile_pic.png', height: 60,)
                        ],
                      ),
                    )
                  ],
                )
              ],
            );
          } else {
            return Center(
              child: _spinkit,
            );
          }
        }
      )
    );
  }
}