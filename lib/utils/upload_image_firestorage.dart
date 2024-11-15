import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UploadImageFirestorage {
  const UploadImageFirestorage(
    this.storageRef
  );

  static const Uuid uuid = Uuid();
  final Reference storageRef;

  Future<(String downloadURL, String filename)> uploadImage(File image, int size, String pathPrefix) async {
    final extension = p.extension(image.path);
    final metadata = SettableMetadata(contentType: "image/${extension.substring(1)}");
    final filename = "${uuid.v4()}$extension";
    final pathname = "$pathPrefix/$filename";
    final cmd = img.Command()..decodeImageFile(image.path)..copyResize(width: 800)..writeToFile(image.path);
    await cmd.executeThread();
    await storageRef.child(pathname).putFile(image, metadata);
    final downloadURL = await storageRef.child(pathname).getDownloadURL();
    return (downloadURL, filename);
  }
}