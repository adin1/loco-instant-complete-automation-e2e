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
  final ScrollController _marketplaceScrollController = ScrollController();
  final Completer<GoogleMapController> _mapController = Completer();
  
  int? _hoveredCategoryIndex;
  int _currentProviderPage = 0;
  Timer? _marketplaceScrollTimer;

  // Cluj-Napoca coordinates
  static const LatLng _clujCenter = LatLng(46.770439, 23.591423);

  // Categorii cu subcategorii (stil eMAG)
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
      'photo': 'https://randomuser.me/api/portraits/men/32.jpg',
      'motto': 'Soluții electrice rapide și sigure',
      'services': ['Instalații electrice', 'Reparații', 'Verificări'],
      'rating': 4.8,
    },
    {
      'id': '2',
      'name': 'Maria Ionescu',
      'photo': 'https://randomuser.me/api/portraits/women/44.jpg',
      'motto': 'Curățenie impecabilă, prețuri corecte',
      'services': ['Curățenie generală', 'După constructor', 'Birouri'],
      'rating': 4.9,
    },
    {
      'id': '3',
      'name': 'Vasile Mureșan',
      'photo': 'https://randomuser.me/api/portraits/men/52.jpg',
      'motto': 'Instalații și reparații non-stop',
      'services': ['Instalații sanitare', 'Desfundări', 'Centrale'],
      'rating': 4.7,
    },
    {
      'id': '4',
      'name': 'Alex Radu',
      'photo': 'https://randomuser.me/api/portraits/men/22.jpg',
      'motto': 'Reparăm orice, oricând',
      'services': ['Mobilă', 'Uși', 'Montaj IKEA'],
      'rating': 4.6,
    },
    {
      'id': '5',
      'name': 'George Transport',
      'photo': 'https://randomuser.me/api/portraits/men/45.jpg',
      'motto': 'Transport rapid în Cluj',
      'services': ['Mutări', 'Marfă', 'Curierat'],
      'rating': 4.5,
    },
    {
      'id': '6',
      'name': 'Elena Grădini',
      'photo': 'https://randomuser.me/api/portraits/women/28.jpg',
      'motto': 'Grădina ta, pasiunea noastră',
      'services': ['Gazon', 'Întreținere', 'Irigații'],
      'rating': 4.8,
    },
    // Pagina 2
    {
      'id': '7',
      'name': 'Andrei Zugrav',
      'photo': 'https://randomuser.me/api/portraits/men/55.jpg',
      'motto': 'Zugrăveli de calitate superioară',
      'services': ['Interior', 'Exterior', 'Decorative'],
      'rating': 4.9,
    },
    {
      'id': '8',
      'name': 'Mihai Acoperiș',
      'photo': 'https://randomuser.me/api/portraits/men/62.jpg',
      'motto': 'Acoperiș sigur, casă fericită',
      'services': ['Reparații', 'Țiglă', 'Hidroizolații'],
      'rating': 4.7,
    },
    {
      'id': '9',
      'name': 'Dan IT Expert',
      'photo': 'https://randomuser.me/api/portraits/men/35.jpg',
      'motto': 'Rezolvăm orice problemă IT',
      'services': ['PC', 'Laptop', 'Rețele'],
      'rating': 4.8,
    },
    {
      'id': '10',
      'name': 'Ana Curățenie Pro',
      'photo': 'https://randomuser.me/api/portraits/women/33.jpg',
      'motto': 'Strălucire garantată',
      'services': ['Apartamente', 'Case', 'Birouri'],
      'rating': 4.9,
    },
    {
      'id': '11',
      'name': 'Florin Electric',
      'photo': 'https://randomuser.me/api/portraits/men/42.jpg',
      'motto': 'Electrician autorizat ANRE',
      'services': ['Autorizat', 'Verificări', 'Avarii'],
      'rating': 4.6,
    },
    {
      'id': '12',
      'name': 'Cristina Home',
      'photo': 'https://randomuser.me/api/portraits/women/55.jpg',
      'motto': 'Casa ta în mâini bune',
      'services': ['Menaj', 'Spălat', 'Călcat'],
      'rating': 4.7,
    },
  ];

  // Produse marketplace (scroll vertical)
  final List<Map<String, dynamic>> _marketplaceProducts = [
    {'name': 'Miere de albine 100% naturală', 'description': 'Direct de la producător, 1kg', 'price': '45 RON'},
    {'name': 'Dulceață de căpșuni', 'description': 'Făcută în casă, 350g', 'price': '25 RON'},
    {'name': 'Ouă de țară proaspete', 'description': 'Găini crescute liber, 30 buc', 'price': '35 RON'},
    {'name': 'Brânză de burduf', 'description': 'Tradițională, 500g', 'price': '40 RON'},
    {'name': 'Țuică de prune', 'description': 'Artizanală, 1L', 'price': '60 RON'},
    {'name': 'Zacuscă de casă', 'description': 'Rețetă tradițională, 500g', 'price': '30 RON'},
    {'name': 'Pâine de casă', 'description': 'Cu maia naturală', 'price': '15 RON'},
    {'name': 'Gem de zmeură', 'description': 'Fără conservanți, 350g', 'price': '28 RON'},
    {'name': 'Unt de țară', 'description': 'Din lapte de vacă, 250g', 'price': '22 RON'},
    {'name': 'Smântână de casă', 'description': 'Proaspătă, 500g', 'price': '18 RON'},
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
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Caută servicii sau prestatori...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC0000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Căutare', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2DD4BF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.bolt, color: Color(0xFFCDEB45), size: 20),
        ),
        const SizedBox(width: 8),
        const Text('LOCO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFCC0000))),
        const Text(' INSTANT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2DD4BF))),
      ],
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT SIDEBAR - Categories with hover submenu
              SizedBox(width: 220, child: _buildCategoriesSidebar()),
              const SizedBox(width: 16),
              
              // CENTER - Map + Providers
              Expanded(flex: 3, child: _buildCenterContent()),
              const SizedBox(width: 16),
              
              // RIGHT SIDEBAR - MarketPlace with auto-scroll
              SizedBox(width: 280, child: _buildMarketPlaceSidebar()),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LEFT SIDEBAR - CATEGORIES WITH HOVER ====================
  Widget _buildCategoriesSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: Color(0xFFCDEB45), size: 24),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LOCO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFCC0000), height: 1)),
                    Text('INSTANT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF2DD4BF), height: 1.2)),
                  ],
                ),
              ],
            ),
          ),
          
          // Categories
          ...List.generate(_categories.length, (index) {
            return _buildCategoryItemWithSubmenu(index);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItemWithSubmenu(int index) {
    final category = _categories[index];
    final isHovered = _hoveredCategoryIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCategoryIndex = index),
      onExit: (_) => setState(() => _hoveredCategoryIndex = null),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Category item
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFFF5F5F5) : Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isHovered ? const Color(0xFFCC0000) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    category['icon'],
                    size: 16,
                    color: isHovered ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isHovered ? const Color(0xFFCC0000) : const Color(0xFF333333),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Submenu (appears on hover)
          if (isHovered)
            Positioned(
              left: 218,
              top: 0,
              child: _buildSubmenu(category['subcategories'] as List<String>),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmenu(List<String> subcategories) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subcategories.map((sub) {
          return InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selectat: $sub')),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Text(
                sub,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== CENTER CONTENT - MAP + PROVIDERS ====================
  Widget _buildCenterContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Google Maps Cluj-Napoca
          _buildGoogleMap(),
          const SizedBox(height: 16),
          
          // Search bar
          _buildSearchBar(),
          const SizedBox(height: 20),
          
          // Providers grid with arrows
          _buildProvidersSection(),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
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
          
          // Location badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: Color(0xFFCC0000), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  const Text('Cluj-Napoca', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Icon(Icons.search, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Caută servicii sau prestatori...',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC0000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Căutare', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersSection() {
    return Column(
      children: [
        // Providers grid with navigation arrows
        Row(
          children: [
            // Left arrow
            _buildNavigationArrow(Icons.chevron_left, _prevProviderPage),
            const SizedBox(width: 8),
            
            // Providers grid (3x2)
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildProviderCard(_currentProviders[0])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildProviderCard(_currentProviders[1])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildProviderCard(_currentProviders[2])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildProviderCard(_currentProviders.length > 3 ? _currentProviders[3] : {})),
                      const SizedBox(width: 12),
                      Expanded(child: _buildProviderCard(_currentProviders.length > 4 ? _currentProviders[4] : {})),
                      const SizedBox(width: 12),
                      Expanded(child: _buildProviderCard(_currentProviders.length > 5 ? _currentProviders[5] : {})),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Right arrow
            _buildNavigationArrow(Icons.chevron_right, _nextProviderPage),
          ],
        ),
        
        // Page indicator
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalPages, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
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
        width: 36,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
        ),
        child: Icon(icon, color: const Color(0xFFCC0000), size: 28),
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    if (provider.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Photo
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(provider['photo'] ?? ''),
                onBackgroundImageError: (_, __) {},
                child: provider['photo'] == null ? const Icon(Icons.person) : null,
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider['name'] ?? '',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          Text(' ${provider['rating'] ?? 0}', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Motto
                  Text(
                    provider['motto'] ?? '',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Services
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (provider['services'] as List<String>? ?? []).take(3).map((service) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCC0000),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  service,
                                  style: const TextStyle(fontSize: 9, color: Color(0xFF555555)),
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
                  
                  // Button
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Inițiază comanda', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
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

  // ==================== RIGHT SIDEBAR - MARKETPLACE AUTO-SCROLL ====================
  Widget _buildMarketPlaceSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Market Place',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
            ),
          ),
          
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Produse de casă de vânzare',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 12),
          
          // Auto-scrolling products
          SizedBox(
            height: 400,
            child: MouseRegion(
              onEnter: (_) => _marketplaceScrollTimer?.cancel(),
              onExit: (_) => _startMarketplaceAutoScroll(),
              child: ListView.builder(
                controller: _marketplaceScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _marketplaceProducts.length * 10, // Repeat for infinite scroll effect
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏠 Produse de casă',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Susține producătorii locali!',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 10),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product['description'] ?? '',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['price'] ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
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
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildProvidersSection(),
          const SizedBox(height: 24),
          _buildMarketPlaceSidebar(),
          const SizedBox(height: 24),
          _buildCategoriesSidebar(),
        ],
      ),
    );
  }
}
