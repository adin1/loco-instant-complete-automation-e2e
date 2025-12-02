import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/animated_promo_presentation.dart';
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

    // Validare
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
    final isDesktop = screenWidth > 1000;
    final isTablet = screenWidth > 650 && screenWidth <= 1000;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F4C81), Color(0xFF1A936F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : (isTablet ? 32 : 20),
                vertical: 24,
              ),
              child: isDesktop
                  ? _buildDesktopLayout()
                  : isTablet
                      ? _buildTabletLayout()
                      : _buildMobileLayout(),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT - Split: Branding | Login Card
  // ══════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT SIDE - Branding
          Expanded(
            flex: 45,
            child: _buildBrandingSection(),
          ),
          const SizedBox(width: 80),
          // RIGHT SIDE - Login Card
          Expanded(
            flex: 55,
            child: _buildLoginCard(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TABLET LAYOUT
  // ══════════════════════════════════════════════════════════════
  Widget _buildTabletLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactBranding(),
          const SizedBox(height: 32),
          _buildLoginCard(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ══════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactBranding(),
        const SizedBox(height: 24),
        _buildLoginCard(),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BRANDING SECTION (Desktop - Left Side)
  // ══════════════════════════════════════════════════════════════
  Widget _buildBrandingSection() {
    return FadeInWidget(
      duration: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          _buildLogo(size: 72),
          const SizedBox(height: 24),
          // Title
          const Text(
            'LOCO INSTANT',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'la un pas de tine',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Description
          Text(
            'Platforma inteligentă care conectează rapid clienții cu prestatorii de servicii verificați din apropiere.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          // Features
          _buildFeatureItem(Icons.bolt, 'Comenzi în câteva secunde'),
          const SizedBox(height: 12),
          _buildFeatureItem(Icons.verified_user, 'Prestatori verificați'),
          const SizedBox(height: 12),
          _buildFeatureItem(Icons.lock_outline, 'Plăți securizate ESCROW'),
          const SizedBox(height: 12),
          _buildFeatureItem(Icons.location_on_outlined, 'Prestatori din zona ta'),
          const SizedBox(height: 32),
          // Prezentare Animată
          const AnimatedPromoPresentation(
            height: 280,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // COMPACT BRANDING (Tablet/Mobile - Top)
  // ══════════════════════════════════════════════════════════════
  Widget _buildCompactBranding() {
    return FadeInWidget(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          _buildLogo(size: 56),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'LOCO ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'INSTANT',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2DD4BF),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'la un pas de tine',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LOGO WIDGET
  // ══════════════════════════════════════════════════════════════
  Widget _buildLogo({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF2DD4BF),
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
  // LOGIN CARD - Modern Design (Stripe/Notion inspired)
  // ══════════════════════════════════════════════════════════════
  Widget _buildLoginCard() {
    return SlideInWidget(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 600),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  'Intră în cont',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Alege tipul de cont și autentifică-te',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Account Type Tabs
                _buildAccountTypeTabs(),
                const SizedBox(height: 24),
                
                // Provider Type Selection (if provider)
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
                const SizedBox(height: 18),
                
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
                const SizedBox(height: 12),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcție în dezvoltare')),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: Text(
                      'Ai uitat parola?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'sau',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
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
                        'Creează unul gratuit',
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
  // ACCOUNT TYPE TABS (Client / Prestator)
  // ══════════════════════════════════════════════════════════════
  Widget _buildAccountTypeTabs() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
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
                  color: !_isProvider ? const Color(0xFF2DD4BF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isProvider
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2DD4BF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color: !_isProvider ? Colors.white : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 15,
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
                  color: _isProvider ? const Color(0xFF2DD4BF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isProvider
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2DD4BF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handyman_outlined,
                      size: 20,
                      color: _isProvider ? Colors.white : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prestator',
                      style: TextStyle(
                        fontSize: 15,
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
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 24),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.1) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2DD4BF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF2DD4BF) : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF2DD4BF) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TEXT FIELD - Modern Design
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
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (focusNode.hasFocus)
                BoxShadow(
                  color: error != null
                      ? Colors.red.withOpacity(0.15)
                      : const Color(0xFF2DD4BF).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextFormField(
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
                color: error != null ? Colors.red.shade400 : Colors.grey.shade500,
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
              fillColor: const Color(0xFFF5F7FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: error != null
                    ? BorderSide(color: Colors.red.shade400, width: 1.5)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: error != null ? Colors.red.shade400 : const Color(0xFF2DD4BF),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: Colors.red.shade500),
              const SizedBox(width: 6),
              Text(
                error,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade500,
                  fontWeight: FontWeight.w500,
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
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2DD4BF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF2DD4BF).withOpacity(0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
