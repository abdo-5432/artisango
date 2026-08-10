import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import '../services/rate_app_service.dart';
import '../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final VoidCallback? onProductAdded;
  const AddProductScreen({super.key, this.onProductAdded});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _city = TextEditingController();
  String _category = 'Carpenter';
  final List<String> _cats = [
    'Carpenter',
    'Electrician',
    'Plumber',
    'Painter',
    'Mason',
    'Tailor'
  ];
  bool _loading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('location_disabled'.tr())));
        setState(() => _gettingLocation = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('permission_denied'.tr())));
          setState(() => _gettingLocation = false);
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition();
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final city = placemarks.first.locality ??
          placemarks.first.administrativeArea ??
          '';
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        if (city.isNotEmpty) _city.text = city;
        _gettingLocation = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('error_label'.tr() + ': $e')));
      setState(() => _gettingLocation = false);
    }
  }

  void _submit() async {
    if (_title.text.isEmpty || _desc.text.isEmpty || _city.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('fill_fields'.tr())));
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('image_required'.tr())));
      return;
    }

    setState(() => _loading = true);

    final imageUrl = await CloudinaryService().uploadImage(_imageFile!);
    if (imageUrl == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('image_upload_failed'.tr())));
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    final user = await FirestoreService().getUser(auth.currentUser!.uid);

    final product = ProductModel(
      id: '',
      artisanId: auth.currentUser!.uid,
      artisanName: user?.name ?? '',
      title: _title.text.trim(),
      description: _desc.text.trim(),
      category: _category,
      city: _city.text.trim(),
      imageUrl: imageUrl,
      rating: 0.0,
      reviewCount: 0,
      reviews: [],
      latitude: _latitude,
      longitude: _longitude,
    );

    await FirestoreService().addProduct(product);
    widget.onProductAdded?.call();
    setState(() => _loading = false);
    if (mounted) {
      Navigator.pop(context);
      await RateAppService.requestReview(context);
    }
  }

  // Get localized category name
  String _getLocalizedCategory(String category) {
    switch (category) {
      case 'Carpenter':
        return 'carpenter'.tr();
      case 'Electrician':
        return 'electrician'.tr();
      case 'Plumber':
        return 'plumber'.tr();
      case 'Painter':
        return 'painter'.tr();
      case 'Mason':
        return 'mason'.tr();
      case 'Tailor':
        return 'tailor'.tr();
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_service'.tr()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 1.5),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 48, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 8),
                          Text('tap_to_add_photo'.tr(),
                              style: GoogleFonts.poppins(
                                  color: Theme.of(context).primaryColor)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
                controller: _title,
                decoration: _inputDec('service_title'.tr(), Icons.title)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: _cats
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(_getLocalizedCategory(c)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: _inputDec('category'.tr(), Icons.category),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _city,
                        decoration: _inputDec('city'.tr(), Icons.location_on))),
                IconButton(
                  icon: _gettingLocation
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, color: Color(0xFF6C63FF)),
                  onPressed: _gettingLocation ? null : _getCurrentLocation,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _desc,
                maxLines: 4,
                decoration: _inputDec('description'.tr(), Icons.description)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('post_service'.tr(),
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
