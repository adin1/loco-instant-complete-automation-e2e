import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page_variant.dart';
import '../services/page_variant_service.dart';

/// Provider pentru PageVariantService
final pageVariantServiceProvider = Provider<PageVariantService>((ref) {
  return PageVariantService();
});

/// Provider pentru variantele unei pagini specifice
final pageVariantsProvider = FutureProvider.family<List<PageVariant>, String>((ref, pageKey) async {
  final service = ref.watch(pageVariantServiceProvider);
  await service.init();
  return service.getVariantsForPage(pageKey);
});

/// Provider pentru varianta activă a unei pagini
final activeVariantProvider = FutureProvider.family<PageVariant?, String>((ref, pageKey) async {
  final service = ref.watch(pageVariantServiceProvider);
  await service.init();
  return service.getActiveVariant(pageKey);
});

/// Provider pentru configurația activă a paginii de login
final loginConfigProvider = FutureProvider<LoginPageConfig>((ref) async {
  final service = ref.watch(pageVariantServiceProvider);
  await service.init();
  final variant = service.getActiveVariant('login');
  
  if (variant != null) {
    return LoginPageConfig.fromJson(variant.config);
  }
  
  return const LoginPageConfig();
});

/// Provider pentru configurația activă a homepage-ului
final homepageConfigProvider = FutureProvider<HomepageConfig>((ref) async {
  final service = ref.watch(pageVariantServiceProvider);
  await service.init();
  final variant = service.getActiveVariant('homepage');
  
  if (variant != null) {
    return HomepageConfig.fromJson(variant.config);
  }
  
  return const HomepageConfig();
});

/// StateNotifier pentru gestionarea variantelor (pentru Admin UI)
class PageVariantNotifier extends StateNotifier<AsyncValue<List<PageVariant>>> {
  final PageVariantService _service;
  final String pageKey;

  PageVariantNotifier(this._service, this.pageKey) : super(const AsyncValue.loading()) {
    _loadVariants();
  }

  Future<void> _loadVariants() async {
    state = const AsyncValue.loading();
    try {
      await _service.init();
      final variants = _service.getVariantsForPage(pageKey);
      state = AsyncValue.data(variants);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadVariants();
  }

  Future<void> createVariant(String name, String? description, Map<String, dynamic> config) async {
    try {
      await _service.createVariant(
        pageKey: pageKey,
        name: name,
        description: description,
        config: config,
      );
      await _loadVariants();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> activateVariant(String variantId) async {
    try {
      await _service.activateVariant(variantId);
      await _loadVariants();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> duplicateVariant(String variantId, String newName) async {
    try {
      await _service.duplicateVariant(variantId, newName);
      await _loadVariants();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVariant(String variantId) async {
    try {
      await _service.deleteVariant(variantId);
      await _loadVariants();
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider factory pentru PageVariantNotifier
final pageVariantNotifierProvider = StateNotifierProvider.family<PageVariantNotifier, AsyncValue<List<PageVariant>>, String>(
  (ref, pageKey) {
    final service = ref.watch(pageVariantServiceProvider);
    return PageVariantNotifier(service, pageKey);
  },
);

