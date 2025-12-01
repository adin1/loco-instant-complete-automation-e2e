import 'dart:async';
import 'package:flutter/material.dart';
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
  
  int? _hoveredCategoryIndex;
  int _currentProviderPage = 0;
  Timer? _marketplaceScrollTimer;

  // Cluj-Napoca coordinates
  static const LatLng _clujCenter = LatLng(46.770439, 23.591423);

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

  // Prestatori (6 per pagină)
  final List<Map<String, dynamic>> _allProviders = [
    {
      'id': '1',
      'name': 'Ion Popescu',
      'photo': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Soluții electrice rapide și sigure',
      'services': ['Instalații electrice', 'Reparații', 'Verificări'],
      'rating': 4.8,
    },
    {
      'id': '2',
      'name': 'Maria Ionescu',
      'photo': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Curățenie impecabilă, prețuri corecte',
      'services': ['Curățenie generală', 'După constructor', 'Birouri'],
      'rating': 4.9,
    },
    {
      'id': '3',
      'name': 'Vasile Mureșan',
      'photo': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150&h=150&fit=crop&crop=face',
      'motto': 'Instalații și reparații non-stop',
      'services': ['Instalații sanitare', 'Desfundări', 'Centrale'],
      'rating': 4.7,
    },
    {
      'id': '4',
      'name': 'Alex Radu',
      'photo': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      'motto': 'Reparăm orice, oricând',
      'services': ['Mobilă', 'Uși', 'Montaj IKEA'],
      'rating': 4.6,
    },
    {
      'id': '5',
      'name': 'George Transport',
      'photo': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Transport rapid în Cluj',
      'services': ['Mutări', 'Marfă', 'Curierat'],
      'rating': 4.5,
    },
    {
      'id': '6',
      'name': 'Elena Grădini',
      'photo': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&h=150&fit=crop&crop=face',
      'motto': 'Grădina ta, pasiunea noastră',
      'services': ['Gazon', 'Întreținere', 'Irigații'],
      'rating': 4.8,
    },
    {
      'id': '7',
      'name': 'Andrei Zugrav',
      'photo': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
      'motto': 'Zugrăveli de calitate superioară',
      'services': ['Interior', 'Exterior', 'Decorative'],
      'rating': 4.9,
    },
    {
      'id': '8',
      'name': 'Mihai Acoperiș',
      'photo': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
      'motto': 'Acoperiș sigur, casă fericită',
      'services': ['Reparații', 'Țiglă', 'Hidroizolații'],
      'rating': 4.7,
    },
    {
      'id': '9',
      'name': 'Dan IT Expert',
      'photo': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&h=150&fit=crop&crop=face',
      'motto': 'Rezolvăm orice problemă IT',
      'services': ['PC', 'Laptop', 'Rețele'],
      'rating': 4.8,
    },
    {
      'id': '10',
      'name': 'Ana Curățenie Pro',
      'photo': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop&crop=face',
      'motto': 'Strălucire garantată',
      'services': ['Apartamente', 'Case', 'Birouri'],
      'rating': 4.9,
    },
    {
      'id': '11',
      'name': 'Florin Electric',
      'photo': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
      'motto': 'Electrician autorizat ANRE',
      'services': ['Autorizat', 'Verificări', 'Avarii'],
      'rating': 4.6,
    },
    {
      'id': '12',
      'name': 'Cristina Home',
      'photo': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
      'motto': 'Casa ta în mâini bune',
      'services': ['Menaj', 'Spălat', 'Călcat'],
      'rating': 4.7,
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
    {'name': 'Pâine de casă', 'description': 'Cu maia naturală', 'price': '15 RON', 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=100&h=100&fit=crop'},
    {'name': 'Gem de zmeură', 'description': 'Fără conservanți, 350g', 'price': '28 RON', 'image': 'https://images.unsplash.com/photo-1474440692490-2e83ae13ba29?w=100&h=100&fit=crop'},
    {'name': 'Unt de țară', 'description': 'Din lapte de vacă, 250g', 'price': '22 RON', 'image': 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=100&h=100&fit=crop'},
    {'name': 'Smântână de casă', 'description': 'Proaspătă, 500g', 'price': '18 RON', 'image': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=100&h=100&fit=crop'},
  ];

  List<Map<String, dynamic>> get _currentProviders {
    final start = _currentProviderPage * 6;
    final end = (start + 6).clamp(0, _allProviders.length);
    return _allProviders.sublist(start, end);
  }

  int get _totalPages => (_allProviders.length / 6).ceil();

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

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey.shade500, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Caută servicii sau prestatori...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC0000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Căutare', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          _buildHeaderIcon(Icons.person_outline, 'Contul meu'),
          const SizedBox(width: 20),
          _buildHeaderIcon(Icons.favorite_border, 'Favorite'),
          const SizedBox(width: 20),
          _buildHeaderIcon(Icons.shopping_cart_outlined, 'Coș'),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2DD4BF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.bolt, color: Color(0xFFCDEB45), size: 24),
        ),
        const SizedBox(width: 10),
        const Text('LOCO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFCC0000))),
        const Text(' INSTANT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2DD4BF))),
      ],
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        // Main content
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT SIDEBAR - Categories
                  SizedBox(width: 240, child: _buildCategoriesSidebar()),
                  const SizedBox(width: 16),
                  
                  // CENTER - Map + Providers
                  Expanded(flex: 3, child: _buildCenterContent()),
                  const SizedBox(width: 16),
                  
                  // RIGHT SIDEBAR - Marketplace
                  SizedBox(width: 300, child: _buildMarketplaceSidebar()),
                ],
              ),
            ),
          ),
        ),
        
        // Subcategories overlay (în fața hărții)
        if (_hoveredCategoryIndex != null)
          Positioned(
            left: 272, // 240 (sidebar) + 16 (padding) + 16 (margin)
            top: 80 + (_hoveredCategoryIndex! * 56.0),
            child: _buildSubmenuOverlay(),
          ),
      ],
    );
  }

  // ==================== LEFT SIDEBAR - CATEGORIES ====================
  Widget _buildCategoriesSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt, color: Color(0xFFCDEB45), size: 28),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LOCO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFCC0000), height: 1)),
                    Text('INSTANT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2DD4BF), height: 1.2)),
                  ],
                ),
              ],
            ),
          ),
          
          // Categories
          ...List.generate(_categories.length, (index) {
            return _buildCategoryItem(index);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final category = _categories[index];
    final isHovered = _hoveredCategoryIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCategoryIndex = index),
      onExit: (_) => setState(() => _hoveredCategoryIndex = null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isHovered ? const Color(0xFFF5F5F5) : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isHovered ? const Color(0xFFCC0000) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isHovered ? const Color(0xFFCC0000) : const Color(0xFF333333),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isHovered ? const Color(0xFFCC0000) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmenuOverlay() {
    if (_hoveredCategoryIndex == null) return const SizedBox.shrink();
    
    final category = _categories[_hoveredCategoryIndex!];
    final subcategories = category['subcategories'] as List<String>;

    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() => _hoveredCategoryIndex = null),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                category['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCC0000),
                ),
              ),
            ),
            const Divider(height: 1),
            ...subcategories.map((sub) {
              return InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selectat: $sub')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF444444),
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
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _clujCenter,
              zoom: 13,
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
                markerId: MarkerId('cluj'),
                position: _clujCenter,
                infoWindow: InfoWindow(title: 'Cluj-Napoca'),
              ),
            },
          ),
          
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(color: Color(0xFFCC0000), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text('Cluj-Napoca', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(Icons.search, color: Colors.grey.shade500, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Caută servicii sau prestatori...',
                hintStyle: TextStyle(fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC0000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text('Căutare', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersSection() {
    return Column(
      children: [
        Row(
          children: [
            _buildNavigationArrow(Icons.chevron_left, _prevProviderPage),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildProviderCard(_currentProviders[0])),
                      const SizedBox(width: 16),
                      Expanded(child: _buildProviderCard(_currentProviders[1])),
                      const SizedBox(width: 16),
                      Expanded(child: _buildProviderCard(_currentProviders[2])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildProviderCard(_currentProviders.length > 3 ? _currentProviders[3] : {})),
                      const SizedBox(width: 16),
                      Expanded(child: _buildProviderCard(_currentProviders.length > 4 ? _currentProviders[4] : {})),
                      const SizedBox(width: 16),
                      Expanded(child: _buildProviderCard(_currentProviders.length > 5 ? _currentProviders[5] : {})),
                    ],
                  ),
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
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentProviderPage == index ? const Color(0xFFCC0000) : Colors.grey.shade300,
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
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Icon(icon, color: const Color(0xFFCC0000), size: 32),
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    if (provider.isEmpty) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(provider['photo'] ?? ''),
                onBackgroundImageError: (_, __) {},
                child: provider['photo'] == null ? const Icon(Icons.person, size: 32) : null,
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider['name'] ?? '',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(' ${provider['rating'] ?? 0}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  Text(
                    provider['motto'] ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (provider['services'] as List<String>? ?? []).take(3).map((service) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCC0000),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  service,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Comandă pentru ${provider['name']}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC0000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Inițiază comanda', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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

  // ==================== RIGHT SIDEBAR - MARKETPLACE ====================
  Widget _buildMarketplaceSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header cu titlu și buton căutare
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Marketplace',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF333333)),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC0000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Produse de casă de vânzare',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          
          // Products
          SizedBox(
            height: 420,
            child: MouseRegion(
              onEnter: (_) => _marketplaceScrollTimer?.cancel(),
              onExit: (_) => _startMarketplaceAutoScroll(),
              child: ListView.builder(
                controller: _marketplaceScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _marketplaceProducts.length * 10,
                itemBuilder: (context, index) {
                  final product = _marketplaceProducts[index % _marketplaceProducts.length];
                  return _buildMarketplaceProduct(product);
                },
              ),
            ),
          ),
          
          // Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏠 Produse de casă',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  'Susține producătorii locali!',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceProduct(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
            child: product['image'] == null
                ? const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 28)
                : null,
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['description'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  product['price'] ?? '',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                ),
              ],
            ),
          ),
        ],
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
