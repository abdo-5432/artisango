import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'near_me_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _fs = FirestoreService();
  final List<String> _categories = [
    'All',
    'Carpenter',
    'Electrician',
    'Plumber',
    'Painter',
    'Mason',
    'Tailor'
  ];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<ProductModel> _allProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _fs.getProducts(category: null).first;
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  List<ProductModel> get _filteredProducts {
    var filtered = _allProducts;
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((p) =>
              p.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.artisanName.toLowerCase().contains(query) ||
              p.id.toLowerCase().contains(query))
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('artisan_go'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => NearMeScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ProfileScreen())),
          ),
        ],
      ),
      floatingActionButton: auth.currentUser != null
          ? FutureBuilder<UserModel?>(
              future: _fs.getUser(auth.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data?.role == 'artisan') {
                  return FloatingActionButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddProductScreen(
                            onProductAdded: _refreshProducts,
                          ),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.add),
                  );
                }
                return const SizedBox();
              },
            )
          : const SizedBox(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'search_hint'.tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''))
                    : null,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.grey[800],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) => _buildCategoryChip(_categories[i]),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('error_label'.tr() + ': $_error',
                                  style:
                                      GoogleFonts.poppins(color: Colors.red)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                  onPressed: _loadProducts,
                                  child: Text('retry'.tr())),
                            ],
                          ),
                        )
                      : _filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'no_products_in'.tr() +
                                            ' $_selectedCategory'
                                        : 'no_results'.tr() + ' $_searchQuery',
                                    style:
                                        GoogleFonts.poppins(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (_, i) => ProductCard(
                                product: _filteredProducts[i],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                          product: _filteredProducts[i])),
                                ),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = label == _selectedCategory;
    String displayLabel = label;
    if (label == 'All')
      displayLabel = 'all'.tr();
    else if (label == 'Carpenter')
      displayLabel = 'carpenter'.tr();
    else if (label == 'Electrician')
      displayLabel = 'electrician'.tr();
    else if (label == 'Plumber')
      displayLabel = 'plumber'.tr();
    else if (label == 'Painter')
      displayLabel = 'painter'.tr();
    else if (label == 'Mason')
      displayLabel = 'mason'.tr();
    else if (label == 'Tailor') displayLabel = 'tailor'.tr();
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          displayLabel,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
