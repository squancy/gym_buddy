import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/main.dart';
import 'consts/common_consts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'utils/photo_upload_popup.dart';
import 'utils/upload_image_firestorage.dart';
import 'utils/helpers.dart' as helpers;
import 'utils/post_builder.dart' as post_builder;
import 'package:image_fade/image_fade.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instance.ref();

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

class _ProfilePhotoState extends State<ProfilePhoto> {
  var _image = File(ProfileConsts.defaultProfilePicPath);
  final _picker = ImagePicker();
  bool _showFile = false;

  Future<void> _uploadPic(File file, String? userID) async {
    var (String downloadURL, String filename) = await UploadImageFirestorage(storageRef).uploadImage(file, 200, "profile_pics/$userID");
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
            bgImage = AssetImage(snapshot.data?['path'] as String);
          } else {
            bgImage = NetworkImage(snapshot.data?['path'] as String);
          }
          return GestureDetector(
            onDoubleTap: uploadPopup.showOptions,
            child: Builder(
              builder: (context) {
                return SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipOval(
                    child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                      child: ImageFade(
                        image: _showFile ? FileImage(_image) : bgImage,
                        placeholder: Container(
                          width: 80,
                          height: 80,
                          color: Colors.black,
                        ),
                      )
                    ),
                  ),
                );
              }
            ),
          );
        } else {
          return helpers.ProfilePicPlaceholder(radius: 40,);
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
  var _lastVisible;
  bool _isFirst = true;
  var _firstVisible;
  var _getPostsByUserFuture;
  var _getUserDataFuture;
  FocusNode bioFocusNode = FocusNode();

  @override
  void initState() {
    _getUserDataFuture = _getUserData();
    super.initState();
  }

  Future<List<Map<String, dynamic>>> _getPostsByUser() async {
    if (_lastVisible == null) return [];
    String? userID = await helpers.getUserID();
    List<Map<String, dynamic>> res = [];
    try {
      var userPosts = await db.collection('posts')
        .where('author', isEqualTo: userID)
        .orderBy('date', descending: true)
        .startAfterDocument(_lastVisible)
        .limit(25).get();
      var userData = await db.collection('user_settings').doc(userID).get();
      var userPostDocs = userPosts.docs;
      if (_isFirst) {
        userPostDocs.insert(0, _lastVisible);
      }
      _isFirst = false;
      _lastVisible = userPosts.docs.isEmpty ? null : userPosts.docs[userPosts.docs.length - 1];
      for (final post in userPostDocs) {
        Map<String, dynamic> data = post.data();
        data['author_display_username'] = userData.data()!['display_username'];
        data['author_profile_pic_url'] = userData.data()!['profile_pic_url'];
        res.add(data);
      }
    } catch (e) {
      print(e);
      return [];
    }
    return res;
  }

  Future<void> _setLastVisibleToFirst(userID) async {
    var userPosts = await db.collection('posts')
      .where('author', isEqualTo: userID)
      .orderBy('date', descending: true)
      .limit(1).get();
    _lastVisible = userPosts.docs.isEmpty ? null : userPosts.docs[0];
    _firstVisible = _lastVisible;
  }

  Future<Map<String, dynamic>> _getUserData() async {
    // First get the ID of the user currently logged in 
    final userID = await helpers.getUserID();
    final users = db.collection('users');
    final settingsDocRef = db.collection('user_settings').doc(userID);

    final QuerySnapshot userWithUID = await users.where('id', isEqualTo: userID).get();
    final user = userWithUID.docs[0].data() as Map<String, dynamic>;

    final usettings = await settingsDocRef.get();
    final userSettings = usettings.data() as Map<String, dynamic>;

    await _setLastVisibleToFirst(userID);
    _getPostsByUserFuture = _getPostsByUser();

    return {
      'username': user['username'],
      'displayUsername': userSettings['display_username'],
      'bio': userSettings['bio'],
      'userID': userID
    };
  }

  Future<void> _saveNewData(String newData, int maxLen, String fieldName, {required bool isBio}) async {
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
        )
      ),
      body: FutureBuilder(
        future: _getUserDataFuture,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
            final Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
            final String username = data['username'];
            var displayUsername = data['displayUsername'];
            var bio = data['bio'];

            Future<void> resetToText(tap) async {
              if (_toggleEditDUname.showEdit.value) {
                displayUsername = _controller.text;
                _toggleEditDUname.makeUneditable();
                await _saveNewData(
                  displayUsername,
                  ValidateSignupConsts.MAX_USERNAME_LEN,
                  'display_username',
                  isBio: false
                );
              }
            } 

            Future<void> resetToTextBio(tap) async {
              if (_toggleEditBio.showEdit.value) {
                bio = _bioController.text;
                if (_bioController.text.isNotEmpty) _toggleEditBio.makeUneditable();
                _saveNewData(bio, ProfileConsts.MAX_BIO_LEN, 'bio', isBio: true);
              }
            }

            Future<void> finishBioEdit() async {
              resetToTextBio(null);             
              await _saveNewData(
                _bioController.text,
                ProfileConsts.MAX_BIO_LEN,
                'bio',
                isBio: true
              );
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
                onChanged: (value) {
                  bio = _bioController.text;
                },
                onEditingComplete: finishBioEdit,
                onSubmitted: (context) {
                  finishBioEdit();
                },
                onTapOutside: (event) {
                  finishBioEdit();
                },
                focusNode: bioFocusNode,
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
                              onTapOutside: (tap) async {
                                if (_toggleEditDUname.showEdit.value) {
                                  await resetToText(tap);
                                  /*
                                  setState(() {
                                    _getUserDataFuture = _getUserData();
                                    _lastVisible = _firstVisible;
                                    _isFirst = true;
                                  });
                                  */
                                }
                              },
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
                                        onChanged: (value) {
                                          displayUsername = _controller.value;
                                        },
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                        child: Text(displayUsername, style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0,
                                        )),
                                      );
                                    }
                                  }),
                                ),
                            ),
                              Text("@$username")
                            ],
                          ),),
                          Column(
                            children: [
                              ProfilePhoto(),
                              SizedBox(height: 10,),
                              GestureDetector(
                                onTap: () async {
                                  await helpers.logout();
                                  setState(() {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => WelcomePage(),
                                      ),
                                      (Route<dynamic> route) => false,
                                    );
                                  });
                                },
                                child: Icon(Icons.logout_rounded, size: 20, color: Theme.of(context).colorScheme.primary,),
                              )
                            ],
                          )
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
                        onTapOutside: (tap) async {
                          if (_bioController.text.isEmpty) {
                            bioFocusNode.unfocus();      
                          } else {
                            await resetToTextBio(tap);
                          }
                        },
                        child: GestureDetector(
                          onDoubleTap: () {
                            if (bio.isEmpty) return;
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
                  color: Colors.white12
                ),
                FutureBuilder(
                  future: _getPostsByUserFuture,
                  builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    List<Widget> posts = [];
                    if (snapshot.hasData && snapshot.data != null) {
                      for (final post in snapshot.data!) {
                        posts.add(
                          post_builder.postBuilder(post, displayUsername, context)
                        );
                      }
                      return Column(
                        children: posts,
                      );
                    } else {
                      return Center(
                        child: GlobalConsts.spinkit,
                      );
                    }
                  }
                )
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