import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/page_variant.dart';

/// Service pentru gestionarea variantelor de pagini
/// Stochează local în SharedPreferences
class PageVariantService {
  static const String _storageKey = 'page_variants';
  
  /// Instanță singleton
  static final PageVariantService _instance = PageVariantService._internal();
  factory PageVariantService() => _instance;
  PageVariantService._internal();

  List<PageVariant> _variants = [];
  bool _initialized = false;

  /// Inițializează serviciul și încarcă variantele salvate
  Future<void> init() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    
    if (data != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(data);
        _variants = jsonList.map((json) => PageVariant.fromJson(json)).toList();
      } catch (e) {
        print('Error loading page variants: $e');
        _variants = [];
      }
    }
    
    // Creează variante default dacă nu există
    await _ensureDefaultVariants();
    
    _initialized = true;
  }

  /// Asigură că există variante default pentru paginile principale
  Future<void> _ensureDefaultVariants() async {
    // Default Login variant
    if (!_variants.any((v) => v.pageKey == 'login')) {
      await createVariant(
        pageKey: 'login',
        name: 'Login v1 - Gradient Classic',
        description: 'Varianta inițială cu gradient albastru-verde',
        config: const LoginPageConfig().toJson(),
        setActive: true,
      );
    }
    
    // Default Homepage variant
    if (!_variants.any((v) => v.pageKey == 'homepage')) {
      await createVariant(
        pageKey: 'homepage',
        name: 'Homepage v1 - Map Focus',
        description: 'Varianta inițială cu hartă centrală',
        config: const HomepageConfig().toJson(),
        setActive: true,
      );
    }
  }

  /// Salvează variantele în storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _variants.map((v) => v.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Obține toate variantele pentru o pagină
  List<PageVariant> getVariantsForPage(String pageKey) {
    return _variants.where((v) => v.pageKey == pageKey).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obține varianta activă pentru o pagină
  PageVariant? getActiveVariant(String pageKey) {
    try {
      return _variants.firstWhere(
        (v) => v.pageKey == pageKey && v.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obține o variantă după ID
  PageVariant? getVariantById(String id) {
    try {
      return _variants.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Creează o nouă variantă
  Future<PageVariant> createVariant({
    required String pageKey,
    required String name,
    String? description,
    required Map<String, dynamic> config,
    bool setActive = false,
  }) async {
    final id = '${pageKey}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Dacă setActive, dezactivează celelalte variante pentru această pagină
    if (setActive) {
      _variants = _variants.map((v) {
        if (v.pageKey == pageKey && v.isActive) {
          return v.copyWith(isActive: false);
        }
        return v;
      }).toList();
    }
    
    final variant = PageVariant(
      id: id,
      pageKey: pageKey,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      isActive: setActive,
      config: config,
    );
    
    _variants.add(variant);
    await _save();
    
    return variant;
  }

  /// Activează o variantă (dezactivează celelalte pentru aceeași pagină)
  Future<void> activateVariant(String variantId) async {
    final variant = getVariantById(variantId);
    if (variant == null) return;
    
    _variants = _variants.map((v) {
      if (v.pageKey == variant.pageKey) {
        return v.copyWith(isActive: v.id == variantId);
      }
      return v;
    }).toList();
    
    await _save();
  }

  /// Duplică o variantă
  Future<PageVariant> duplicateVariant(String variantId, String newName) async {
    final original = getVariantById(variantId);
    if (original == null) {
      throw Exception('Variant not found');
    }
    
    return createVariant(
      pageKey: original.pageKey,
      name: newName,
      description: 'Copie a "${original.name}"',
      config: Map<String, dynamic>.from(original.config),
      setActive: false,
    );
  }

  /// Șterge o variantă (nu poate șterge varianta activă)
  Future<bool> deleteVariant(String variantId) async {
    final variant = getVariantById(variantId);
    if (variant == null) return false;
    
    // Nu putem șterge varianta activă
    if (variant.isActive) {
      return false;
    }
    
    _variants.removeWhere((v) => v.id == variantId);
    await _save();
    return true;
  }

  /// Actualizează configurația unei variante
  Future<void> updateVariantConfig(String variantId, Map<String, dynamic> newConfig) async {
    _variants = _variants.map((v) {
      if (v.id == variantId) {
        return v.copyWith(config: newConfig);
      }
      return v;
    }).toList();
    
    await _save();
  }

  /// Redenumește o variantă
  Future<void> renameVariant(String variantId, String newName, String? newDescription) async {
    _variants = _variants.map((v) {
      if (v.id == variantId) {
        return v.copyWith(name: newName, description: newDescription);
      }
      return v;
    }).toList();
    
    await _save();
  }

  /// Salvează starea curentă a unei pagini ca variantă nouă
  Future<PageVariant> saveCurrentAsVariant({
    required String pageKey,
    required String name,
    String? description,
    required Map<String, dynamic> currentConfig,
  }) async {
    return createVariant(
      pageKey: pageKey,
      name: name,
      description: description,
      config: currentConfig,
      setActive: false,
    );
  }

  /// Lista tuturor page keys disponibile
  List<String> get availablePageKeys {
    return _variants.map((v) => v.pageKey).toSet().toList();
  }
}

