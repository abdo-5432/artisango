import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = await FirestoreService().getUser(auth.currentUser!.uid);
    if (user != null) {
      _cityController.text = user.city;
      _bioController.text = user.bio;
      _phoneController.text = user.phoneNumber;
      _photoUrl = user.photoUrl;
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser!.uid;
    final fs = FirestoreService();

    String? newPhotoUrl = _photoUrl;
    if (_profileImage != null) {
      newPhotoUrl = await CloudinaryService().uploadImage(_profileImage!);
    }

    final updates = {
      'city': _cityController.text.trim(),
      'bio': _bioController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      if (newPhotoUrl != null) 'photoUrl': newPhotoUrl,
    };

    await fs.updateUser(uid, updates);
    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'edit_profile'.tr(),
          style: GoogleFonts.poppins(
            color: Theme.of(context).primaryColor, // purple title
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // white background
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor, // purple text
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            child: Text('save'.tr()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: CircleAvatar(
                        radius: 47,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_photoUrl != null && _photoUrl!.isNotEmpty
                                ? NetworkImage(_photoUrl!) as ImageProvider
                                : null),
                        child: (_profileImage == null &&
                                (_photoUrl == null || _photoUrl!.isEmpty))
                            ? Icon(Icons.person,
                                size: 50, color: Colors.grey.shade300)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C63FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'city'.tr(),
                prefixIcon: const Icon(Icons.location_on),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'bio'.tr(),
                hintText: 'bio_hint'.tr(),
                prefixIcon: const Icon(Icons.info_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'phone_number'.tr(),
                hintText: 'phone_hint'.tr(),
                prefixIcon: const Icon(Icons.phone),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
