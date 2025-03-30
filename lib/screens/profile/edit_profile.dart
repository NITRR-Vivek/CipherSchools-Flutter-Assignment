import 'dart:typed_data';
import 'package:cipherx/utils/restore_system_chrome.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import '../../services/sharedpreference_helper.dart';
import '../../utils/constants.dart';
import '../../utils/pick_image_helper.dart';
import '../../widgets/custom_snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  final String? currentName;
  final Uint8List? currentImage;
  final VoidCallback onProfileUpdated;

  const EditProfileScreen({
    super.key,
    this.currentName,
    this.currentImage,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  Uint8List? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName ?? '');
    _profileImage = widget.currentImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await permission.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      openAppSettings(); // Open app settings if permanently denied
      return false;
    }

    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    bool hasPermission = source == ImageSource.camera
        ? await _requestPermission(Permission.camera)
        : await _requestPermission(Permission.storage);

    Uint8List? pickedImage = await pickImage(source);
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }



  Future<Uint8List> compressImage(Uint8List imageBytes) async {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    img.Image resizedImage = img.copyResize(image, width: 500);
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 70);
    return Uint8List.fromList(compressedBytes);
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      CustomSnackbar.show(context, message: 'Please enter a username');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SharedPreferencesHelper.setName(_nameController.text);
      if (_profileImage != null) {
        final compressedImage = await compressImage(_profileImage!);
        await SharedPreferencesHelper.setUserImg(compressedImage);
      }

      widget.onProfileUpdated();
      if (!mounted) return;
      CustomSnackbar.show(context, message: "Profile updated successfully!");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, message: "Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    restoreSystemChrome(color: AppColors.tonesAppColor400);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: AppColors.tonesAppColor400,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.darkAppColor300,
                  child: _profileImage != null
                      ? CircleAvatar(
                    radius: 58,
                    backgroundImage: MemoryImage(_profileImage!),
                  )
                      : CircleAvatar(
                    radius: 58,
                    backgroundImage: AssetImage('assets/images/person.jpg'),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _showImagePickerModal,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.darkAppColor300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAppColor300,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
