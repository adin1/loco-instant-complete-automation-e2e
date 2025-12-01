import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  // Cluj-Napoca coordinates (current user location simulation)
  static const LatLng _userLocation = LatLng(46.770439, 23.591423);

  // Categorii cu subcategorii
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.electrical_services,
      'name': 'Electrician',
      'subcategories': ['Instalații electrice', 'Reparații prize', 'Tablouri electrice', 'Verificări PRAM', 'Iluminat LED'],
    },
    {
      'icon': Icons.plumbing,
      'name': 'Instalator',
      'subcategories': ['Instalații sanitare', 'Desfundare canalizare', 'Montaj centrale', 'Reparații țevi', 'Instalare boiler'],
    },
    {
      'icon': Icons.cleaning_services,
      'name': 'Curățenie',
      'subcategories': ['Curățenie generală', 'Curățenie după constructor', 'Curățenie birouri', 'Spălat geamuri', 'Dezinfecție'],
    },
    {
      'icon': Icons.handyman,
      'name': 'Reparații',
      'subcategories': ['Reparații mobilă', 'Montaj mobilier', 'Reparații uși', 'Reparații diverse', 'Asamblare IKEA'],
    },
    {
      'icon': Icons.local_shipping,
      'name': 'Transport',
      'subcategories': ['Transport marfă', 'Mutări apartamente', 'Transport mobilă', 'Curierat local', 'Transport materiale'],
    },
    {
      'icon': Icons.yard,
      'name': 'Grădinărit',
      'subcategories': ['Tuns gazon', 'Întreținere grădină', 'Tăiat copaci', 'Plantat flori', 'Sistem irigații'],
    },
    {
      'icon': Icons.brush,
      'name': 'Zugrăveli',
      'subcategories': ['Zugrăvit interior', 'Zugrăvit exterior', 'Vopsit lavabil', 'Tencuieli decorative', 'Glet și șlefuit'],
    },
    {
      'icon': Icons.roofing,
      'name': 'Acoperiș',
      'subcategories': ['Reparații acoperiș', 'Montaj țiglă', 'Hidroizolații', 'Jgheaburi și burlane', 'Mansardări'],
    },
    {
      'icon': Icons.computer,
      'name': 'IT & Tech',
      'subcategories': ['Reparații PC', 'Instalare software', 'Configurare rețea', 'Recuperare date', 'Service laptop'],
    },
  ];

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
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
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
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Colors.white70, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Caută servicii sau prestatori...',
                        hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Căutare',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          _buildHeaderButton(Icons.person_outline, 'Cont', () => context.go('/profile')),
          const SizedBox(width: 16),
          _buildHeaderButton(Icons.history, 'Comenzi', () => context.go('/orders')),
        ],
      ),
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
    return Stack(
      children: [
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
        
        // Subcategories overlay
        if (_hoveredCategoryIndex != null)
          Positioned(
            left: 280,
            top: 100 + (_hoveredCategoryIndex! * 52.0),
            child: _buildSubmenuOverlay(),
          ),
      ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo în sidebar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF2DD4BF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(child: _buildLogo(iconSize: 28, fontSize: 16)),
          ),
          
          // Categories list
          ...List.generate(_categories.length, (index) => _buildCategoryItem(index)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final category = _categories[index];
    final isHovered = _hoveredCategoryIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCategoryIndex = index),
      onExit: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_hoveredSubcategoryIndex == null && mounted) {
            setState(() => _hoveredCategoryIndex = null);
          }
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _hoveredCategoryIndex = _hoveredCategoryIndex == index ? null : index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFFF0F9FF) : Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isHovered ? const Color(0xFF2DD4BF) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category['icon'],
                  size: 20,
                  color: isHovered ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isHovered ? const Color(0xFF1565C0) : const Color(0xFF333333),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isHovered ? const Color(0xFF2DD4BF) : Colors.grey.shade400,
              ),
            ],
          ),
        ),
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
        setState(() {
          _hoveredSubcategoryIndex = null;
          _hoveredCategoryIndex = null;
        });
      },
      child: Container(
        width: 260,
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
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildProvidersSection(),
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
            initialCameraPosition: const CameraPosition(
              target: _userLocation,
              zoom: 14,
            ),
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            markers: {
              const Marker(
                markerId: MarkerId('user'),
                position: _userLocation,
                infoWindow: InfoWindow(title: 'Tu ești aici'),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGoogleMap(),
          const SizedBox(height: 20),
          _buildSearchBar(),
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

