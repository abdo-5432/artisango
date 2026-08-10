import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;
    final userDoc = await FirestoreService().getUser(user.uid);
    if (userDoc != null && mounted) {
      setState(() {
        _isFavorite = userDoc.favorites.contains(widget.product.id);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.currentUser?.uid;
    if (userId == null) return;
    final fs = FirestoreService();
    if (_isFavorite) {
      await fs.removeFavorite(userId, widget.product.id);
    } else {
      await fs.addFavorite(userId, widget.product.id);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 130,
                      color: const Color(0xFFEEEDFF),
                      child: const Icon(Icons.handyman, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      onPressed: _toggleFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(widget.product.category,
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: const Color(0xFF6C63FF))),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.product.title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(widget.product.artisanName,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(widget.product.rating.toStringAsFixed(1)),
                      const SizedBox(width: 4),
                      Text('(${widget.product.reviewCount})',
                          style: GoogleFonts.poppins(color: Colors.grey)),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: Colors.grey),
                          Text(widget.product.city,
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
