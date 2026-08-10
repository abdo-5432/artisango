import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/product_model.dart';

class AddReviewScreen extends StatefulWidget {
  final ProductModel product;
  const AddReviewScreen({super.key, required this.product});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _rating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('write_review_hint'.tr())),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final userName = await FirestoreService().getUser(auth.currentUser!.uid);
    final newReview = {
      'userName': userName?.name ?? 'Anonymous',
      'rating': _rating,
      'text': _reviewController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    final updatedReviews =
        List<Map<String, dynamic>>.from(widget.product.reviews);
    updatedReviews.add(newReview);

    final totalRating = updatedReviews.fold<double>(
        0, (sum, r) => sum + (r['rating'] as num).toDouble());
    final avgRating = totalRating / updatedReviews.length;
    final reviewCount = updatedReviews.length;

    await FirestoreService().updateProductReviews(
      widget.product.id,
      avgRating,
      reviewCount,
      updatedReviews,
    );

    setState(() => _isSubmitting = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('write_review'.tr()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'rate_service'.tr(namedArgs: {'title': widget.product.title}),
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...List.generate(5, (i) {
                  final starValue = i + 1;
                  return IconButton(
                    icon: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () =>
                        setState(() => _rating = starValue.toDouble()),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'write_review_hint'.tr(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('submit_review'.tr(),
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
