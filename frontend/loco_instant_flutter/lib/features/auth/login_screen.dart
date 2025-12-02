import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/animated_promo_presentation.dart';
import '../../providers/provider_state.dart' show UserRole, userRoleProvider, ProviderType, providerTypeProvider;
import '../admin/page_variants_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _isSubmitting = false;
  bool _isProvider = false;
  bool _obscurePassword = true;
  ProviderType? _providerType;
  String? _emailError;
  String? _passwordError;
  
  late final AuthService _authService;
  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  @override
  void initState() {
    super.initState();
    final isAndroidEmulator = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final baseUrl = _apiBaseUrlOverride.isNotEmpty
        ? _apiBaseUrlOverride
        : (isAndroidEmulator ? 'http://10.0.2.2:3000' : 'http://localhost:3000');
    _authService = AuthService(baseUrl: baseUrl);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (email.isEmpty) {
      setState(() => _emailError = 'Introdu adresa de email');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Adresă de email invalidă');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Introdu parola');
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'Parola trebuie să aibă minim 6 caractere');
      return;
    }

    if (_isProvider && _providerType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selectează tipul de activitate'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _authService.login(email: email, password: password);

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
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 1100;
    final isTablet = screenWidth > 750 && screenWidth <= 1100;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Gradient original albastru-verde
          gradient: LinearGradient(
            colors: [
              Color(0xFF1D4ED8),  // Albastru
              Color(0xFF22C55E),  // Verde
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background effects
            _buildBackgroundEffects(),
            
            // Main content
            SafeArea(
              child: isDesktop
                  ? _buildDesktopLayout(screenHeight)
                  : isTablet
                      ? _buildTabletLayout()
                      : _buildMobileLayout(),
            ),
            
            // Admin button - Page Variants
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PageVariantsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Variante',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BACKGROUND EFFECTS - Simple subtle glow
  // ══════════════════════════════════════════════════════════════
  Widget _buildBackgroundEffects() {
    return const SizedBox.shrink(); // No background effects
  }

  // ══════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT - Hero Presentation + Login
  // ══════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(double screenHeight) {
    return Row(
      children: [
        // LEFT SIDE - Hero Presentation (60%)
        Expanded(
          flex: 60,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: _buildHeroSection(maxWidth: 700, maxHeight: screenHeight * 0.85),
            ),
          ),
        ),
        // RIGHT SIDE - Login Form (40%)
        Expanded(
          flex: 40,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: _buildLoginCard(maxWidth: 400),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TABLET LAYOUT
  // ══════════════════════════════════════════════════════════════
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Logo & Title
            _buildCompactHeader(),
            const SizedBox(height: 32),
            // Presentation
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: const AnimatedPromoPresentation(height: 240),
              ),
            ),
            const SizedBox(height: 40),
            // Login Card
            _buildLoginCard(maxWidth: 420),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ══════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo & Title
            _buildCompactHeader(),
            const SizedBox(height: 24),
            // Presentation
            const AnimatedPromoPresentation(height: 200),
            const SizedBox(height: 32),
            // Login Card
            _buildLoginCard(maxWidth: double.infinity),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HERO SECTION - Desktop Left Side
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeroSection({required double maxWidth, required double maxHeight}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + Brand
            FadeInWidget(
              duration: const Duration(milliseconds: 600),
              child: Row(
                children: [
                  _buildLogo(size: 48),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'LOCO ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'INSTANT',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2DD4BF),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'la un pas de tine',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Animated Presentation - CENTERED & PROMINENT
            SlideInWidget(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 700),
              child: const AnimatedPromoPresentation(height: 220),
            ),
            
            const SizedBox(height: 20),
            
            // Trust badges
            FadeInWidget(
              delay: const Duration(milliseconds: 600),
              child: Row(
                children: [
                  _buildTrustBadge(Icons.verified_user, 'Verificat'),
                  const SizedBox(width: 20),
                  _buildTrustBadge(Icons.lock, 'ESCROW'),
                  const SizedBox(width: 20),
                  _buildTrustBadge(Icons.speed, 'Rapid'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2DD4BF), size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // COMPACT HEADER - Tablet/Mobile
  // ══════════════════════════════════════════════════════════════
  Widget _buildCompactHeader() {
    return FadeInWidget(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          _buildLogo(size: 48),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'LOCO ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'INSTANT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2DD4BF),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'la un pas de tine',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LOGO
  // ══════════════════════════════════════════════════════════════
  Widget _buildLogo({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2DD4BF), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2DD4BF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.bolt,
        size: size * 0.55,
        color: Colors.white,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LOGIN CARD - Glassmorphism style
  // ══════════════════════════════════════════════════════════════
  Widget _buildLoginCard({required double maxWidth}) {
    return SlideInWidget(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 600),
      offset: const Offset(30, 0),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const Text(
                  'Bine ai venit!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Autentifică-te pentru a continua',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                    const SizedBox(height: 28),
                    
                    // Account Type Tabs
                    _buildAccountTypeTabs(),
                    const SizedBox(height: 24),
                    
                    // Provider Type Selection
                    _buildProviderTypeSection(),
                    
                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: 'Email',
                      hint: 'nume@exemplu.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      error: _emailError,
                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Parolă',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      error: _passwordError,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: Text(
                          'Ai uitat parola?',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                    
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nu ai cont? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: const Text(
                            'Înregistrează-te',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2DD4BF),
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
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ACCOUNT TYPE TABS
  // ══════════════════════════════════════════════════════════════
  Widget _buildAccountTypeTabs() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Client Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isProvider = false;
                _providerType = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !_isProvider 
                      ? const Color(0xFF2DD4BF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: !_isProvider ? Colors.white : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !_isProvider ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Prestator Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isProvider = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isProvider 
                      ? const Color(0xFF2DD4BF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handyman_outlined,
                      size: 18,
                      color: _isProvider ? Colors.white : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Prestator',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isProvider ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PROVIDER TYPE SECTION
  // ══════════════════════════════════════════════════════════════
  Widget _buildProviderTypeSection() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: _isProvider ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tip activitate',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildProviderTypeOption(
                  type: ProviderType.services,
                  icon: Icons.build_outlined,
                  label: 'Servicii',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProviderTypeOption(
                  type: ProviderType.marketplace,
                  icon: Icons.storefront_outlined,
                  label: 'Marketplace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProviderTypeOption({
    required ProviderType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _providerType == type;
    return GestureDetector(
      onTap: () => setState(() => _providerType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF2DD4BF).withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF2DD4BF)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? const Color(0xFF2DD4BF)
                  : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? const Color(0xFF2DD4BF)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TEXT FIELD - Light theme
  // ══════════════════════════════════════════════════════════════
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? error,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: isPassword && _obscurePassword,
          textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: error != null 
                  ? Colors.red.shade400 
                  : Colors.grey.shade500,
              size: 20,
            ),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null 
                    ? Colors.red.shade400 
                    : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null 
                    ? Colors.red.shade400 
                    : const Color(0xFF2DD4BF),
                width: 2,
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: Colors.red.shade400),
              const SizedBox(width: 6),
              Text(
                error,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SUBMIT BUTTON
  // ══════════════════════════════════════════════════════════════
  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2DD4BF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF2DD4BF).withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Continuă',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
