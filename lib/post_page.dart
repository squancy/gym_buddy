import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'utils/photo_upload_popup.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/upload_image_firestorage.dart';
import 'utils/helpers.dart' as helpers;
import 'package:moye/moye.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as datepicker;
import 'package:intl/intl.dart';
import 'package:moye/widgets/gradient_overlay.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instance.ref();

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  static const List<String> _dayTypes = <String>[
    'Chest',
    'Back',
    'Legs',
    'Arms',
    'Shoulders',
    'Cardio',
  ];

  // Only for testing
  // TODO: web scrape gyms in Hungary
  static const List<Map<String, dynamic>> _gyms = [
    {
      'name': 'The best gym in Budapest',
      'props': {
        'geoloc': [32.122, -21.322],
        'opened': 2019
      }
    },
    {
      'name': 'The second best gym in Budapest',
      'props': {
        'geoloc': [32.122, -21.322],
        'opened': 2019
      }
    }
  ];


  String? _dayTypeVal = '';
  String? _gymVal = '';
  bool _showImages = false;
  final _picker = ImagePicker();
  List<File> _selectedImages = [];
  final _controller = TextEditingController();
  String _errorMsg = '';
  bool _hasError = false;
  DateTime? _datetimeVal;

  void _selectFromSource(ImageSource sourceType) async {
    final pickedFiles = await _picker.pickMultiImage(limit: 5);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((el) => File(el.path)).toList();
        _showImages = true;
      });
    }
  }

  Future<void> createNewPost(
    List<File> images,
    String postText,
    String? dayType,
    String? gym,
    DateTime? when) async {
    // First validate user input: only the text field is mandatory
    setState(() {
      _errorMsg = '';
      _hasError = false;
    });

    if (postText.isEmpty) {
      setState(() {
        _errorMsg = 'Fill why you want a gym buddy';
        _hasError = true;
      });
      return;
    }

    final uuid = Uuid(); 
    final postID = uuid.v4();
    List<String> downloadURLs = [];
    List<String> filenames = [];

    // Upload every image
    for (final image in images) {
      var (String downloadURL, String filename) = await UploadImageFirestorage(storageRef).uploadImage(image, 100, "post_pics/$postID");
      downloadURLs.add(downloadURL);
      filenames.add(filename);
    }

    // Push to db
    final postsDocRef = db.collection('posts').doc(postID);
    final data = {
      'author': await helpers.getUserID(),
      'content': postText,
      'day_type': dayType,
      'gym': gym,
      'download_url_list': downloadURLs,
      'filename_list': filenames,
      'when': when,
      'date': FieldValue.serverTimestamp()
    };

    try {
      await postsDocRef.set(data);
    } catch (e) {
      setState(() {
        _errorMsg = 'An unknown error occurred';
        _hasError = true;
      });
      return;
    }

    setState(() {
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadPhoto = PhotoUploadPopup(context, _selectFromSource);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          scrolledUnderElevation: 0,
        )
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(
                    'Find a gym buddy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).withGradientOverlay(gradient: LinearGradient(colors: [
                    Colors.white,
                    Theme.of(context).colorScheme.primary,
                  ])),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Looking for a buddy?',
                          hintStyle: TextStyle(
                            color: Colors.grey
                          ),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none
                        ),
                        maxLines: null,
                        controller: _controller,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: CustomDropdown<String>(
                    hintText: 'What day are you having?',  
                    items: _dayTypes,
                    onChanged: (p0) {
                      _dayTypeVal = p0;
                    },
                    decoration: CustomDropdownDecoration(
                      closedFillColor: Colors.black,
                      expandedFillColor: Colors.black,                      
                      listItemDecoration: ListItemDecoration(
                        highlightColor:  const Color.fromARGB(255, 23, 23, 23),
                        selectedColor: const Color.fromARGB(255, 23, 23, 23),
                        splashColor:  const Color.fromARGB(255, 23, 23, 23)
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: CustomDropdown<String>.search(
                    hintText: 'Which gym are you going to?',  
                    items: List<String>.from(_gyms.map((obj) => obj['name']).toList()),
                    onChanged: (p0) {
                      _gymVal = p0;
                    },
                    excludeSelected: false,
                    decoration: CustomDropdownDecoration(
                      closedFillColor: Colors.black,
                      expandedFillColor: Colors.black,
                      listItemDecoration: ListItemDecoration(
                        highlightColor:  const Color.fromARGB(255, 23, 23, 23),
                        selectedColor: const Color.fromARGB(255, 23, 23, 23),
                        splashColor:  const Color.fromARGB(255, 23, 23, 23)
                      ),
                      searchFieldDecoration: SearchFieldDecoration(
                        fillColor: Colors.black
                      )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: FilledButton.icon(
                          icon: Icon(Icons.date_range_rounded, size: 18,),
                          onPressed: () {
                            DateTime now = DateTime.now();
                            datepicker.DatePicker.showDateTimePicker(
                              context,
                              theme: datepicker.DatePickerTheme(
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                doneStyle: TextStyle(color: Colors.white),
                                cancelStyle: TextStyle(color: Colors.white),
                                itemStyle: TextStyle(color: Colors.white)
                              ),
                              showTitleActions: true,
                              minTime: now,
                              onConfirm: (date) {
                                setState(() {
                                  _datetimeVal = date;
                                });
                              },
                              currentTime: DateTime.now(),
                              locale: datepicker.LocaleType.en
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.black),
                            foregroundColor: _datetimeVal != null ? WidgetStateProperty.all(Colors.white) : WidgetStateProperty.all(Colors.grey) 
                          ),
                          label: _datetimeVal != null ? Text(DateFormat('MM-dd kk:mm').format(_datetimeVal as DateTime)) : Text('What time?')
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: FilledButton.icon(
                          onPressed: uploadPhoto.showOptions,
                          label: Text('Upload photos'),
                          icon: Icon(Icons.add_a_photo_rounded, size: 18,),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.black),
                            foregroundColor: _selectedImages.isNotEmpty ? WidgetStateProperty.all(Colors.white) : WidgetStateProperty.all(Colors.grey)
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: helpers.horizontalImageViewer(
                    showImages: _showImages,
                    images: _selectedImages,
                    isPost: true
                  )
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: SizedBox(
                    height: 45,
                    child: ProgressButton(
                      onPressed: () {
                        return createNewPost(
                          _selectedImages,
                          _controller.text,
                          _dayTypeVal,
                          _gymVal,
                          _datetimeVal
                        );
                      },
                      loadingType: ProgressButtonLoadingType.replace,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        textStyle: WidgetStatePropertyAll(
                          TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        )
                      ),
                      type: ProgressButtonType.filled,
                      child: Text('Post'),
                    ),
                  ),
                ),
                _hasError ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Text(_errorMsg),
                  )
                ) : Container()
              ]
            ),
          )
        ],
      )
    );
  }
}