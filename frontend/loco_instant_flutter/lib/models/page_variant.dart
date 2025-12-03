import 'dart:convert';

/// Model pentru o variantă de pagină
class PageVariant {
  final String id;
  final String pageKey;
  final String name;
  final String? description;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic> config;

  PageVariant({
    required this.id,
    required this.pageKey,
    required this.name,
    this.description,
    required this.createdAt,
    required this.isActive,
    required this.config,
  });

  /// Creează din JSON
  factory PageVariant.fromJson(Map<String, dynamic> json) {
    return PageVariant(
      id: json['id'] as String,
      pageKey: json['pageKey'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
      config: json['config'] as Map<String, dynamic>,
    );
  }

  /// Convertește în JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageKey': pageKey,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'config': config,
    };
  }

  /// Creează o copie cu modificări
  PageVariant copyWith({
    String? id,
    String? pageKey,
    String? name,
    String? description,
    DateTime? createdAt,
    bool? isActive,
    Map<String, dynamic>? config,
  }) {
    return PageVariant(
      id: id ?? this.id,
      pageKey: pageKey ?? this.pageKey,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      config: config ?? this.config,
    );
  }

  @override
  String toString() {
    return 'PageVariant(id: $id, pageKey: $pageKey, name: $name, isActive: $isActive)';
  }
}

/// Configurație pentru pagina de Login
class LoginPageConfig {
  final String layout; // 'classic', 'split', 'centered'
  final String theme; // 'gradient', 'dark', 'light'
  final bool showPresentation;
  final int presentationHeight;
  final bool showBackgroundEffects;
  final String cardStyle; // 'white', 'glass', 'transparent'
  final String accentColor;

  const LoginPageConfig({
    this.layout = 'split',
    this.theme = 'gradient',
    this.showPresentation = true,
    this.presentationHeight = 320,
    this.showBackgroundEffects = false,
    this.cardStyle = 'white',
    this.accentColor = '#2DD4BF',
  });

  factory LoginPageConfig.fromJson(Map<String, dynamic> json) {
    return LoginPageConfig(
      layout: json['layout'] as String? ?? 'split',
      theme: json['theme'] as String? ?? 'gradient',
      showPresentation: json['showPresentation'] as bool? ?? true,
      presentationHeight: json['presentationHeight'] as int? ?? 320,
      showBackgroundEffects: json['showBackgroundEffects'] as bool? ?? false,
      cardStyle: json['cardStyle'] as String? ?? 'white',
      accentColor: json['accentColor'] as String? ?? '#2DD4BF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layout': layout,
      'theme': theme,
      'showPresentation': showPresentation,
      'presentationHeight': presentationHeight,
      'showBackgroundEffects': showBackgroundEffects,
      'cardStyle': cardStyle,
      'accentColor': accentColor,
    };
  }

  LoginPageConfig copyWith({
    String? layout,
    String? theme,
    bool? showPresentation,
    int? presentationHeight,
    bool? showBackgroundEffects,
    String? cardStyle,
    String? accentColor,
  }) {
    return LoginPageConfig(
      layout: layout ?? this.layout,
      theme: theme ?? this.theme,
      showPresentation: showPresentation ?? this.showPresentation,
      presentationHeight: presentationHeight ?? this.presentationHeight,
      showBackgroundEffects: showBackgroundEffects ?? this.showBackgroundEffects,
      cardStyle: cardStyle ?? this.cardStyle,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

/// Configurație pentru Homepage
class HomepageConfig {
  final String mapStyle; // 'standard', 'satellite', 'terrain'
  final bool showCategories;
  final bool showSearchBar;
  final String layout; // 'map_focus', 'split', 'list_focus'

  const HomepageConfig({
    this.mapStyle = 'standard',
    this.showCategories = true,
    this.showSearchBar = true,
    this.layout = 'map_focus',
  });

  factory HomepageConfig.fromJson(Map<String, dynamic> json) {
    return HomepageConfig(
      mapStyle: json['mapStyle'] as String? ?? 'standard',
      showCategories: json['showCategories'] as bool? ?? true,
      showSearchBar: json['showSearchBar'] as bool? ?? true,
      layout: json['layout'] as String? ?? 'map_focus',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mapStyle': mapStyle,
      'showCategories': showCategories,
      'showSearchBar': showSearchBar,
      'layout': layout,
    };
  }
}

