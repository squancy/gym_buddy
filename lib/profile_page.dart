import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';
import 'consts/common_consts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

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

Future<String?> getUserID() async {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  return prefs.getString('userID');
}

class ProfilePhoto extends StatefulWidget {
  const ProfilePhoto({super.key});

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  var _image = File('assets/default_profile_pic.png');
  final picker = ImagePicker();
  bool showAsset = true;

  void getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final userID = await getUserID();
    if (pickedFile != null) {
      uploadPic(File(pickedFile.path), userID);
    }

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        showAsset = false;
      }
    });
  }

  void uploadPic(File file, String? userID) async {
    final extension = p.extension(file.path);
    final metadata = SettableMetadata(contentType: "image/${extension.substring(1)}");
    final storageRef = FirebaseStorage.instance.ref();
    final uuid = Uuid();
    final filename = "${uuid.v4()}$extension";
    final pathname = "images/$userID/$filename";
    final cmd = img.Command()..decodeImageFile(file.path)..copyResize(width: 100)..writeToFile(file.path);
    await cmd.executeThread();
    final uploadTask = await storageRef.child(pathname).putFile(file, metadata);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    print(downloadUrl);
  }

  void getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    final userID = await getUserID();

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadPic(_image, userID);
        showAsset = false;
      }
    });
  }

  // TODO: make UI work on android as well
  void showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: showOptions,
      child: Builder(
        builder: (context) {
          return CircleAvatar(
            radius: 40,
            backgroundImage: showAsset ? AssetImage(_image.path) : FileImage(_image)
          );
        }
      ),
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final _spinkit = SpinKitFadingCircle(color: Colors.white, size: 25);
  final _toggleEditDUname = Toggle();
  final _toggleEditBio = Toggle();
  final _controller = TextEditingController();
  final _bioController = TextEditingController();

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserData() async {
    // First get the ID of the user currently logged in 
    final userID = await getUserID();
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

  void saveNewData(String newData, int maxLen, String fieldName, {required bool isBio}) async {
    if (Characters(newData).length > maxLen || (Characters(newData).isEmpty && !isBio)) {
      return;
    }

    final userID = await getUserID();
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
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getUserData(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
            final String username = data['username'];
            var displayUsername = data['displayUsername'];
            var bio = data['bio'];
            final String profilePicPath = data['profilePicPath']; // will be used later

            void resetToText(tap) {
              if (_toggleEditDUname.showEdit.value) {
                displayUsername = _controller.text;
                saveNewData(
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
                saveNewData(bio, ProfileConsts.MAX_BIO_LEN, 'bio', isBio: true);
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
                  saveNewData(
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
                          if (bio.isEmpty) {
                            FocusScope.of(context).unfocus();      
                            _toggleEditBio.makeEditable();
                          }
                          resetToTextBio(tap);
                        },
                        child: GestureDetector(
                          onDoubleTap: () {
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
              child: _spinkit,
            );
          }
        }
      )
    );
  }
}