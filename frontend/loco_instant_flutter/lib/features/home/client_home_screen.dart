import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  final _searchController = TextEditingController();
  final _marketplaceSearchController = TextEditingController();
  final ScrollController _marketplaceScrollController = ScrollController();
  final Completer<GoogleMapController> _mapController = Completer();
  final FocusNode _searchFocusNode = FocusNode();
  
  int? _hoveredCategoryIndex;
  int? _hoveredSubcategoryIndex;
  int _currentProviderPage = 0;
  Timer? _marketplaceScrollTimer;
  String? _selectedCategory;
  String? _selectedSubcategory;
  bool _isGettingLocation = false;
  bool _showLocationSuggestions = false;
  String _currentLocationText = 'Cluj-Napoca';
  
  // Lista de sugestii pentru căutare
  final List<String> _locationSuggestions = [
    '📍 Locația mea actuală',
    'Str. Memorandumului, Cluj-Napoca',
    'Str. Eroilor, Cluj-Napoca', 
    'Piața Unirii, Cluj-Napoca',
    'Str. Horea, Cluj-Napoca',
    'Mărăști, Cluj-Napoca',
    'Gheorgheni, Cluj-Napoca',
    'Mănăștur, Cluj-Napoca',
  ];

  // Cluj-Napoca coordinates (current user location simulation)
  LatLng _userLocation = const LatLng(46.770439, 23.591423);

  // Categorii ordonate după urgență și popularitate în orașe mari
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.plumbing,
      'name': 'Instalator',
      'urgent': true,
      'subcategories': ['Urgență - scurgeri apă', 'Desfundare canalizare', 'Instalații sanitare', 'Montaj centrale termice', 'Reparații țevi', 'Instalare boiler'],
    },
    {
      'icon': Icons.electrical_services,
      'name': 'Electrician',
      'urgent': true,
      'subcategories': ['Urgență - pană curent', 'Reparații prize/întrerupătoare', 'Tablouri electrice', 'Instalații electrice', 'Verificări PRAM', 'Iluminat LED'],
    },
    {
      'icon': Icons.lock,
      'name': 'Lăcătuș',
      'urgent': true,
      'subcategories': ['Deblocare ușă - URGENȚĂ', 'Schimbare yală', 'Montaj încuietori', 'Copiere chei', 'Blindare uși'],
    },
    {
      'icon': Icons.local_shipping,
      'name': 'Transport & Mutări',
      'urgent': false,
      'subcategories': ['Mutări apartamente', 'Transport marfă', 'Transport mobilă', 'Curierat local', 'Transport materiale construcții'],
    },
    {
      'icon': Icons.cleaning_services,
      'name': 'Curățenie',
      'urgent': false,
      'subcategories': ['Curățenie generală', 'Curățenie după constructor', 'Curățenie birouri', 'Spălat geamuri', 'Dezinfecție'],
    },
    {
      'icon': Icons.handyman,
      'name': 'Reparații casă',
      'urgent': false,
      'subcategories': ['Reparații mobilă', 'Montaj mobilier IKEA', 'Reparații uși/ferestre', 'Montaj corpuri suspendate', 'Reparații diverse'],
    },
    {
      'icon': Icons.hvac,
      'name': 'Aer condiționat',
      'urgent': true,
      'subcategories': ['Montaj AC', 'Curățare/igienizare AC', 'Reparații AC', 'Încărcare freon', 'Demontare AC'],
    },
    {
      'icon': Icons.brush,
      'name': 'Zugrăveli',
      'urgent': false,
      'subcategories': ['Zugrăvit interior', 'Zugrăvit exterior', 'Vopsit lavabil', 'Tencuieli decorative', 'Glet și șlefuit'],
    },
    {
      'icon': Icons.computer,
      'name': 'IT & Tech',
      'urgent': false,
      'subcategories': ['Reparații PC/Laptop', 'Instalare software', 'Configurare rețea WiFi', 'Recuperare date', 'Service imprimante'],
    },
    {
      'icon': Icons.roofing,
      'name': 'Acoperiș',
      'urgent': false,
      'subcategories': ['Reparații acoperiș', 'Montaj țiglă', 'Hidroizolații', 'Jgheaburi și burlane', 'Mansardări'],
    },
  ];
  
  int? _clickedCategoryIndex; // Pentru a ține submeniul deschis la click

  // Prestatori cu coordonate pentru distanță
  final List<Map<String, dynamic>> _allProviders = [
    {
      'id': '1',
      'name': 'Ion Popescu',
      'photo': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Soluții electrice rapide și sigure',
      'services': ['Instalații electrice', 'Reparații', 'Verificări'],
      'rating': 4.8,
      'lat': 46.771, 'lng': 23.592, 'distance': 0.2,
    },
    {
      'id': '2',
      'name': 'Maria Ionescu',
      'photo': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Curățenie impecabilă, prețuri corecte',
      'services': ['Curățenie generală', 'După constructor', 'Birouri'],
      'rating': 4.9,
      'lat': 46.768, 'lng': 23.590, 'distance': 0.5,
    },
    {
      'id': '3',
      'name': 'Vasile Mureșan',
      'photo': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150&h=150&fit=crop&crop=face',
      'motto': 'Instalații și reparații non-stop',
      'services': ['Instalații sanitare', 'Desfundări', 'Centrale'],
      'rating': 4.7,
      'lat': 46.772, 'lng': 23.595, 'distance': 0.8,
    },
    {
      'id': '4',
      'name': 'Alex Radu',
      'photo': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      'motto': 'Reparăm orice, oricând',
      'services': ['Mobilă', 'Uși', 'Montaj IKEA'],
      'rating': 4.6,
      'lat': 46.765, 'lng': 23.588, 'distance': 1.2,
    },
    {
      'id': '5',
      'name': 'George Transport',
      'photo': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Transport rapid în Cluj',
      'services': ['Mutări', 'Marfă', 'Curierat'],
      'rating': 4.5,
      'lat': 46.775, 'lng': 23.600, 'distance': 1.5,
    },
    {
      'id': '6',
      'name': 'Elena Grădini',
      'photo': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&h=150&fit=crop&crop=face',
      'motto': 'Grădina ta, pasiunea noastră',
      'services': ['Gazon', 'Întreținere', 'Irigații'],
      'rating': 4.8,
      'lat': 46.760, 'lng': 23.585, 'distance': 2.0,
    },
  ];

  // Produse marketplace
  final List<Map<String, dynamic>> _marketplaceProducts = [
    {'name': 'Miere de albine 100% naturală', 'description': 'Direct de la producător, 1kg', 'price': '45 RON', 'image': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=100&h=100&fit=crop'},
    {'name': 'Dulceață de căpșuni', 'description': 'Făcută în casă, 350g', 'price': '25 RON', 'image': 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=100&h=100&fit=crop'},
    {'name': 'Ouă de țară proaspete', 'description': 'Găini crescute liber, 30 buc', 'price': '35 RON', 'image': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=100&h=100&fit=crop'},
    {'name': 'Brânză de burduf', 'description': 'Tradițională, 500g', 'price': '40 RON', 'image': 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=100&h=100&fit=crop'},
    {'name': 'Țuică de prune', 'description': 'Artizanală, 1L', 'price': '60 RON', 'image': 'https://images.unsplash.com/photo-1569529465841-dfecdab7503b?w=100&h=100&fit=crop'},
    {'name': 'Zacuscă de casă', 'description': 'Rețetă tradițională, 500g', 'price': '30 RON', 'image': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=100&h=100&fit=crop'},
  ];

  // Afișează doar 3 prestatori pe pagină
  List<Map<String, dynamic>> get _currentProviders {
    final start = _currentProviderPage * 3;
    final end = (start + 3).clamp(0, _allProviders.length);
    return _allProviders.sublist(start, end);
  }

  int get _totalPages => (_allProviders.length / 3).ceil();

  @override
  void initState() {
    super.initState();
    _startMarketplaceAutoScroll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _marketplaceSearchController.dispose();
    _marketplaceScrollController.dispose();
    _marketplaceScrollTimer?.cancel();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Obține locația curentă
  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    
    try {
      // Verifică dacă serviciile de localizare sunt activate
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activează serviciile de localizare'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Verifică și cere permisiunea
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permisiunea pentru locație a fost refuzată'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Obține poziția
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _currentLocationText = 'Locația mea (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        _searchController.text = '📍 Locația mea actuală';
        _showLocationSuggestions = false;
      });

      // Mută harta la noua locație
      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(_userLocation));

      // Caută prestatori în apropiere
      _searchNearbyProviders();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la obținerea locației: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  // Caută prestatori în apropiere de locația curentă
  void _searchNearbyProviders() {
    // Sortează prestatorii după distanță
    _allProviders.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    
    setState(() {
      _currentProviderPage = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${_allProviders.length} prestatori găsiți în apropiere'),
          ],
        ),
        backgroundColor: const Color(0xFF2DD4BF),
      ),
    );
  }

  // Selectează o sugestie de locație
  void _selectLocationSuggestion(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _showLocationSuggestions = false;
    });

    if (suggestion.contains('Locația mea')) {
      _getCurrentLocation();
    } else {
      // Pentru străzi, căutăm prestatorii
      _searchNearbyProviders();
    }
  }

  void _startMarketplaceAutoScroll() {
    _marketplaceScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_marketplaceScrollController.hasClients) {
        final maxScroll = _marketplaceScrollController.position.maxScrollExtent;
        final currentScroll = _marketplaceScrollController.offset;
        
        if (currentScroll >= maxScroll) {
          _marketplaceScrollController.jumpTo(0);
        } else {
          _marketplaceScrollController.jumpTo(currentScroll + 0.5);
        }
      }
    });
  }

  void _nextProviderPage() {
    if (_currentProviderPage < _totalPages - 1) {
      setState(() => _currentProviderPage++);
    } else {
      setState(() => _currentProviderPage = 0);
    }
  }

  void _prevProviderPage() {
    if (_currentProviderPage > 0) {
      setState(() => _currentProviderPage--);
    } else {
      setState(() => _currentProviderPage = _totalPages - 1);
    }
  }

  // Căutare prestator - selectează cel mai apropiat
  void _searchProvider() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introdu un termen de căutare')),
      );
      return;
    }

    // Găsește prestatorii care se potrivesc
    final matchingProviders = _allProviders.where((p) {
      final name = (p['name'] as String).toLowerCase();
      final services = (p['services'] as List<String>).join(' ').toLowerCase();
      final motto = (p['motto'] as String).toLowerCase();
      return name.contains(query) || services.contains(query) || motto.contains(query);
    }).toList();

    if (matchingProviders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nu am găsit prestatori pentru "$query"')),
      );
      return;
    }

    // Sortează după distanță și selectează cel mai apropiat
    matchingProviders.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    final closest = matchingProviders.first;

    // Navighează la comanda pentru acest prestator
    _initiateOrder(closest);
  }

  // Selectare subcategorie
  void _selectSubcategory(String category, String subcategory) {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = subcategory;
      _hoveredCategoryIndex = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ai selectat: $category → $subcategory'),
        action: SnackBarAction(
          label: 'Caută prestatori',
          onPressed: () {
            _searchController.text = subcategory;
            _searchProvider();
          },
        ),
      ),
    );
  }

  // Inițiază comandă pentru un prestator
  void _initiateOrder(Map<String, dynamic> provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(provider['photo']),
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider['name'], style: const TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' ${provider['rating']}', style: const TextStyle(fontSize: 14)),
                      Text(' • ${provider['distance']} km', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider['motto'], style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
            const SizedBox(height: 16),
            const Text('Servicii disponibile:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...(provider['services'] as List<String>).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF2DD4BF)),
                  const SizedBox(width: 8),
                  Text(s),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/order/new?providerId=${provider['id']}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Comandă acum'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              ),
            ],
          ),
          // Badge "Susține producătorii locali" - fix în colțul din dreapta jos
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildSupportLocalBadge(),
          ),
        ],
      ),
    );
  }

  // ==================== LOGO WIDGET ====================
  Widget _buildLogo({double iconSize = 36, double fontSize = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin icon cu fulger
        Container(
          width: iconSize,
          height: iconSize * 1.2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: iconSize * 1.2,
                color: const Color(0xFF2DD4BF),
              ),
              Positioned(
                top: iconSize * 0.15,
                child: Icon(
                  Icons.bolt,
                  size: iconSize * 0.5,
                  color: const Color(0xFFCDEB45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Text LOCO INSTANT
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              fontFamily: 'Segoe UI', // Font similar cu cel din imagine
            ),
            children: const [
              TextSpan(text: 'LOCO ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'INSTANT', style: TextStyle(color: Color(0xFF2DD4BF))),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2DD4BF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildLogo(iconSize: 32, fontSize: 18),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      // Buton locație
                      GestureDetector(
                        onTap: _isGettingLocation ? null : _getCurrentLocation,
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _isGettingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.my_location, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Caută serviciu sau introdu adresa...',
                            hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
                            border: InputBorder.none,
                          ),
                          onTap: () => setState(() => _showLocationSuggestions = true),
                          onChanged: (value) {
                            setState(() => _showLocationSuggestions = value.isNotEmpty);
                          },
                          onSubmitted: (_) {
                            setState(() => _showLocationSuggestions = false);
                            _searchProvider();
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _showLocationSuggestions = false);
                          _searchProvider();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Caută',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          _buildHeaderButton(Icons.person_outline, 'Cont', () => _showUserMenu(context)),
          const SizedBox(width: 16),
          _buildHeaderButton(Icons.history, 'Comenzi', () => context.go('/orders')),
        ],
      ),
    );
  }
  
  // Meniu complet pentru utilizator
  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Avatar și info user
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF2DD4BF),
                    child: const Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Utilizator conectat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'client@test.ro',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildMenuItem(Icons.person_outline, 'Profilul meu', () {
              Navigator.pop(context);
              context.go('/profile');
            }),
            _buildMenuItem(Icons.history, 'Istoricul comenzilor', () {
              Navigator.pop(context);
              context.go('/orders');
            }),
            _buildMenuItem(Icons.favorite_border, 'Prestatori favoriți', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcție în dezvoltare')),
              );
            }),
            _buildMenuItem(Icons.location_on_outlined, 'Adresele mele', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcție în dezvoltare')),
              );
            }),
            _buildMenuItem(Icons.payment, 'Metode de plată', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcție în dezvoltare')),
              );
            }),
            _buildMenuItem(Icons.notifications_outlined, 'Notificări', () {
              Navigator.pop(context);
              context.go('/notifications');
            }),
            _buildMenuItem(Icons.settings_outlined, 'Setări', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcție în dezvoltare')),
              );
            }),
            _buildMenuItem(Icons.help_outline, 'Ajutor & Suport', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcție în dezvoltare')),
              );
            }),
            const Divider(),
            _buildMenuItem(Icons.logout, 'Deconectare', () {
              Navigator.pop(context);
              context.go('/login');
            }, isDestructive: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    final activeIndex = _clickedCategoryIndex ?? _hoveredCategoryIndex;
    
    return Stack(
      children: [
        // Overlay pentru a închide sugestiile când dai click în afară
        if (_showLocationSuggestions)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showLocationSuggestions = false),
              child: Container(color: Colors.transparent),
            ),
          ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 240, child: _buildCategoriesSidebar()),
                  const SizedBox(width: 20),
                  Expanded(flex: 3, child: _buildCenterContent()),
                  const SizedBox(width: 20),
                  SizedBox(width: 280, child: _buildMarketplaceSidebar()),
                ],
              ),
            ),
          ),
        ),
        
        // Subcategories overlay - rămâne deschis la click
        if (activeIndex != null)
          Positioned(
            left: 280,
            top: 100 + (activeIndex * 52.0),
            child: _buildSubmenuOverlay(),
          ),
          
        // Location suggestions dropdown
        if (_showLocationSuggestions)
          Positioned(
            top: 70,
            left: MediaQuery.of(context).size.width * 0.25,
            right: MediaQuery.of(context).size.width * 0.25,
            child: _buildLocationSuggestions(),
          ),
      ],
    );
  }
  
  Widget _buildLocationSuggestions() {
    final query = _searchController.text.toLowerCase();
    final filteredSuggestions = _locationSuggestions.where((s) =>
      query.isEmpty || s.toLowerCase().contains(query)
    ).toList();
    
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.grey.shade600, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Sugestii de locație',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              ...filteredSuggestions.map((suggestion) => ListTile(
                leading: Icon(
                  suggestion.contains('Locația mea') ? Icons.my_location : Icons.location_on_outlined,
                  color: suggestion.contains('Locația mea') ? const Color(0xFF2DD4BF) : Colors.grey.shade600,
                ),
                title: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: suggestion.contains('Locația mea') ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onTap: () => _selectLocationSuggestion(suggestion),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== CATEGORIES SIDEBAR ====================
  Widget _buildCategoriesSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header "Categorii"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF2DD4BF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.category, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Categorii',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (_clickedCategoryIndex != null)
                      GestureDetector(
                        onTap: () => setState(() => _clickedCategoryIndex = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Categories list
              ...List.generate(_categories.length, (index) => _buildCategoryItem(index)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final category = _categories[index];
    final isSelected = _clickedCategoryIndex == index;
    final isHovered = _hoveredCategoryIndex == index;
    final isActive = isSelected || isHovered;
    final isUrgent = category['urgent'] == true;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCategoryIndex = index),
      onExit: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _clickedCategoryIndex != index) {
            setState(() => _hoveredCategoryIndex = null);
          }
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            // La click, păstrăm submeniul deschis
            _clickedCategoryIndex = _clickedCategoryIndex == index ? null : index;
            _hoveredCategoryIndex = _clickedCategoryIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF0F9FF) : Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF2DD4BF) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category['icon'],
                  size: 20,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      category['name'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isActive ? const Color(0xFF1565C0) : const Color(0xFF333333),
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '24/7',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.expand_less : Icons.chevron_right,
                size: 20,
                color: isActive ? const Color(0xFF2DD4BF) : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmenuOverlay() {
    final activeIndex = _clickedCategoryIndex ?? _hoveredCategoryIndex;
    if (activeIndex == null) return const SizedBox.shrink();
    
    final category = _categories[activeIndex];
    final subcategories = category['subcategories'] as List<String>;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSubcategoryIndex = 0),
      onExit: (_) {
        // Nu închidem submeniul dacă e selectat prin click
        if (_clickedCategoryIndex == null) {
          setState(() {
            _hoveredSubcategoryIndex = null;
            _hoveredCategoryIndex = null;
          });
        }
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2DD4BF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(category['icon'], color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ...subcategories.asMap().entries.map((entry) {
              final isSubHovered = _hoveredSubcategoryIndex == entry.key;
              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredSubcategoryIndex = entry.key),
                child: GestureDetector(
                  onTap: () => _selectSubcategory(category['name'], entry.value),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSubHovered ? const Color(0xFFF0F9FF) : Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSubHovered ? Icons.arrow_forward : Icons.circle,
                          size: isSubHovered ? 18 : 6,
                          color: isSubHovered ? const Color(0xFF2DD4BF) : Colors.grey.shade400,
                        ),
                        SizedBox(width: isSubHovered ? 10 : 14),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSubHovered ? FontWeight.w600 : FontWeight.normal,
                              color: isSubHovered ? const Color(0xFF1565C0) : const Color(0xFF555555),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ==================== CENTER CONTENT ====================
  Widget _buildCenterContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGoogleMap(),
          const SizedBox(height: 24),
          _buildProvidersSection(),
        ],
      ),
    );
  }

  // ==================== SUPPORT LOCAL BADGE ====================
  Widget _buildSupportLocalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Produse de casă',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Susține producătorii locali!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            markers: {
              Marker(
                markerId: const MarkerId('user'),
                position: _userLocation,
                infoWindow: const InfoWindow(title: 'Tu ești aici'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            },
          ),
          
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2DD4BF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text('Cluj-Napoca', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Icon(Icons.search, color: Color(0xFF2DD4BF), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Ce serviciu cauți?',
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _searchProvider(),
            ),
          ),
          GestureDetector(
            onTap: _searchProvider,
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF2DD4BF)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Căutare',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROVIDERS SECTION - 3 per pagină ====================
  Widget _buildProvidersSection() {
    return Column(
      children: [
        Row(
          children: [
            _buildNavigationArrow(Icons.chevron_left, _prevProviderPage),
            const SizedBox(width: 12),
            
            // 3 Prestatori pe rând
            Expanded(
              child: Row(
                children: [
                  if (_currentProviders.isNotEmpty)
                    Expanded(child: _buildProviderCard(_currentProviders[0])),
                  const SizedBox(width: 16),
                  if (_currentProviders.length > 1)
                    Expanded(child: _buildProviderCard(_currentProviders[1])),
                  const SizedBox(width: 16),
                  if (_currentProviders.length > 2)
                    Expanded(child: _buildProviderCard(_currentProviders[2])),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            _buildNavigationArrow(Icons.chevron_right, _nextProviderPage),
          ],
        ),
        
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalPages, (index) {
            return GestureDetector(
              onTap: () => setState(() => _currentProviderPage = index),
              child: Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentProviderPage == index 
                      ? const Color(0xFF2DD4BF) 
                      : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNavigationArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
        ),
        child: Icon(icon, color: const Color(0xFF2DD4BF), size: 32),
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Column(
        children: [
          // Header cu gradient
          Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF2DD4BF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 33,
                  backgroundImage: NetworkImage(provider['photo'] ?? ''),
                  onBackgroundImageError: (_, __) {},
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  provider['name'] ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${provider['rating']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(' • ${provider['distance']} km', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  provider['motto'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Servicii
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: (provider['services'] as List<String>? ?? []).take(3).map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF1565C0))),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                
                // Buton
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _initiateOrder(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Inițiază comanda', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MARKETPLACE SIDEBAR (fără banner galben) ====================
  Widget _buildMarketplaceSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Marketplace',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF333333)),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/marketplace'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF2DD4BF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Produse locale de la producători',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),
          
          // Products list
          SizedBox(
            height: 380,
            child: MouseRegion(
              onEnter: (_) => _marketplaceScrollTimer?.cancel(),
              onExit: (_) => _startMarketplaceAutoScroll(),
              child: ListView.builder(
                controller: _marketplaceScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _marketplaceProducts.length * 5,
                itemBuilder: (context, index) {
                  final product = _marketplaceProducts[index % _marketplaceProducts.length];
                  return _buildMarketplaceProduct(product);
                },
              ),
            ),
          ),
          
          // Buton vezi toate
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/marketplace'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF2DD4BF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Vezi toate produsele',
                  style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceProduct(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produs: ${product['name']}')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: product['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(product['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: product['image'] == null ? const Color(0xFFE8F5E9) : null,
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product['description'] ?? '',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['price'] ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2DD4BF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      child: Column(
        children: [
          _buildGoogleMap(),
          const SizedBox(height: 24),
          _buildProvidersSection(),
          const SizedBox(height: 28),
          _buildMarketplaceSidebar(),
          const SizedBox(height: 28),
          _buildCategoriesSidebar(),
        ],
      ),
    );
  }
}

