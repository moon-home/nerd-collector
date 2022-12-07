import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:developer' as devtools show log;

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Widget imageButton({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}) {
  return SizedBox(
    width: 280,
    child: ElevatedButton(
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(
            width: 20,
          ),
          Text(title),
        ],
      ),
      onPressed: onClick,
    ),
  );
}

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  File? _image;

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');
    return File(imagePath).copy(image.path);
  }

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
      );
      if (image == null) return;
      final imagePermanent = await saveFilePermanently(image.path);
      setState(() {
        _image = imagePermanent;
      });
    } on PlatformAssetBundle catch (e) {
      devtools.log('Failed to get image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 40,
        ),
        _image != null
            ? Image.file(
                _image!,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              )
            : Image.network(
                'https://media-exp1.licdn.com/dms/image/C4D03AQHlTQC59YWK9g/profile-displayphoto-shrink_400_400/0/1641955686415?e=1675900800&v=beta&t=QZpjjws2t69rvxl4XY16zyrkauWwLbl9YWQdX_mFN1Y',
              ),
        const SizedBox(
          height: 40,
        ),
        imageButton(
          title: 'Gallery',
          icon: Icons.image_outlined,
          onClick: () => getImage(ImageSource.gallery),
        ),
        imageButton(
          title: 'Camera',
          icon: Icons.camera_outlined,
          onClick: () => getImage(ImageSource.camera),
        ),
      ],
    );
  }
}
