import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import '../../services/auth_service.dart';
import '../../widgets/animated_widgets.dart';
import '../../providers/provider_state.dart' show UserRole, userRoleProvider, ProviderType, providerTypeProvider;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isProvider = false;
  ProviderType? _providerType;
  late final AuthService _authService;
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
    _authService = AuthService(baseUrl: baseUrl);
    
    // Înregistrează widget-ul video pentru web
    if (kIsWeb) {
      _registerVideoElement();
    }
  }

  void _registerVideoElement() {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      'loco-promo-video',
      (int viewId) {
        final videoElement = html.VideoElement()
          ..src = 'assets/assets/videos/loco-instant-promo.mp4'
          ..poster = 'assets/assets/images/loco-instant-poster.jpg'
          ..autoplay = false
          ..loop = true
          ..muted = true
          ..controls = true
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover'
          ..style.borderRadius = '16px';
        return videoElement;
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isProvider && _providerType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te rugăm să selectezi tipul de activitate'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      
      if (_isProvider) {
        ref.read(userRoleProvider.notifier).setRole(UserRole.provider);
        ref.read(providerTypeProvider.notifier).setType(_providerType!);
        context.go('/provider');
      } else {
        ref.read(userRoleProvider.notifier).setRole(UserRole.client);
        ref.read(providerTypeProvider.notifier).clearType();
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Autentificare eșuată: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildProviderTypeCard({
    required ProviderType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ThemeData theme,
  }) {
    final isSelected = _providerType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _providerType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF22C55E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: isDesktop
                ? _buildDesktopLayout(theme)
                : _buildMobileLayout(theme),
          ),
        ),
      ),
    );
  }

  // ==================== DESKTOP LAYOUT - 2 COLOANE ====================
  Widget _buildDesktopLayout(ThemeData theme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // STÂNGA - Formular login (55%)
          Expanded(
            flex: 55,
            child: _buildLoginSection(theme),
          ),
          const SizedBox(width: 40),
          // DREAPTA - Video promo (45%)
          Expanded(
            flex: 45,
            child: _buildVideoSection(),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT - 1 COLOANĂ ====================
  Widget _buildMobileLayout(ThemeData theme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video promo sus (mai mic pe mobil)
          _buildVideoSectionMobile(),
          const SizedBox(height: 24),
          // Formular login
          _buildLoginSection(theme),
        ],
      ),
    );
  }

  // ==================== VIDEO SECTION - DESKTOP ====================
  Widget _buildVideoSection() {
    return SlideInWidget(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 800),
      offset: const Offset(50, 0),
      child: Column(
        children: [
          // Video container
          Container(
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: kIsWeb
                  ? const HtmlElementView(viewType: 'loco-promo-video')
                  : _buildVideoPlaceholder(),
            ),
          ),
          const SizedBox(height: 24),
          // Text sub video
          _buildVideoDescription(),
        ],
      ),
    );
  }

  // ==================== VIDEO SECTION - MOBILE ====================
  Widget _buildVideoSectionMobile() {
    return FadeInWidget(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: kIsWeb
                  ? const HtmlElementView(viewType: 'loco-promo-video')
                  : _buildVideoPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== VIDEO PLACEHOLDER (non-web) ====================
  Widget _buildVideoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0).withOpacity(0.8),
            const Color(0xFF2DD4BF).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          // Play button
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow,
              size: 50,
              color: Color(0xFF1565C0),
            ),
          ),
          // Text overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Vezi cum funcționează LOCO INSTANT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== VIDEO DESCRIPTION ====================
  Widget _buildVideoDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureBadge(Icons.bolt, 'Rapid'),
              const SizedBox(width: 12),
              _buildFeatureBadge(Icons.verified, 'Verificat'),
              const SizedBox(width: 12),
              _buildFeatureBadge(Icons.location_on, 'Local'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Găsește prestatori de servicii în Cluj-Napoca în câteva secunde!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber.shade400, size: 20),
              Icon(Icons.star, color: Colors.amber.shade400, size: 20),
              Icon(Icons.star, color: Colors.amber.shade400, size: 20),
              Icon(Icons.star, color: Colors.amber.shade400, size: 20),
              Icon(Icons.star_half, color: Colors.amber.shade400, size: 20),
              const SizedBox(width: 8),
              const Text(
                '4.8/5 • 1200+ recenzii',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LOGIN SECTION ====================
  Widget _buildLoginSection(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo LOCO Instant
        ScaleInWidget(
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          child: SizedBox(
            width: 80,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.location_on,
                    size: 96,
                    color: const Color(0xFF2DD4BF),
                  ),
                ),
                Positioned(
                  top: 14,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2DD4BF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      size: 36,
                      color: Color(0xFFCDEB45),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Titlu
        FadeInWidget(
          delay: const Duration(milliseconds: 300),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'LOCO',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(width: 6),
              Text(
                'INSTANT',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2DD4BF),
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        FadeInWidget(
          delay: const Duration(milliseconds: 500),
          child: const Text(
            'la un pas de tine',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Card formular
        SlideInWidget(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 600),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 16,
              shadowColor: Colors.black38,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Intră în cont',
                        textAlign: TextAlign.left,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Toggle Client / Prestator
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _isProvider = false;
                                  _providerType = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isProvider
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 18,
                                        color: !_isProvider ? Colors.white : Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Client',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: !_isProvider ? Colors.white : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isProvider = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isProvider
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.handyman,
                                        size: 18,
                                        color: _isProvider ? Colors.white : Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Prestator',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _isProvider ? Colors.white : Colors.grey,
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
                      // Sub-categorii prestator
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _isProvider 
                            ? CrossFadeState.showSecond 
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox(height: 16),
                        secondChild: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
                                    child: Text(
                                      'Selectează tipul de activitate:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  _buildProviderTypeCard(
                                    type: ProviderType.services,
                                    icon: Icons.build_circle_outlined,
                                    title: 'Prestări servicii',
                                    subtitle: 'Găsește comenzi în zona ta',
                                    color: const Color(0xFF3B82F6),
                                    theme: theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildProviderTypeCard(
                                    type: ProviderType.marketplace,
                                    icon: Icons.storefront_outlined,
                                    title: 'Marketplace',
                                    subtitle: 'Vinde prin platformă',
                                    color: const Color(0xFF10B981),
                                    theme: theme,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Introdu emailul';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Parolă',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introdu parola';
                          }
                          if (value.length < 6) {
                            return 'Minim 6 caractere';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Continuă'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Link către înregistrare
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Nu ai cont? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: Text(
                              'Creează unul',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
