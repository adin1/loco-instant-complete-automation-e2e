import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/provider_search_result.dart';
import '../../services/backend_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Câmp unic pentru adresă / stradă (zonă de căutare prestatori)
  final _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();
  final Completer<GoogleMapController> _mapController = Completer();

  // Fallback pe Cluj dacă nu putem obține locația
  static const LatLng _fallbackCenter = LatLng(46.770439, 23.591423);
  static const String _currentLocationLabel = 'Locația mea actuală';

  late final BackendApiService _api;
  final List<ProviderSearchResult> _providers = <ProviderSearchResult>[];
  ProviderSearchResult? _selectedProvider;
  bool _isLoadingProviders = false;
  bool _isCreatingOrder = false;
  int? _activeOrderId;
  String? _activeOrderStatus;
  LatLng _currentCenter = _fallbackCenter;
  bool _isGettingLocation = false;
  double? _estimatedPrice;
  static const _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  @override
  void initState() {
    super.initState();
    final isAndroidEmulator =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final baseUrl = _apiBaseUrlOverride.isNotEmpty
        ? _apiBaseUrlOverride
        : (isAndroidEmulator
            ? 'http://10.0.2.2:3000'
            : 'http://localhost:3000');
    _api = BackendApiService(baseUrl: baseUrl);
    _initLocationAndSearch();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndSearch() async {
    setState(() {
      _isGettingLocation = true;
    });

    LatLng center = _fallbackCenter;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviciile de localizare sunt dezactivate.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permisiunea de localizare a fost refuzată.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      center = LatLng(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Folosim locația implicită (Cluj) – motiv: $e',
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _currentCenter = center;
      _isGettingLocation = false;
      // Autocomplete pentru câmpul de adresă cu locația curentă (label informativ)
      _addressController.text = _currentLocationLabel;
    });

    if (_mapController.isCompleted) {
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(center, 13),
      );
    }

    await _searchProviders();
  }

  Future<void> _searchProviders() async {
    setState(() {
      _isLoadingProviders = true;
    });
    try {
      final results = await _api.searchProviders(
        q: 'taxi',
        lat: _currentCenter.latitude,
        lon: _currentCenter.longitude,
      );
      setState(() {
        _providers
          ..clear()
          ..addAll(results);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load providers: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProviders = false;
        });
      }
    }
  }

  /// Caută o zonă pe hartă după adresă / stradă și apoi încarcă prestatori în jur.
  Future<void> _searchByAddress() async {
    final query = _addressController.text.trim();

    if (query.isEmpty) {
      // Dacă nu avem adresă introdusă, folosim pur și simplu locația curentă (_currentCenter).
      await _searchProviders();
      return;
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        <String, String>{
          'q': query,
          'format': 'json',
          'limit': '1',
        },
      );

      final dio = Dio()
        ..options.headers['User-Agent'] =
            'loco-instant-flutter/0.1 (local dev)';

      final response = await dio.getUri(uri);
      final data = response.data;

      if (data is List && data.isNotEmpty) {
        final first = data.first as Map<String, dynamic>;
        final lat = double.tryParse(first['lat']?.toString() ?? '');
        final lon = double.tryParse(first['lon']?.toString() ?? '');

        if (lat != null && lon != null) {
          final center = LatLng(lat, lon);

          if (!mounted) return;
          setState(() {
            _currentCenter = center;
          });

          if (_mapController.isCompleted) {
            final controller = await _mapController.future;
            await controller.animateCamera(
              CameraUpdate.newLatLngZoom(center, 14),
            );
          }

          await _searchProviders();
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nu am găsit această adresă. Încearcă altă formulare.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nu am putut localiza adresa: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  /// Afișează un selector simplu: locația curentă sau altă adresă.
  Future<void> _showLocationChoice() async {
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                elevation: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.my_location),
                      title: const Text('Folosește locația mea actuală'),
                      onTap: () => Navigator.of(context).pop('current'),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.edit_location_alt_outlined),
                      title: const Text('Introdu altă adresă'),
                      onTap: () => Navigator.of(context).pop('custom'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (choice == 'current') {
      _addressController.text = _currentLocationLabel;
      await _initLocationAndSearch();
    } else if (choice == 'custom') {
      _addressController.clear();
      FocusScope.of(context).requestFocus(_addressFocusNode);
    }
  }

  Set<Marker> get _markers {
    return _providers
        .map(
          (p) => Marker(
            markerId: MarkerId(p.id),
            position: LatLng(p.lat, p.lon),
            infoWindow: InfoWindow(
              title: p.name,
              snippet: p.serviceNames.isNotEmpty ? p.serviceNames.first : null,
            ),
            onTap: () {
              _onProviderSelected(p);
            },
          ),
        )
        .toSet();
  }

  Future<void> _onProviderSelected(ProviderSearchResult provider) async {
    setState(() {
      _selectedProvider = provider;
      _estimatedPrice = _computeEstimatedPrice(provider);
    });

    if (_mapController.isCompleted) {
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(provider.lat, provider.lon),
          15,
        ),
      );
    }
  }

  double _computeEstimatedPrice(ProviderSearchResult provider) {
    final origin = _currentCenter;
    final destination = LatLng(provider.lat, provider.lon);
    final distanceKm = _distanceInKm(origin, destination);

    const baseFare = 15.0; // tarif pornire
    const perKm = 3.0; // RON / km

    final rawPrice = baseFare + distanceKm * perKm;
    // Limităm într-un interval rezonabil pentru demo
    return rawPrice.clamp(20.0, 200.0);
  }

  double _distanceInKm(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;

    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);

    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * math.pi / 180.0;

  Future<void> _createOrder(int serviceIndex) async {
    if (_selectedProvider == null) return;

    final services = _selectedProvider!.serviceNames;
    final String serviceName =
        (serviceIndex >= 0 && serviceIndex < services.length)
            ? services[serviceIndex]
            : 'Serviciu';

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      final providerIdInt = int.tryParse(_selectedProvider!.providerId);

      // Încercăm să mapăm serviciul selectat la un ID numeric, altfel folosim 1 (demo).
      final int serviceId = () {
        if (serviceIndex >= 0 &&
            serviceIndex < _selectedProvider!.serviceIds.length) {
          final rawId = _selectedProvider!.serviceIds[serviceIndex];
          return int.tryParse(rawId) ?? 1;
        }
        return 1;
      }();

      final response = await _api.createOrder(
        customerId: 1,
        serviceId: serviceId,
        providerId: providerIdInt,
        status: 'pending',
        priceEstimate: null,
        currency: 'RON',
        originLat: _currentCenter.latitude,
        originLng: _currentCenter.longitude,
      );

      final data = response.data;
      int? orderId;
      if (data is Map<String, dynamic> && data['id'] is num) {
        orderId = (data['id'] as num).toInt();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Comanda a fost creată pentru serviciul: $serviceName',
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        setState(() {
          _activeOrderId = orderId;
          _activeOrderStatus = 'pending';
        });
        if (orderId != null) {
          await _showOrderSummary(orderId, serviceName);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nu s-a putut crea comanda: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });
      }
    }
  }

  Future<void> _openOrderSheet() async {
    // Dacă nu este selectat explicit un provider dar avem rezultate,
    // folosim automat primul provider din listă (cel mai apropiat în demo).
    if (_selectedProvider == null && _providers.isNotEmpty) {
      await _onProviderSelected(_providers.first);
    } else if (_selectedProvider == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nu există prestatori disponibili în zonă.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // După așteptarea selecției provider-ului, verificăm din nou că widgetul
    // este încă montat înainte de a folosi `context` mai departe.
    if (!mounted) return;

    final services = _selectedProvider!.serviceNames;

    int selectedIndex = 0;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedProvider!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Alege serviciul pentru care vrei să faci comanda:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      if (services.isEmpty)
                        const Text(
                          'Acest prestator nu are servicii definite. '
                          'Vom folosi un serviciu generic.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      else
                        RadioGroup<int>(
                          groupValue: selectedIndex,
                          onChanged: (val) {
                            if (val == null) return;
                            setModalState(() {
                              selectedIndex = val;
                            });
                          },
                          child: Column(
                            children: [
                              ...List.generate(services.length, (index) {
                                return RadioListTile<int>(
                                  value: index,
                                  title: Text(services[index]),
                                );
                              }),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Confirmă comanda'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result == true) {
      await _createOrder(selectedIndex);
    }
  }

  Future<void> _showOrderSummary(int orderId, String serviceName) async {
    final provider = _selectedProvider;
    if (provider == null || !mounted) return;

    final estimatedPriceText = _estimatedPrice == null
        ? '—'
        : '${_estimatedPrice!.toStringAsFixed(0)} RON';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.serviceNames.join(', '),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Descriere prestator (demo)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Prestator local verificat, disponibil pentru intervenții rapide '
                  'în zona ta. Program 08:00–22:00, timp mediu de răspuns 15 minute.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Serviciu selectat',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tarif estimat',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            estimatedPriceText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/chat/$orderId');
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat cu prestatorul'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/payment/$orderId');
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Mergi la plată'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 13,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),
          _buildTopSearchCard(context),
          _buildBottomSheet(context),
          if (_isLoadingProviders || _isGettingLocation)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 90),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopSearchCard(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LOCO Instant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Introdu o adresă sau o stradă pentru a găsi prestatori',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          focusNode: _addressFocusNode,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _searchByAddress(),
                          onTap: () {
                            if (_addressController.text == _currentLocationLabel) {
                              _showLocationChoice();
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ex: Str. Eroilor 10, Cluj',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _searchByAddress,
                      icon: const Icon(Icons.search),
                      label: const Text('Găsește furnizor de servicii'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedProvider?.name ??
                          'Găsește un furnizor de servicii pe hartă',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedProvider != null &&
                        _selectedProvider!.ratingAvg != null)
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            _selectedProvider!.ratingAvg!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedProvider?.serviceNames.join(', ') ??
                      'Alege o destinație și un furnizor pentru a începe',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: _providers.isEmpty
                      ? const Center(
                          child: Text(
                            'Nu sunt mașini disponibile în zonă. Încearcă să cauți din nou.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _providers.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final provider = _providers[index];
                            final isSelected =
                                _selectedProvider?.id == provider.id;
                            return GestureDetector(
                              onTap: () => _onProviderSelected(provider),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(12),
                                width: 220,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blueAccent
                                        : Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            provider.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (provider.ratingAvg != null)
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  size: 14,
                                                  color: Colors.amber),
                                              const SizedBox(width: 2),
                                              Text(
                                                provider.ratingAvg!
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.serviceNames.join(', '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (provider.isInstant)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: const Text(
                                              'Instant',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          '${provider.lat.toStringAsFixed(3)}, ${provider.lon.toStringAsFixed(3)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tarif estimat',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _estimatedPrice == null
                              ? '—'
                              : '${_estimatedPrice!.toStringAsFixed(0)} RON',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed:
                            _isCreatingOrder ? null : _openOrderSheet,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isCreatingOrder
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Comandă'),
                      ),
                    ),
                  ],
                ),
                if (_activeOrderId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Cerere #$_activeOrderId – status: ${_activeOrderStatus ?? 'pending'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          if (_activeOrderId != null) {
                            context.push('/chat/${_activeOrderId!}');
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Chat'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if (_activeOrderId != null) {
                            context.push('/payment/${_activeOrderId!}');
                          }
                        },
                        icon: const Icon(Icons.payment_outlined, size: 18),
                        label: const Text('Plată'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if (_activeOrderId != null) {
                            context.push('/review/${_activeOrderId!}');
                          }
                        },
                        icon: const Icon(Icons.star_border, size: 18),
                        label: const Text('Rating'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


