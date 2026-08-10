import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/theme_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final uid = authService.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final fs = FirestoreService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('my_profile'.tr()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Language switcher
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final newLocale = context.locale == const Locale('en')
                  ? const Locale('fr')
                  : const Locale('en');
              context.setLocale(newLocale);
              setState(() {});
            },
          ),
          // Theme toggle
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          // Favorites
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
          // Edit Profile
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          // Logout button – fixed: clears the entire navigation stack
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              await authService.logout();
              if (context.mounted) {
                Navigator.pop(context); // close dialog
                // Replace the entire navigation stack with a single LoginScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: fs.getUser(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user == null) return Center(child: Text('user_not_found'.tr()));
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: user.photoUrl.isNotEmpty
                            ? NetworkImage(user.photoUrl)
                            : null,
                        child: user.photoUrl.isEmpty
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    color: Theme.of(context).primaryColor),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(user.name,
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(user.email,
                          style: GoogleFonts.poppins(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          user.role == 'artisan' ? 'Artisan' : 'Client',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.city.isNotEmpty)
                        _infoTile(Icons.location_on, 'city'.tr(), user.city),
                      if (user.bio.isNotEmpty)
                        _infoTile(Icons.info_outline, 'bio'.tr(), user.bio),
                      if (user.phoneNumber.isNotEmpty)
                        _infoTile(
                            Icons.phone, 'phone_number'.tr(), user.phoneNumber),
                      if (user.role == 'artisan') ...[
                        const SizedBox(height: 16),
                        Text('my_services'.tr(),
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        StreamBuilder(
                          stream: fs.getArtisanProducts(uid),
                          builder: (ctx, snap) {
                            final products = snap.data ?? [];
                            if (products.isEmpty) {
                              return Center(
                                  child: Text('no_services_yet'.tr(),
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey)));
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: products.length,
                              itemBuilder: (_, i) => ProductCard(
                                product: products[i],
                                onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                          product: products[i])),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
