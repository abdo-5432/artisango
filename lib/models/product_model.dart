class ProductModel {
  final String id;
  final String artisanId;
  final String artisanName;
  final String title;
  final String description;
  final String category;
  final String city;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<Map<String, dynamic>> reviews;
  final double? latitude; // added
  final double? longitude; // added

  ProductModel({
    required this.id,
    required this.artisanId,
    required this.artisanName,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
    this.latitude,
    this.longitude,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    dynamic reviewsData = map['reviews'];
    List<Map<String, dynamic>> reviewsList = [];
    if (reviewsData is List) {
      reviewsList =
          reviewsData.map((item) => Map<String, dynamic>.from(item)).toList();
    } else if (reviewsData is Map) {
      reviewsList = [Map<String, dynamic>.from(reviewsData)];
    }

    return ProductModel(
      id: id,
      artisanId: map['artisanId'] ?? '',
      artisanName: map['artisanName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      city: map['city'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] is int ? map['reviewCount'] : 0,
      reviews: reviewsList,
      latitude:
          map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'artisanId': artisanId,
      'artisanName': artisanName,
      'title': title,
      'description': description,
      'category': category,
      'city': city,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'reviews': reviews,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
