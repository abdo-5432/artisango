import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/rate_app_service.dart';
import 'add_review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _refreshProduct() async {
    final updated = await FirestoreService().getProduct(_product.id);
    if (updated != null && mounted) {
      setState(() {
        _product = updated;
      });
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (!digitsOnly.startsWith('212')) {
      if (digitsOnly.startsWith('0')) {
        digitsOnly = '212${digitsOnly.substring(1)}';
      } else {
        digitsOnly = '212$digitsOnly';
      }
    }
    final whatsappIntent = Uri.parse('whatsapp://send?phone=$digitsOnly');
    try {
      await launchUrl(whatsappIntent, mode: LaunchMode.externalApplication);
      return;
    } catch (e) {
      final webUrl = Uri.parse('https://wa.me/$digitsOnly');
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return;
      } catch (e2) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('could_not_open_whatsapp'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('contact_artisan_at'.tr() + ': $digitsOnly',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: digitsOnly));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('number_copied'.tr())),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.copy),
                    label: Text('copy_number'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('close'.tr()),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final shareText = 'share_text'.tr(namedArgs: {
                    'title': _product.title,
                    'id': _product.id,
                    'artisanName': _product.artisanName,
                    'city': _product.city,
                    'rating': _product.rating.toStringAsFixed(1),
                    'reviewCount': _product.reviewCount.toString(),
                    'description': _product.description,
                    'imageUrl': _product.imageUrl,
                  });
                  Share.share(shareText, subject: 'share_subject'.tr());
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEEEDFF),
                  child: const Icon(Icons.handyman, size: 80),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_product.category,
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).primaryColor)),
                  ),
                  const SizedBox(height: 12),
                  Text(_product.title,
                      style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_product.artisanName,
                          style: GoogleFonts.poppins(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_product.city,
                          style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (i) => Icon(
                              i < _product.rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20)),
                      const SizedBox(width: 8),
                      Text(
                          '${_product.rating.toStringAsFixed(1)} (${_product.reviewCount} ${'reviews'.tr()})',
                          style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('about_service'.tr(),
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_product.description,
                      style: GoogleFonts.poppins(color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final artisan = await FirestoreService()
                            .getUser(_product.artisanId);
                        final phone = artisan?.phoneNumber ?? '';
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('artisan_not_provided_phone'.tr())),
                          );
                          return;
                        }
                        _openWhatsApp(phone);
                      },
                      icon: const Icon(Icons.chat),
                      label: Text('contact_whatsapp'.tr(),
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddReviewScreen(product: _product)),
                        );
                        if (result == true && mounted) {
                          await _refreshProduct();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('thank_you_review'.tr())),
                          );
                          await RateAppService.requestReview(context);
                        }
                      },
                      icon: const Icon(Icons.rate_review),
                      label: Text('write_review'.tr(),
                          style: GoogleFonts.poppins(fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_product.reviews.isNotEmpty) ...[
                    Text('reviews'.tr(),
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._product.reviews
                        .map((review) => _buildReviewCard(review)),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review['userName'],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                        i < (review['rating'] as num).round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16)),
              ),
              const Spacer(),
              Text(
                _formatDate(review['timestamp']),
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review['text'],
              style:
                  GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800])),
        ],
      ),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    final date = DateTime.parse(isoString);
    return '${date.day}/${date.month}/${date.year}';
  }
}
