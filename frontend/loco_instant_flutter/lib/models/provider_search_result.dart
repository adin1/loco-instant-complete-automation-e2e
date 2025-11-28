class ProviderSearchResult {
  final String id;
  final String tenantCode;
  final String providerId;
  final String name;
  final List<String> serviceIds;
  final List<String> serviceNames;
  final double? ratingAvg;
  final int? ratingCount;
  final bool isInstant;
  final double lat;
  final double lon;

  ProviderSearchResult({
    required this.id,
    required this.tenantCode,
    required this.providerId,
    required this.name,
    required this.serviceIds,
    required this.serviceNames,
    required this.ratingAvg,
    required this.ratingCount,
    required this.isInstant,
    required this.lat,
    required this.lon,
  });

  factory ProviderSearchResult.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] as Map<String, dynamic>?) ?? {};
    final serviceIds = (json['service_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final serviceNames = (json['service_names'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    return ProviderSearchResult(
      id: json['id']?.toString() ?? '',
      tenantCode: json['tenant_code']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      serviceIds: serviceIds,
      serviceNames: serviceNames,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt(),
      isInstant: json['is_instant'] as bool? ?? false,
      lat: (location['lat'] as num?)?.toDouble() ?? 0,
      lon: (location['lon'] as num?)?.toDouble() ?? 0,
    );
  }
}


