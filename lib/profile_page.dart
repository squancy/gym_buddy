import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'consts/common_consts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:transparent_image/transparent_image.dart';
import 'utils/photo_upload_popup.dart';
import 'utils/upload_image_firestorage.dart';
import 'utils/helpers.dart' as helpers;
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instance.ref();

/*

*/
final SharedPreferencesAsync prefs = SharedPreferencesAsync();
final x = prefs.setBool('loggedIn', false);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class Toggle {
  final ValueNotifier<bool> showEdit = ValueNotifier<bool>(false);

  void makeEditable() {
    showEdit.value = true;
  }

  void makeUneditable() {
    showEdit.value = false;
  }
}

class ProfilePhoto extends StatefulWidget {
  const ProfilePhoto({super.key});

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class ProfilePicPlaceholder extends StatelessWidget {
  const ProfilePicPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Color.fromARGB(255, 14, 22, 29),
    );
  }
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  var _image = File(ProfileConsts.defaultProfilePicPath);
  final _picker = ImagePicker();
  bool _showFile = false;

  Future<void> _uploadPic(File file, String? userID) async {
    var (String downloadURL, String filename) = await UploadImageFirestorage(storageRef).uploadImage(file, 100, "profile_pics/$userID");
    final settingsDocRef = db.collection('user_settings').doc(userID);
    try {
      await settingsDocRef.update({
        'profile_pic_path': filename,
        'profile_pic_url': downloadURL
      });
    } catch (e) {
      // ...
    }
  }

  void _selectFromSource(ImageSource sourceType) async {
    final pickedFile = await _picker.pickImage(source: sourceType);
    final userID = await helpers.getUserID();
    if (pickedFile != null) {
      _uploadPic(File(pickedFile.path), userID);
    }

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _showFile = true;
      }
    });
  }

  Future<String> _getProfilePicURL() async {
    final userID = await helpers.getUserID();
    final settingsDocRef = db.collection('user_settings').doc(userID);
    final usettings = await settingsDocRef.get();
    final userSettings = usettings.data() as Map<String, dynamic>;
    return userSettings['profile_pic_url'];
  }

  Future<Map<String, String>> _getProfilePicFile() async {
    final profilePicURL = await _getProfilePicURL();
    if (profilePicURL.isEmpty) {
      return {'type': 'default', 'path': ProfileConsts.defaultProfilePicPath};
    }
    return {'type': 'url', 'path': profilePicURL};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getProfilePicFile(),
      builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
        final uploadPopup = PhotoUploadPopup(context, _selectFromSource);
        if (snapshot.hasData) {
          dynamic bgImage;
          if (snapshot.data?['type'] == 'default') {
            bgImage = Image.asset(snapshot.data?['path'] as String, width: 80, height: 80, fit: BoxFit.cover);
          } else {
            bgImage = FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data?['path'] as String,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            );
          }
          return GestureDetector(
            onDoubleTap: uploadPopup.showOptions,
            child: Builder(
              builder: (context) {
                return Stack(
                  children: [
                    ProfilePicPlaceholder(),
                    ClipOval(
                      child: _showFile ? Image.file(_image, width: 80, height: 80, fit: BoxFit.cover,) : bgImage,
                    )
                  ]
                );
              }
            ),
          );
        } else {
          return ProfilePicPlaceholder();
        }
      }
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final _toggleEditDUname = Toggle();
  final _toggleEditBio = Toggle();
  final _controller = TextEditingController();
  final _bioController = TextEditingController();

  Future<Map<String, dynamic>> _getUserData() async {
    // First get the ID of the user currently logged in 
    final userID = await helpers.getUserID();
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
      // 'profilePicPath': userSettings['profile_pic_path'],
      // 'profilePicURL': userSettings['profile_pic_url']
    };
  }

  void _saveNewData(String newData, int maxLen, String fieldName, {required bool isBio}) async {
    if (Characters(newData).length > maxLen || (Characters(newData).isEmpty && !isBio)) {
      return;
    }

    final userID = await helpers.getUserID();
    final settingsDocRef = db.collection('user_settings').doc(userID);

    try {
      await settingsDocRef.update({fieldName: newData});
    } catch (e) {
      // ...
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bioController.dispose();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getUserData(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
            final String username = data['username'];
            var displayUsername = data['displayUsername'];
            var bio = data['bio'];

            void resetToText(tap) {
              if (_toggleEditDUname.showEdit.value) {
                displayUsername = _controller.text;
                _saveNewData(
                  displayUsername,
                  ValidateSignupConsts.MAX_USERNAME_LEN,
                  'display_username',
                  isBio: false
                );
                _toggleEditDUname.makeUneditable();
              }
            } 

            void resetToTextBio(tap) {
              if (_toggleEditBio.showEdit.value) {
                bio = _bioController.text;
                _saveNewData(bio, ProfileConsts.MAX_BIO_LEN, 'bio', isBio: true);
                _toggleEditBio.makeUneditable();
              }
            }

            Widget buildBioField({required bool autofocus}) {
              return TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write something about yourself...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  counterText: '',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                autofocus: autofocus,
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 0,
                  height: 1.4
                ),
                controller: _bioController,
                maxLines: null,
                onSubmitted: (context) {
                  _saveNewData(
                    _bioController.text,
                    ProfileConsts.MAX_BIO_LEN,
                    'bio',
                    isBio: true
                  );
                  resetToText(null);
                },
              );
            }

            return ListView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            TapRegion(
                              onTapOutside: resetToText,
                              child: GestureDetector(
                                onDoubleTap: () {
                                  _toggleEditDUname.makeEditable();
                                  _controller.text = displayUsername;
                                },
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: _toggleEditDUname.showEdit,
                                  builder: (context, value, child) {
                                    if (_toggleEditDUname.showEdit.value) {
                                      return TextField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          counterText: '',
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        controller: _controller,
                                        autofocus: true,
                                        maxLength: 100,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0,
                                        ),
                                        onSubmitted: resetToText,
                                      );
                                    } else {
                                      return Text(displayUsername, style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ));
                                    }
                                  }),
                                ),
                            ),
                              Text("@$username")
                            ],
                          ),),
                          ProfilePhoto()
                        ],
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                  child: Builder(
                    builder: (context) {
                      if (bio.isEmpty) {
                        _toggleEditBio.makeEditable();
                      }
                      return TapRegion(
                        onTapOutside: (tap) {
                          if (_bioController.text.isEmpty) {
                            FocusScope.of(context).unfocus();      
                            // _toggleEditBio.makeUneditable();
                          } else {
                            resetToTextBio(tap);
                          }
                        },
                        child: GestureDetector(
                          onDoubleTap: () {
                            if (_bioController.text.isEmpty) return;
                            _toggleEditBio.makeEditable();
                            _bioController.text = bio;
                          },
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _toggleEditBio.showEdit,
                            builder: (context, value, child) {
                              if (_toggleEditBio.showEdit.value) {
                                return buildBioField(autofocus: !bio.isEmpty);
                              } else {
                                return Text(
                                  bio,
                                  style: TextStyle(letterSpacing: 0, height: null),
                                );
                              }
                            }
                          ),
                        ),
                      );
                    },
                  ),
                ), 
                Divider(
                  color: Colors.grey
                ),
              ],
            );
          } else {
            return Center(
              child: GlobalConsts.spinkit,
            );
          }
        }
      )
    );
  }
}