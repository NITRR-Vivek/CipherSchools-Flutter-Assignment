import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../services/sharedpreference_helper.dart';
import '../../utils/constants.dart';
import '../../utils/restore_system_chrome.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final PersistentTabController controller;

  const ProfileScreen({
    super.key,
    required this.onLogout,
    required this.controller,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  Uint8List? _userImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final name = await SharedPreferencesHelper.getName();
    final image = await SharedPreferencesHelper.getUserImg();

    setState(() {
      _userName = name ?? 'User';
      _userImage = image;
      _isLoading = false;
    });
  }
  @override
  void didChangeDependencies() {
    restoreSystemChrome(color: Colors.white);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 8, left: 8, right: 8),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.darkAppColor300,
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : CircleAvatar(
                          radius: 40,
                          backgroundImage: _userImage != null
                              ? MemoryImage(_userImage!)
                              : AssetImage('assets/images/person.jpg') as ImageProvider,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Username",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _isLoading ? 'Loading...' : (_userName ?? 'User'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                currentName: _userName,
                                currentImage: _userImage,
                                onProfileUpdated: _loadUserData,
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.edit_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      context,
                      icon: Icons.account_circle,
                      title: "Account",
                      iconColor: AppColors.lightAppColor400,
                      onTap: (){}
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.settings,
                      title: "Settings",
                      iconColor: AppColors.lightAppColor400,
                      onTap: (){}
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.cloud_upload,
                      title: "Export Data",
                      iconColor: AppColors.lightAppColor400,
                      onTap: (){}
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.logout,
                      title: "Logout",
                      iconColor: Colors.red,
                      onTap: widget.onLogout
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
        required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        height: 40, // Size of the rounded square
        width: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25), // Adjust transparency
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.grey.shade300, thickness: 1),
    );
  }
}
