import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_fade/image_fade.dart';
import 'dart:io';
import 'package:moye/moye.dart';

Future<String?> getUserID() async {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  // await prefs.setBool('loggedIn', false);
  return prefs.getString('userID');
}

// TODO: rewrite this function to a StatelessWidget class
Widget blackTextfield(
  BuildContext context,
  String labelText,
  TextEditingController? controller,
  FocusNode? focusNode,
  {required bool isPassword, required bool isEmail}
  ) {
  return TextField(
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      labelText: labelText,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w500
      ),
      floatingLabelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary
      ),
      fillColor: Colors.black,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    onTapOutside: (event) {
      FocusManager.instance.primaryFocus?.unfocus();
    },
    obscureText: isPassword,
    keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
  );
}

Future<Position?> getGeolocation() async { 
  // Get geolocation data, if available
  try {
    Position? geoloc;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (serviceEnabled && permission != LocationPermission.denied) {
      geoloc = await Geolocator.getCurrentPosition();
    } else {
      geoloc = await Geolocator.getLastKnownPosition();
    }
    return geoloc;
  } catch (e) {
    return null;
  }
}

class ImageBig {
  const ImageBig(this.context, this.image);

  final BuildContext context;
  final image;

  SafeArea buildImage() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BottomSheetHandle().alignCenter,
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImageFade(
                image: image,
                placeholder: Container(
                  color: Colors.black,
                ),
              ),
            ),
          )
        ]
      )
    );
  }

  void showImageInBig() {
    BottomSheetUtils.showBottomSheet(
      context: context,
      borderRadius: BorderRadius.circular(16),
      config: WrapBottomSheetConfig(
        builder: (context, controller) {
          return buildImage();
        },
      ),
    );
  }
}

// TODO: rewrite this function to a StatelessWidget class
Widget horizontalImageViewer({required showImages, required images, required isPost, context}) {
  return SizedBox(
    height: showImages ? 150 : 0,
    child: ListView(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      children: [
      for (final el in images)
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: GestureDetector(
            onTap: () {
              final imgb = ImageBig(context, isPost ? FileImage(File(el.path)) : NetworkImage(el));
              imgb.showImageInBig();
            },
            child: SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: ImageFade(
                    image: isPost ? FileImage(File(el.path)) : NetworkImage(el),
                    placeholder: Container(
                      width: 180,
                      height: 150,
                      color: Colors.black,
                    ),
                  )
                ),
              ),
            ),
          ),
        ),
    ],),
  );
}

class ProfilePicPlaceholder extends StatelessWidget {
  const ProfilePicPlaceholder({super.key, required this.radius});
  
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color.fromARGB(255, 14, 22, 29),
    );
  }
}

class ProgressBtn extends StatelessWidget {
  const ProgressBtn({
    super.key,
    required this.onPressedFn,
    required this.child
  });

  final dynamic onPressedFn;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProgressButton(
      onPressed: onPressedFn,
      loadingType: ProgressButtonLoadingType.replace,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
        foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onSecondary),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            fontWeight: FontWeight.bold
          )
        )
      ),
      type: ProgressButtonType.filled,
      child: child,
    );
  }
}