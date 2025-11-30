/// Model pentru un serviciu oferit de prestator
class ProviderServiceItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final int durationMinutes;
  final bool isActive;
  final String category;
  final String? imageUrl;

  ProviderServiceItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'RON',
    this.durationMinutes = 60,
    this.isActive = true,
    required this.category,
    this.imageUrl,
  });

  ProviderServiceItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    int? durationMinutes,
    bool? isActive,
    String? category,
    String? imageUrl,
  }) {
    return ProviderServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  factory ProviderServiceItem.fromJson(Map<String, dynamic> json) {
    return ProviderServiceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'RON',
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      isActive: json['isActive'] as bool? ?? true,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// Model pentru profilul prestatorului
class ProviderProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? description;
  final String? avatarUrl;
  final double rating;
  final int totalOrders;
  final int completedOrders;
  final bool isAvailable;
  final bool isVerified;
  final List<String> categories;
  final List<ProviderServiceItem> services;
  final DateTime? createdAt;

  ProviderProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.description,
    this.avatarUrl,
    this.rating = 0.0,
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.isAvailable = true,
    this.isVerified = false,
    this.categories = const [],
    this.services = const [],
    this.createdAt,
  });

  ProviderProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? description,
    String? avatarUrl,
    double? rating,
    int? totalOrders,
    int? completedOrders,
    bool? isAvailable,
    bool? isVerified,
    List<String>? categories,
    List<ProviderServiceItem>? services,
    DateTime? createdAt,
  }) {
    return ProviderProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      categories: categories ?? this.categories,
      services: services ?? this.services,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Categorii de servicii disponibile
class ServiceCategories {
  static const List<ServiceCategory> all = [
    ServiceCategory(id: 'transport', name: 'Transport', icon: '🚗'),
    ServiceCategory(id: 'reparatii', name: 'Reparații', icon: '🔧'),
    ServiceCategory(id: 'curatenie', name: 'Curățenie', icon: '🧹'),
    ServiceCategory(id: 'instalatii', name: 'Instalații', icon: '🔩'),
    ServiceCategory(id: 'electrician', name: 'Electrician', icon: '⚡'),
    ServiceCategory(id: 'livrare', name: 'Livrare', icon: '📦'),
    ServiceCategory(id: 'frumusete', name: 'Frumusețe', icon: '💇'),
    ServiceCategory(id: 'sanatate', name: 'Sănătate', icon: '🏥'),
    ServiceCategory(id: 'educatie', name: 'Educație', icon: '📚'),
    ServiceCategory(id: 'altele', name: 'Altele', icon: '📋'),
  ];
}

class ServiceCategory {
  final String id;
  final String name;
  final String icon;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

