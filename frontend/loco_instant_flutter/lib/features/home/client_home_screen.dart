import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  final _searchController = TextEditingController();
  int _selectedMarketplaceTab = 0;
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  // Categorii servicii
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.electrical_services, 'name': 'Electrician'},
    {'icon': Icons.plumbing, 'name': 'Instalator'},
    {'icon': Icons.cleaning_services, 'name': 'Curățenie'},
    {'icon': Icons.handyman, 'name': 'Reparații'},
    {'icon': Icons.local_shipping, 'name': 'Transport'},
    {'icon': Icons.yard, 'name': 'Grădinărit'},
    {'icon': Icons.computer, 'name': 'IT & Tech'},
    {'icon': Icons.brush, 'name': 'Zugrăveli'},
    {'icon': Icons.roofing, 'name': 'Acoperiș'},
  ];

  // Anunțuri marketplace
  final List<Map<String, dynamic>> _announcements = [
    {'title': 'iPhone 15 Pro Max', 'description': 'Nou, sigilat, garanție 2 ani'},
    {'title': 'Samsung TV 55" OLED 4K', 'description': 'Smart TV, HDR10+'},
    {'title': 'MacBook Air M3 15"', 'description': '8GB RAM, 256GB SSD'},
    {'title': 'Sony WH-1000XM5', 'description': 'Căști wireless, Noise Cancelling'},
    {'title': 'PlayStation 5 Slim', 'description': 'Edition digitală, nou'},
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients && mounted) {
        final nextPage = (_currentBannerIndex + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          _buildHeader(),
          // Main Content
          Expanded(
            child: isMobile 
                ? _buildMobileLayout() 
                : _buildDesktopLayout(isTablet),
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
          // Logo
          _buildLogo(),
          const SizedBox(width: 32),
          
          // Search bar
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF444444)),
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
                        hintText: 'Începe o nouă căutare',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC0000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          
          // Right icons
          _buildHeaderIcon(Icons.person_outline, 'Contul meu'),
          const SizedBox(width: 20),
          _buildHeaderIcon(Icons.favorite_border, 'Favorite'),
          const SizedBox(width: 20),
          _buildHeaderIcon(Icons.shopping_cart_outlined, 'Coșul meu'),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        const Text(
          'LOCO',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFFCC0000),
          ),
        ),
        const Text(
          ' INSTANT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2DD4BF),
          ),
        ),
      ],
    );
  }

  // ==================== DESKTOP LAYOUT (3 COLUMNS) ====================
  Widget _buildDesktopLayout(bool isTablet) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT SIDEBAR - 20%
              SizedBox(
                width: isTablet ? 180 : 240,
                child: _buildSidebarLeft(),
              ),
              const SizedBox(width: 20),
              
              // CENTER CONTENT - 50-60%
              Expanded(
                flex: 3,
                child: _buildMainContent(isTablet),
              ),
              const SizedBox(width: 20),
              
              // RIGHT SIDEBAR - 20-30%
              SizedBox(
                width: isTablet ? 220 : 300,
                child: _buildMarketPlaceSidebar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SIDEBAR LEFT (Logo + Categories) ====================
  Widget _buildSidebarLeft() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo/Sigla
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                    Text(
                      'LOCO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFCC0000),
                        height: 1,
                      ),
                    ),
                    Text(
                      'INSTANT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2DD4BF),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Categorii Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade50,
            child: const Text(
              'CATEGORII',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF666666),
                letterSpacing: 1,
              ),
            ),
          ),
          
          // Lista categorii
          ...List.generate(_categories.length, (index) {
            final category = _categories[index];
            return _buildCategoryItem(category['icon'], category['name']);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String name) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF666666)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ==================== MAIN CONTENT (Center Column) ====================
  Widget _buildMainContent(bool isTablet) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Harta Cluj-Napoca
          _buildMapCard(),
          const SizedBox(height: 20),
          
          // 2. Bara de căutare servicii
          _buildSearchBar(),
          const SizedBox(height: 24),
          
          // 3. Primul rând de carduri (3 coloane)
          _buildServiceCardsRow(isTablet),
          const SizedBox(height: 20),
          
          // 4. Motto + Buton Inițiază comanda
          _buildMottoSection(),
          const SizedBox(height: 20),
          
          // 5. Al doilea rând de carduri (3 coloane)
          _buildServiceCardsRow(isTablet),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Map placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Harta Cluj-Napoca',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(Google Maps – în curând)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Location badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCC0000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Cluj-Napoca',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(Icons.search, color: Colors.grey.shade500, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Caută servicii sau prestatori...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Căutare',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCardsRow(bool isTablet) {
    return Row(
      children: [
        Expanded(child: _buildServiceCard('POZĂ')),
        const SizedBox(width: 16),
        Expanded(child: _buildServiceCard('POZĂ')),
        const SizedBox(width: 16),
        Expanded(child: _buildServiceCard('POZĂ')),
      ],
    );
  }

  Widget _buildServiceCard(String label) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image, size: 28, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMottoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Motto-ul prestatorului',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Soluții rapide și profesioniste pentru casa ta. Calitate garantată.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inițiază comandă...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC0000),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Inițiază comanda',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MARKETPLACE SIDEBAR (Right Column) ====================
  Widget _buildMarketPlaceSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Market Place',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
          ),
          
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildTab('Lista anunțuri', 0),
                const SizedBox(width: 10),
                _buildTab('Căutare', 1),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Announcements list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: _announcements.map((announcement) {
                return _buildAnnouncementCard(announcement);
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          
          // Banner
          _buildBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedMarketplaceTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMarketplaceTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCC0000) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF666666),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, color: Colors.grey.shade400, size: 24),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  announcement['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 100,
      child: PageView(
        controller: _bannerController,
        onPageChanged: (index) => setState(() => _currentBannerIndex = index),
        children: [
          _buildBannerSlide(
            'Banner care rulează',
            'Cu oferte săptămânale ieși mereu pe PLUS',
            const Color(0xFF4CAF50),
          ),
          _buildBannerSlide(
            'Transport Gratuit',
            'La comenzi peste 200 RON',
            const Color(0xFF2196F3),
          ),
          _buildBannerSlide(
            'Oferte Speciale',
            'Reduceri de până la 50%',
            const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlide(String title, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
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
          // Center content first
          _buildMapCard(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 20),
          
          // Cards grid (2 columns on mobile)
          Row(
            children: [
              Expanded(child: _buildServiceCard('POZĂ')),
              const SizedBox(width: 12),
              Expanded(child: _buildServiceCard('POZĂ')),
            ],
          ),
          const SizedBox(height: 12),
          _buildServiceCard('POZĂ'),
          const SizedBox(height: 16),
          
          _buildMottoSection(),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildServiceCard('POZĂ')),
              const SizedBox(width: 12),
              Expanded(child: _buildServiceCard('POZĂ')),
            ],
          ),
          const SizedBox(height: 12),
          _buildServiceCard('POZĂ'),
          const SizedBox(height: 24),
          
          // MarketPlace
          _buildMarketPlaceSidebar(),
          const SizedBox(height: 24),
          
          // Categories
          _buildSidebarLeft(),
        ],
      ),
    );
  }
}
