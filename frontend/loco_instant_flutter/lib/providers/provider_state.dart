import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/provider_service.dart';

/// Starea utilizatorului (client sau prestator)
enum UserRole { client, provider }

/// Tipul de prestator (servicii sau marketplace)
enum ProviderType { services, marketplace }

extension ProviderTypeExtension on ProviderType {
  String get label {
    switch (this) {
      case ProviderType.services:
        return 'Prestări servicii';
      case ProviderType.marketplace:
        return 'Marketplace';
    }
  }

  String get description {
    switch (this) {
      case ProviderType.services:
        return 'Găsește comenzi în zona ta';
      case ProviderType.marketplace:
        return 'Vinde prin platformă';
    }
  }

  String get icon {
    switch (this) {
      case ProviderType.services:
        return 'build';
      case ProviderType.marketplace:
        return 'storefront';
    }
  }
}

/// Notifier pentru rolul utilizatorului
class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier() : super(UserRole.client) {
    _loadRole();
  }

  static const _key = 'user_role';

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'provider') {
      state = UserRole.provider;
    } else {
      state = UserRole.client;
    }
  }

  Future<void> setRole(UserRole role) async {
    state = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, role.name);
  }

  void toggleRole() {
    setRole(state == UserRole.client ? UserRole.provider : UserRole.client);
  }
}

/// Provider pentru rolul utilizatorului
final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRole>(
  (ref) => UserRoleNotifier(),
);

/// Notifier pentru tipul de prestator
class ProviderTypeNotifier extends StateNotifier<ProviderType?> {
  ProviderTypeNotifier() : super(null) {
    _loadType();
  }

  static const _key = 'provider_type';

  Future<void> _loadType() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'services') {
      state = ProviderType.services;
    } else if (value == 'marketplace') {
      state = ProviderType.marketplace;
    } else {
      state = null;
    }
  }

  Future<void> setType(ProviderType type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, type.name);
  }

  Future<void> clearType() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Provider pentru tipul de prestator
final providerTypeProvider = StateNotifierProvider<ProviderTypeNotifier, ProviderType?>(
  (ref) => ProviderTypeNotifier(),
);

/// Notifier pentru profilul prestatorului
class ProviderProfileNotifier extends StateNotifier<ProviderProfile?> {
  ProviderProfileNotifier() : super(null) {
    _loadProfile();
  }

  static const _key = 'provider_profile';

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        state = ProviderProfile(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'],
          description: data['description'],
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          isAvailable: data['isAvailable'] ?? true,
          isVerified: data['isVerified'] ?? false,
          categories: (data['categories'] as List?)?.cast<String>() ?? [],
          services: (data['services'] as List?)
                  ?.map((s) => ProviderServiceItem.fromJson(s))
                  .toList() ??
              [],
        );
      } catch (e) {
        // Ignore parse errors
      }
    }
  }

  Future<void> _saveProfile() async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'id': state!.id,
      'name': state!.name,
      'email': state!.email,
      'phone': state!.phone,
      'description': state!.description,
      'rating': state!.rating,
      'isAvailable': state!.isAvailable,
      'isVerified': state!.isVerified,
      'categories': state!.categories,
      'services': state!.services.map((s) => s.toJson()).toList(),
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  /// Setează profilul prestatorului
  Future<void> setProfile(ProviderProfile profile) async {
    state = profile;
    await _saveProfile();
  }

  /// Actualizează disponibilitatea
  Future<void> setAvailability(bool isAvailable) async {
    if (state != null) {
      state = state!.copyWith(isAvailable: isAvailable);
      await _saveProfile();
    }
  }

  /// Adaugă un serviciu
  Future<void> addService(ProviderServiceItem service) async {
    if (state != null) {
      final services = [...state!.services, service];
      state = state!.copyWith(services: services);
      await _saveProfile();
    }
  }

  /// Actualizează un serviciu
  Future<void> updateService(ProviderServiceItem service) async {
    if (state != null) {
      final services = state!.services.map((s) {
        return s.id == service.id ? service : s;
      }).toList();
      state = state!.copyWith(services: services);
      await _saveProfile();
    }
  }

  /// Șterge un serviciu
  Future<void> removeService(String serviceId) async {
    if (state != null) {
      final services = state!.services.where((s) => s.id != serviceId).toList();
      state = state!.copyWith(services: services);
      await _saveProfile();
    }
  }

  /// Toggle serviciu activ/inactiv
  Future<void> toggleServiceActive(String serviceId) async {
    if (state != null) {
      final services = state!.services.map((s) {
        return s.id == serviceId ? s.copyWith(isActive: !s.isActive) : s;
      }).toList();
      state = state!.copyWith(services: services);
      await _saveProfile();
    }
  }

  /// Actualizează categoriile
  Future<void> updateCategories(List<String> categories) async {
    if (state != null) {
      state = state!.copyWith(categories: categories);
      await _saveProfile();
    }
  }

  /// Logout - șterge profilul
  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Provider pentru profilul prestatorului
final providerProfileProvider =
    StateNotifierProvider<ProviderProfileNotifier, ProviderProfile?>(
  (ref) => ProviderProfileNotifier(),
);

/// Provider pentru comenzile prestatorului (demo)
class ProviderOrdersNotifier extends StateNotifier<List<ProviderOrder>> {
  ProviderOrdersNotifier() : super([]) {
    _loadDemoOrders();
  }

  void _loadDemoOrders() {
    // Date demo pentru comenzi
    state = [
      ProviderOrder(
        id: '1001',
        customerName: 'Maria Ionescu',
        serviceName: 'Transport local',
        status: OrderStatus.pending,
        price: 45.0,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        address: 'Str. Eroilor 25, Cluj-Napoca',
      ),
      ProviderOrder(
        id: '1002',
        customerName: 'Andrei Pop',
        serviceName: 'Livrare colete',
        status: OrderStatus.accepted,
        price: 30.0,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        address: 'Bd. 21 Decembrie 45, Cluj-Napoca',
      ),
      ProviderOrder(
        id: '1003',
        customerName: 'Elena Radu',
        serviceName: 'Transport aeroport',
        status: OrderStatus.completed,
        price: 120.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        address: 'Aeroportul Internațional Cluj',
      ),
    ];
  }

  void acceptOrder(String orderId) {
    state = state.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: OrderStatus.accepted);
      }
      return o;
    }).toList();
  }

  void rejectOrder(String orderId) {
    state = state.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: OrderStatus.rejected);
      }
      return o;
    }).toList();
  }

  void completeOrder(String orderId) {
    state = state.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: OrderStatus.completed);
      }
      return o;
    }).toList();
  }
}

final providerOrdersProvider =
    StateNotifierProvider<ProviderOrdersNotifier, List<ProviderOrder>>(
  (ref) => ProviderOrdersNotifier(),
);

/// Model pentru o comandă
class ProviderOrder {
  final String id;
  final String customerName;
  final String serviceName;
  final OrderStatus status;
  final double price;
  final DateTime createdAt;
  final String address;
  final String? customerPhone;
  final String? notes;

  ProviderOrder({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.status,
    required this.price,
    required this.createdAt,
    required this.address,
    this.customerPhone,
    this.notes,
  });

  ProviderOrder copyWith({
    String? id,
    String? customerName,
    String? serviceName,
    OrderStatus? status,
    double? price,
    DateTime? createdAt,
    String? address,
    String? customerPhone,
    String? notes,
  }) {
    return ProviderOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
    );
  }
}

enum OrderStatus {
  pending,
  accepted,
  inProgress,
  completed,
  rejected,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'În așteptare';
      case OrderStatus.accepted:
        return 'Acceptată';
      case OrderStatus.inProgress:
        return 'În desfășurare';
      case OrderStatus.completed:
        return 'Finalizată';
      case OrderStatus.rejected:
        return 'Respinsă';
      case OrderStatus.cancelled:
        return 'Anulată';
    }
  }

  String get color {
    switch (this) {
      case OrderStatus.pending:
        return 'orange';
      case OrderStatus.accepted:
        return 'blue';
      case OrderStatus.inProgress:
        return 'purple';
      case OrderStatus.completed:
        return 'green';
      case OrderStatus.rejected:
        return 'red';
      case OrderStatus.cancelled:
        return 'grey';
    }
  }
}

