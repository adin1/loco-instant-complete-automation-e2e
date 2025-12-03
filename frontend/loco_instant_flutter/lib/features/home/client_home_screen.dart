import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> 
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _marketplaceSearchController = TextEditingController();
  final ScrollController _marketplaceScrollController = ScrollController();
  final Completer<GoogleMapController> _mapController = Completer();
  final FocusNode _searchFocusNode = FocusNode();
  
  // Animation controllers
  late AnimationController _categoryAnimController;
  late AnimationController _providerAnimController;
  late Animation<double> _categoryScaleAnimation;
  
  int? _hoveredCategoryIndex;
  int? _hoveredSubcategoryIndex;
  int? _hoveredProviderIndex;
  int _currentProviderPage = 0;
  Timer? _marketplaceScrollTimer;
  String? _selectedCategory;
  String? _selectedSubcategory;
  bool _isGettingLocation = false;
  bool _showLocationSuggestions = false;
  bool _showCategoryDropdown = false;
  String _currentLocationText = 'Cluj-Napoca';
  
  // Adrese salvate de utilizator
  List<Map<String, dynamic>> _savedAddresses = [];
  
  // Lista de sugestii pentru căutare
  List<String> _locationSuggestions = [
    '📍 Locația mea actuală',
  ];

  // Cluj-Napoca coordinates (current user location simulation)
  LatLng _userLocation = const LatLng(46.770439, 23.591423);

  // Categorii cu design modern și iconițe atractive
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.plumbing,
      'name': 'Instalator',
      'color': const Color(0xFF3B82F6),
      'gradient': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      'urgent': true,
      'emoji': '🔧',
      'subcategories': ['Urgență - scurgeri apă', 'Desfundare canalizare', 'Instalații sanitare', 'Montaj centrale termice', 'Reparații țevi', 'Instalare boiler'],
    },
    {
      'icon': Icons.electrical_services,
      'name': 'Electrician',
      'color': const Color(0xFFF59E0B),
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'urgent': true,
      'emoji': '⚡',
      'subcategories': ['Urgență - pană curent', 'Reparații prize/întrerupătoare', 'Tablouri electrice', 'Instalații electrice', 'Verificări PRAM', 'Iluminat LED'],
    },
    {
      'icon': Icons.lock,
      'name': 'Lăcătuș',
      'color': const Color(0xFFEF4444),
      'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      'urgent': true,
      'emoji': '🔐',
      'subcategories': ['Deblocare ușă - URGENȚĂ', 'Schimbare yală', 'Montaj încuietori', 'Copiere chei', 'Blindare uși'],
    },
    {
      'icon': Icons.local_shipping,
      'name': 'Transport',
      'color': const Color(0xFF8B5CF6),
      'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      'urgent': false,
      'emoji': '🚚',
      'subcategories': ['Mutări apartamente', 'Transport marfă', 'Transport mobilă', 'Curierat local', 'Transport materiale'],
    },
    {
      'icon': Icons.cleaning_services,
      'name': 'Curățenie',
      'color': const Color(0xFF10B981),
      'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      'urgent': false,
      'emoji': '✨',
      'subcategories': ['Curățenie generală', 'Curățenie după constructor', 'Curățenie birouri', 'Spălat geamuri', 'Dezinfecție'],
    },
    {
      'icon': Icons.handyman,
      'name': 'Reparații',
      'color': const Color(0xFF6366F1),
      'gradient': [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
      'urgent': false,
      'emoji': '🛠️',
      'subcategories': ['Reparații mobilă', 'Montaj mobilier IKEA', 'Reparații uși/ferestre', 'Montaj corpuri suspendate', 'Reparații diverse'],
    },
    {
      'icon': Icons.hvac,
      'name': 'Aer condiționat',
      'color': const Color(0xFF06B6D4),
      'gradient': [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
      'urgent': true,
      'emoji': '❄️',
      'subcategories': ['Montaj AC', 'Curățare/igienizare AC', 'Reparații AC', 'Încărcare freon', 'Demontare AC'],
    },
    {
      'icon': Icons.brush,
      'name': 'Zugrăveli',
      'color': const Color(0xFFEC4899),
      'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
      'urgent': false,
      'emoji': '🎨',
      'subcategories': ['Zugrăvit interior', 'Zugrăvit exterior', 'Vopsit lavabil', 'Tencuieli decorative', 'Glet și șlefuit'],
    },
    {
      'icon': Icons.computer,
      'name': 'IT & Tech',
      'color': const Color(0xFF14B8A6),
      'gradient': [const Color(0xFF14B8A6), const Color(0xFF0D9488)],
      'urgent': false,
      'emoji': '💻',
      'subcategories': ['Reparații PC/Laptop', 'Instalare software', 'Configurare rețea WiFi', 'Recuperare date', 'Service imprimante'],
    },
    {
      'icon': Icons.roofing,
      'name': 'Acoperiș',
      'color': const Color(0xFF78716C),
      'gradient': [const Color(0xFF78716C), const Color(0xFF57534E)],
      'urgent': false,
      'emoji': '🏠',
      'subcategories': ['Reparații acoperiș', 'Montaj țiglă', 'Hidroizolații', 'Jgheaburi și burlane', 'Mansardări'],
    },
  ];
  
  int? _clickedCategoryIndex; // Pentru a ține submeniul deschis la click

  // Prestatori cu coordonate pentru distanță - organizați pe categorii
  final List<Map<String, dynamic>> _allProviders = [
    // === INSTALATORI ===
    {
      'id': '1',
      'name': 'Vasile Mureșan',
      'photo': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150&h=150&fit=crop&crop=face',
      'motto': 'Instalații și reparații non-stop 24/7',
      'category': 'Instalator',
      'categoryColor': const Color(0xFF3B82F6),
      'services': ['Urgență scurgeri', 'Desfundări', 'Centrale termice'],
      'rating': 4.9,
      'reviews': 127,
      'responseTime': '15 min',
      'priceRange': '80-200 RON',
      'verified': true,
      'available': true,
      'lat': 46.772, 'lng': 23.595, 'distance': 0.3,
    },
    {
      'id': '2',
      'name': 'Florin Instalatorul',
      'photo': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
      'motto': 'Rezolvăm orice problemă de instalații',
      'category': 'Instalator',
      'categoryColor': const Color(0xFF3B82F6),
      'services': ['Instalații sanitare', 'Boilere', 'Țevi'],
      'rating': 4.7,
      'reviews': 89,
      'responseTime': '25 min',
      'priceRange': '70-180 RON',
      'verified': true,
      'available': true,
      'lat': 46.768, 'lng': 23.588, 'distance': 0.8,
    },
    // === ELECTRICIENI ===
    {
      'id': '3',
      'name': 'Ion Popescu Electric',
      'photo': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Soluții electrice rapide și sigure',
      'category': 'Electrician',
      'categoryColor': const Color(0xFFF59E0B),
      'services': ['Tablouri electrice', 'Prize/Întrerupătoare', 'LED'],
      'rating': 4.8,
      'reviews': 156,
      'responseTime': '20 min',
      'priceRange': '100-250 RON',
      'verified': true,
      'available': true,
      'lat': 46.771, 'lng': 23.592, 'distance': 0.2,
    },
    {
      'id': '4',
      'name': 'Mihai Electricianul',
      'photo': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Electrician autorizat ANRE',
      'category': 'Electrician',
      'categoryColor': const Color(0xFFF59E0B),
      'services': ['Instalații electrice', 'Verificări PRAM', 'Urgențe'],
      'rating': 4.9,
      'reviews': 203,
      'responseTime': '15 min',
      'priceRange': '90-220 RON',
      'verified': true,
      'available': false,
      'lat': 46.775, 'lng': 23.600, 'distance': 0.5,
    },
    // === LĂCĂTUȘI ===
    {
      'id': '5',
      'name': 'Andrei Lăcătușul',
      'photo': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      'motto': 'Deblocări de urgență în 15 minute!',
      'category': 'Lăcătuș',
      'categoryColor': const Color(0xFFEF4444),
      'services': ['Deblocare ușă', 'Schimbare yală', 'Blindări'],
      'rating': 4.8,
      'reviews': 312,
      'responseTime': '10 min',
      'priceRange': '100-300 RON',
      'verified': true,
      'available': true,
      'lat': 46.769, 'lng': 23.590, 'distance': 0.4,
    },
    // === CURĂȚENIE ===
    {
      'id': '6',
      'name': 'Maria Clean Pro',
      'photo': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Curățenie impecabilă, prețuri corecte',
      'category': 'Curățenie',
      'categoryColor': const Color(0xFF10B981),
      'services': ['Curățenie generală', 'După constructor', 'Birouri'],
      'rating': 4.9,
      'reviews': 245,
      'responseTime': '1 oră',
      'priceRange': '150-400 RON',
      'verified': true,
      'available': true,
      'lat': 46.768, 'lng': 23.590, 'distance': 0.5,
    },
    {
      'id': '7',
      'name': 'Clean Express',
      'photo': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=150&h=150&fit=crop&crop=face',
      'motto': 'Facem strălucitor orice spațiu',
      'category': 'Curățenie',
      'categoryColor': const Color(0xFF10B981),
      'services': ['Spălat geamuri', 'Dezinfecție', 'Mochete'],
      'rating': 4.7,
      'reviews': 178,
      'responseTime': '2 ore',
      'priceRange': '120-350 RON',
      'verified': true,
      'available': true,
      'lat': 46.762, 'lng': 23.582, 'distance': 1.2,
    },
    // === TRANSPORT ===
    {
      'id': '8',
      'name': 'George Transport Rapid',
      'photo': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Transport și mutări în Cluj-Napoca',
      'category': 'Transport',
      'categoryColor': const Color(0xFF8B5CF6),
      'services': ['Mutări apartamente', 'Transport marfă', 'Curierat'],
      'rating': 4.6,
      'reviews': 167,
      'responseTime': '30 min',
      'priceRange': '200-600 RON',
      'verified': true,
      'available': true,
      'lat': 46.775, 'lng': 23.600, 'distance': 1.5,
    },
    // === REPARAȚII ===
    {
      'id': '9',
      'name': 'Alex Reparații Casă',
      'photo': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
      'motto': 'Reparăm orice, montăm orice!',
      'category': 'Reparații',
      'categoryColor': const Color(0xFF6366F1),
      'services': ['Mobilă', 'Montaj IKEA', 'Uși/Ferestre'],
      'rating': 4.7,
      'reviews': 134,
      'responseTime': '45 min',
      'priceRange': '80-200 RON',
      'verified': true,
      'available': true,
      'lat': 46.765, 'lng': 23.588, 'distance': 1.0,
    },
    // === AER CONDIȚIONAT ===
    {
      'id': '10',
      'name': 'Clima Expert AC',
      'photo': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&h=150&fit=crop&crop=face',
      'motto': 'Montaj și service aer condiționat',
      'category': 'Aer condiționat',
      'categoryColor': const Color(0xFF06B6D4),
      'services': ['Montaj AC', 'Igienizare', 'Încărcare freon'],
      'rating': 4.8,
      'reviews': 198,
      'responseTime': '1 oră',
      'priceRange': '200-500 RON',
      'verified': true,
      'available': true,
      'lat': 46.770, 'lng': 23.598, 'distance': 0.6,
    },
    // === ZUGRĂVELI ===
    {
      'id': '11',
      'name': 'Dan Zugravu Pro',
      'photo': 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=150&h=150&fit=crop&crop=face',
      'motto': 'Zugrăveli de calitate superioară',
      'category': 'Zugrăveli',
      'categoryColor': const Color(0xFFEC4899),
      'services': ['Zugrăvit interior', 'Glet/Șlefuit', 'Decorativ'],
      'rating': 4.9,
      'reviews': 267,
      'responseTime': '1 zi',
      'priceRange': '15-25 RON/mp',
      'verified': true,
      'available': true,
      'lat': 46.773, 'lng': 23.594, 'distance': 0.7,
    },
    // === IT & TECH ===
    {
      'id': '12',
      'name': 'TechFix Reparații',
      'photo': 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=150&h=150&fit=crop&crop=face',
      'motto': 'Rezolvăm orice problemă IT',
      'category': 'IT & Tech',
      'categoryColor': const Color(0xFF14B8A6),
      'services': ['Reparații PC/Laptop', 'Rețele WiFi', 'Recuperare date'],
      'rating': 4.8,
      'reviews': 145,
      'responseTime': '30 min',
      'priceRange': '100-300 RON',
      'verified': true,
      'available': true,
      'lat': 46.766, 'lng': 23.591, 'distance': 0.9,
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
    _loadSavedAddresses();
    
    // Initialize animation controllers
    _categoryAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _providerAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _categoryScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _categoryAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _marketplaceSearchController.dispose();
    _marketplaceScrollController.dispose();
    _marketplaceScrollTimer?.cancel();
    _searchFocusNode.dispose();
    _categoryAnimController.dispose();
    _providerAnimController.dispose();
    super.dispose();
  }
  
  // Încarcă adresele salvate din SharedPreferences
  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddressesJson = prefs.getStringList('saved_addresses') ?? [];
    
    setState(() {
      _savedAddresses = [
        {'icon': Icons.home, 'name': 'Acasă', 'address': 'Str. Memorandumului 12, Cluj-Napoca', 'isDefault': true},
        {'icon': Icons.work, 'name': 'Serviciu', 'address': 'Str. Eroilor 45, Cluj-Napoca', 'isDefault': false},
      ];
      
      _locationSuggestions = [
        '📍 Locația mea actuală',
        ...(_savedAddresses.map((a) => '${a['name']}: ${a['address']}')),
        'Piața Unirii, Cluj-Napoca',
        'Mărăști, Cluj-Napoca',
        'Gheorgheni, Cluj-Napoca',
        'Mănăștur, Cluj-Napoca',
      ];
    });
  }
  
  // Salvează o adresă nouă
  Future<void> _saveAddress(String name, String address) async {
    final prefs = await SharedPreferences.getInstance();
    final newAddress = {'name': name, 'address': address, 'icon': Icons.location_on};
    
    setState(() {
      _savedAddresses.add(newAddress);
      _locationSuggestions.insert(2, '$name: $address');
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Adresa "$name" a fost salvată'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
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

  // Inițiază comandă pentru un prestator - Dialog modern
  void _initiateOrder(Map<String, dynamic> provider) {
    final categoryColor = provider['categoryColor'] as Color? ?? const Color(0xFF2DD4BF);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header cu gradient
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [categoryColor, categoryColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(provider['photo'] ?? ''),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    provider['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (provider['verified'] == true)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.verified, color: categoryColor, size: 16),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider['category'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${provider['rating']} (${provider['reviews']})',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${provider['distance']} km',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Motto
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '"${provider['motto']}"',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Info cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildOrderInfoCard(
                          Icons.schedule,
                          'Timp răspuns',
                          provider['responseTime'] ?? '',
                          categoryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOrderInfoCard(
                          Icons.payments,
                          'Estimare preț',
                          provider['priceRange'] ?? '',
                          categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Servicii
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build_circle, color: categoryColor, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Servicii disponibile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(provider['services'] as List<String>? ?? []).map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.check, size: 14, color: categoryColor),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              s,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Locație comandă
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DD4BF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on, color: Color(0xFF2DD4BF), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Locația ta',
                              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                            Text(
                              _currentLocationText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _showLocationSuggestions = true);
                        },
                        child: Text(
                          'Schimbă',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Butoane acțiune
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Row(
                    children: [
                      // Buton chat
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _openProviderChat(provider);
                          },
                          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Buton telefon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Funcție disponibilă în curând')),
                            );
                          },
                          icon: const Icon(Icons.phone_outlined, color: Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Buton comandă
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _confirmOrder(provider);
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [categoryColor, categoryColor.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flash_on, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Comandă acum',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildOrderInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  // Confirmă comanda și navighează
  void _confirmOrder(Map<String, dynamic> provider) {
    final categoryColor = provider['categoryColor'] as Color? ?? const Color(0xFF2DD4BF);
    
    // Arată loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation(categoryColor),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Se creează comanda...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Te conectăm cu ${provider['name']}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Simulează crearea comenzii
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Închide loading
      
      // Arată succes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Comandă creată cu succes!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${provider['name']} a fost notificat',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Navighează la detaliile comenzii
      context.go('/order/1'); // În producție, ar fi ID-ul real al comenzii
    });
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildLogo(iconSize: 32, fontSize: 18),
          const SizedBox(width: 24),
          
          // Selector de locație cu dropdown
          _buildLocationSelector(),
          const SizedBox(width: 16),
          
          // Căutare servicii
          Expanded(child: _buildSearchInput()),
          
          const SizedBox(width: 24),
          _buildHeaderButton(Icons.notifications_outlined, '', () => context.go('/notifications'), showBadge: true),
          const SizedBox(width: 12),
          _buildHeaderButton(Icons.history_outlined, 'Comenzi', () => context.go('/orders')),
          const SizedBox(width: 12),
          _buildHeaderButton(Icons.person_outline, 'Cont', () => _showUserMenu(context)),
        ],
      ),
    );
  }
  
  // Widget pentru selectarea locației
  Widget _buildLocationSelector() {
    return GestureDetector(
      onTap: () => setState(() => _showLocationSuggestions = !_showLocationSuggestions),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isGettingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2DD4BF)),
                  )
                : const Icon(Icons.location_on, color: Color(0xFF2DD4BF), size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Locația ta',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
                Row(
                  children: [
                    Text(
                      _currentLocationText.length > 20 
                        ? '${_currentLocationText.substring(0, 20)}...' 
                        : _currentLocationText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showLocationSuggestions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white60,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget pentru câmpul de căutare
  Widget _buildSearchInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Color(0xFF64748B), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Ce serviciu cauți? (ex: electrician, instalator...)',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _searchProvider(),
            ),
          ),
          GestureDetector(
            onTap: _searchProvider,
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(10),
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

  Widget _buildHeaderButton(IconData icon, String label, VoidCallback onTap, {bool showBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                if (showBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    
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
        
        // Subcategories overlay - deschis pe hover (ca la eMAG)
        if (_hoveredCategoryIndex != null)
          Positioned(
            left: 280,
            top: 100 + (_hoveredCategoryIndex! * 52.0),
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
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header cu titlu și buton de închidere
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DD4BF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on, color: Color(0xFF2DD4BF), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Alege locația',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showLocationSuggestions = false),
                      child: const Icon(Icons.close, color: Colors.white60, size: 22),
                    ),
                  ],
                ),
              ),
              
              // Buton detectare automată
              _buildLocationOption(
                icon: Icons.my_location,
                iconColor: const Color(0xFF2DD4BF),
                title: 'Folosește locația curentă',
                subtitle: 'Detectare automată GPS',
                isHighlighted: true,
                onTap: () {
                  setState(() => _showLocationSuggestions = false);
                  _getCurrentLocation();
                },
              ),
              
              const Divider(height: 1),
              
              // Adrese salvate
              if (_savedAddresses.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.bookmark, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        'ADRESE SALVATE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                ..._savedAddresses.map((addr) => _buildLocationOption(
                  icon: addr['icon'] as IconData? ?? Icons.location_on,
                  iconColor: addr['isDefault'] == true ? const Color(0xFF3B82F6) : Colors.grey.shade600,
                  title: addr['name'] as String,
                  subtitle: addr['address'] as String,
                  trailing: addr['isDefault'] == true 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Implicit', style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6))),
                      )
                    : null,
                  onTap: () {
                    setState(() {
                      _currentLocationText = addr['address'] as String;
                      _showLocationSuggestions = false;
                    });
                    _searchNearbyProviders();
                  },
                )),
                const Divider(height: 1),
              ],
              
              // Căutare manuală
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      'CAUTĂ ADRESĂ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Introdu adresa sau strada...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: Icon(Icons.edit_location_outlined, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _currentLocationText = value;
                        _showLocationSuggestions = false;
                      });
                      // Opțional: salvează adresa
                      _showSaveAddressDialog(value);
                    }
                  },
                ),
              ),
              
              // Zone populare
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      'ZONE POPULARE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildZoneChip('Centru'),
                    _buildZoneChip('Mărăști'),
                    _buildZoneChip('Gheorgheni'),
                    _buildZoneChip('Mănăștur'),
                    _buildZoneChip('Zorilor'),
                    _buildZoneChip('Grigorescu'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLocationOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    bool isHighlighted = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFF2DD4BF).withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildZoneChip(String zone) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentLocationText = '$zone, Cluj-Napoca';
          _showLocationSuggestions = false;
        });
        _searchNearbyProviders();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          zone,
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
      ),
    );
  }
  
  void _showSaveAddressDialog(String address) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bookmark_add, color: Color(0xFF2DD4BF)),
            SizedBox(width: 12),
            Text('Salvează adresa?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vrei să salvezi "$address" pentru acces rapid?'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nume (ex: Acasă, Birou)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nu, mulțumesc'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (nameController.text.isNotEmpty) {
                _saveAddress(nameController.text, address);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Salvează', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== CATEGORIES SIDEBAR - Design Modern Bolt/Glovo Style ====================
  Widget _buildCategoriesSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header modern
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.apps, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categorii',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Alege serviciul dorit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Quick filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('🔥 Popular', true),
                          _buildFilterChip('⚡ Urgențe', false),
                          _buildFilterChip('💰 Prețuri mici', false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Categories list cu design modern
              ...List.generate(_categories.length, (index) => _buildCategoryItemModern(index)),
              
              // Footer cu statistici
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('150+', 'Prestatori'),
                    _buildStatItem('4.8', '⭐ Rating mediu'),
                    _buildStatItem('15 min', 'Răspuns'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.white70,
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2DD4BF),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCategoryItemModern(int index) {
    final category = _categories[index];
    final isHovered = _hoveredCategoryIndex == index;
    final isUrgent = category['urgent'] == true;
    final categoryColor = category['color'] as Color;
    final gradientColors = category['gradient'] as List<Color>;
    final emoji = category['emoji'] as String;
    
    // Calculează câți prestatori sunt în această categorie
    final providerCount = _allProviders.where((p) => p['category'] == category['name']).length;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredCategoryIndex = index);
        _categoryAnimController.forward();
      },
      onExit: (_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && _hoveredCategoryIndex == index && _hoveredSubcategoryIndex == null) {
            setState(() => _hoveredCategoryIndex = null);
            _categoryAnimController.reverse();
          }
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedCategory = category['name']);
          _filterProvidersByCategory(category['name']);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHovered ? categoryColor.withOpacity(0.08) : Colors.white,
            border: Border(
              left: BorderSide(
                color: isHovered ? categoryColor : Colors.transparent,
                width: 3,
              ),
              bottom: BorderSide(color: Colors.grey.shade100),
            ),
          ),
          child: Row(
            children: [
              // Icon cu gradient sau emoji
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: isHovered 
                    ? LinearGradient(colors: gradientColors)
                    : null,
                  color: isHovered ? null : categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isHovered
                    ? Icon(category['icon'], size: 22, color: Colors.white)
                    : Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              
              // Nume și info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isHovered ? categoryColor : const Color(0xFF1E293B),
                          ),
                        ),
                        if (isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flash_on, size: 10, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  '24/7',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$providerCount prestatori disponibili',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isHovered ? categoryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isHovered ? Icons.arrow_forward : Icons.chevron_right,
                  size: 18,
                  color: isHovered ? categoryColor : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Filtrează prestatorii după categorie
  void _filterProvidersByCategory(String category) {
    final filtered = _allProviders.where((p) => p['category'] == category).toList();
    
    setState(() {
      _currentProviderPage = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${filtered.length} prestatori găsiți în "$category"'),
          ],
        ),
        backgroundColor: const Color(0xFF2DD4BF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSubmenuOverlay() {
    if (_hoveredCategoryIndex == null) return const SizedBox.shrink();
    
    final category = _categories[_hoveredCategoryIndex!];
    final subcategories = category['subcategories'] as List<String>;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSubcategoryIndex = 0),
      onExit: (_) {
        // La ieșire din submeniu, închidem totul
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _hoveredSubcategoryIndex = null;
              _hoveredCategoryIndex = null;
            });
          }
        });
      },
      child: Container(
        width: 300,
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

  // Generează markeri pentru toți prestatorii
  Set<Marker> _buildProviderMarkers() {
    final markers = <Marker>{
      // Markerul utilizatorului
      Marker(
        markerId: const MarkerId('user'),
        position: _userLocation,
        infoWindow: const InfoWindow(title: '📍 Tu ești aici'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        zIndex: 2,
      ),
    };
    
    // Adaugă markeri pentru fiecare prestator
    for (final provider in _allProviders) {
      final lat = provider['lat'] as double;
      final lng = provider['lng'] as double;
      markers.add(
        Marker(
          markerId: MarkerId('provider_${provider['id']}'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: provider['name'] as String,
            snippet: '⭐ ${provider['rating']} • ${provider['distance']} km',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () => _initiateOrder(provider),
        ),
      );
    }
    
    return markers;
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
            markers: _buildProviderMarkers(),
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
    final categoryColor = provider['categoryColor'] as Color? ?? const Color(0xFF2DD4BF);
    final isAvailable = provider['available'] == true;
    final isVerified = provider['verified'] == true;
    final providerIndex = _allProviders.indexOf(provider);
    final isHovered = _hoveredProviderIndex == providerIndex;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredProviderIndex = providerIndex),
      onExit: (_) => setState(() => _hoveredProviderIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: isHovered 
          ? (Matrix4.identity()..translate(0.0, -8.0))
          : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isHovered 
                ? categoryColor.withOpacity(0.25) 
                : Colors.black.withOpacity(0.08),
              blurRadius: isHovered ? 24 : 12,
              offset: Offset(0, isHovered ? 12 : 4),
            ),
          ],
          border: Border.all(
            color: isHovered ? categoryColor.withOpacity(0.3) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Header cu gradient dinamic bazat pe categorie
            Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categoryColor,
                    categoryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Pattern de fundal
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  
                  // Badge categorie
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        provider['category'] ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status disponibilitate
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable 
                          ? const Color(0xFF10B981) 
                          : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAvailable ? 'Activ' : 'Ocupat',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Avatar
                  Positioned(
                    bottom: -30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(provider['photo'] ?? ''),
                          onBackgroundImageError: (_, __) {},
                          child: isVerified
                            ? Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3B82F6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified, color: Colors.white, size: 14),
                                ),
                              )
                            : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
              child: Column(
                children: [
                  // Nume
                  Text(
                    provider['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  
                  // Rating, reviews și distanță
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              '${provider['rating']}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${provider['reviews']})',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                      Text(
                        '${provider['distance']} km',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Motto
                  Text(
                    provider['motto'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Info row: timp răspuns și preț
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProviderInfoItem(
                          Icons.schedule,
                          provider['responseTime'] ?? '',
                          'Răspuns',
                        ),
                        Container(width: 1, height: 24, color: Colors.grey.shade300),
                        _buildProviderInfoItem(
                          Icons.payments_outlined,
                          provider['priceRange'] ?? '',
                          'Preț',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Servicii tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: (provider['services'] as List<String>? ?? []).take(3).map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: categoryColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: categoryColor,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Butoane
                  Row(
                    children: [
                      // Buton chat
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _openProviderChat(provider),
                          icon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade600, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      // Buton comandă
                      Expanded(
                        child: GestureDetector(
                          onTap: isAvailable ? () => _initiateOrder(provider) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: isAvailable
                                ? LinearGradient(
                                    colors: [categoryColor, categoryColor.withOpacity(0.8)],
                                  )
                                : null,
                              color: isAvailable ? null : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isAvailable && isHovered
                                ? [
                                    BoxShadow(
                                      color: categoryColor.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isAvailable ? Icons.flash_on : Icons.schedule,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isAvailable ? 'Comandă acum' : 'Indisponibil',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProviderInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }
  
  // Deschide chat cu prestatorul
  void _openProviderChat(Map<String, dynamic> provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(provider['photo'] ?? ''),
            ),
            const SizedBox(width: 12),
            Text('Deschid chat cu ${provider['name']}...'),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

