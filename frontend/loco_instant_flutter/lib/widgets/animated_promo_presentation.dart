import 'dart:async';
import 'package:flutter/material.dart';

/// Prezentare animată cu beneficiile LOCO INSTANT
/// Auto-advancement între slide-uri cu animații elegante
class AnimatedPromoPresentation extends StatefulWidget {
  final double? height;
  final BorderRadius? borderRadius;

  const AnimatedPromoPresentation({
    super.key,
    this.height,
    this.borderRadius,
  });

  @override
  State<AnimatedPromoPresentation> createState() => _AnimatedPromoPresentationState();
}

class _AnimatedPromoPresentationState extends State<AnimatedPromoPresentation>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;
  
  static const _slideDuration = Duration(seconds: 5);
  static const _animationDuration = Duration(milliseconds: 600);

  final List<_SlideData> _slides = [
    // Slide 1: Intro
    _SlideData(
      gradient: [Color(0xFF0F172A), Color(0xFF1E40AF), Color(0xFF2DD4BF)],
      icon: Icons.bolt,
      title: 'LOCO INSTANT',
      subtitle: 'Servicii la un click distanță',
      description: 'Platforma care conectează rapid clienții cu prestatorii de servicii verificați din orașul tău',
      features: [],
      badge: '🚀 NOU',
    ),
    // Slide 2: Beneficii Client
    _SlideData(
      gradient: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF06B6D4)],
      icon: Icons.person,
      title: 'Pentru CLIENȚI',
      subtitle: 'Comandă în siguranță',
      description: '',
      features: [
        _Feature(Icons.flash_on, 'Comandă în câteva secunde'),
        _Feature(Icons.verified_user, 'Prestatori verificați și evaluați'),
        _Feature(Icons.lock, 'Plată sigură cu sistem ESCROW'),
        _Feature(Icons.support_agent, 'Suport dedicat 24/7'),
      ],
      highlight: '💰 Banii sunt blocați până la finalizarea lucrării!',
      badge: '⭐ RECOMANDAT',
    ),
    // Slide 3: Beneficii Prestator
    _SlideData(
      gradient: [Color(0xFF064E3B), Color(0xFF10B981), Color(0xFF34D399)],
      icon: Icons.handyman,
      title: 'Pentru PRESTATORI',
      subtitle: 'Crește-ți afacerea',
      description: '',
      features: [
        _Feature(Icons.notifications_active, 'Primești comenzi instant'),
        _Feature(Icons.schedule, 'Tu îți setezi programul'),
        _Feature(Icons.payments, 'Plată garantată la finalizare'),
        _Feature(Icons.trending_up, 'Profil public cu recenzii'),
      ],
      highlight: '📈 Crește-ți vizibilitatea în oraș!',
      badge: '💼 PENTRU AFACERI',
    ),
    // Slide 4: ESCROW Security
    _SlideData(
      gradient: [Color(0xFF581C87), Color(0xFF8B5CF6), Color(0xFFA855F7)],
      icon: Icons.security,
      title: 'Sistem ESCROW',
      subtitle: '100% Protecție Garantată',
      description: 'Banii sunt ținuți în siguranță până când lucrarea este finalizată și confirmată de client',
      features: [
        _Feature(Icons.shield, 'Clientul este protejat'),
        _Feature(Icons.account_balance_wallet, 'Prestatorul primește plata garantat'),
        _Feature(Icons.gavel, 'Mediere în caz de dispută'),
      ],
      highlight: '🔒 Zero riscuri pentru ambele părți!',
      badge: '🛡️ SECURIZAT',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: _slideDuration,
    );
    
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _progressController.forward();
    _autoAdvanceTimer = Timer.periodic(_slideDuration, (_) {
      _nextPage();
    });
  }

  void _nextPage() {
    final nextPage = (_currentPage + 1) % _slides.length;
    _pageController.animateToPage(
      nextPage,
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
    );
    setState(() => _currentPage = nextPage);
    _progressController.reset();
    _progressController.forward();
  }

  void _goToPage(int page) {
    _autoAdvanceTimer?.cancel();
    _pageController.animateToPage(
      page,
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
    );
    setState(() => _currentPage = page);
    _progressController.reset();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 420;
    final isCompact = height < 300;
    
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(isCompact ? 16 : 24),
      child: Container(
        height: height,
      child: Stack(
        children: [
          // Slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              _progressController.reset();
              _progressController.forward();
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) => _buildSlide(_slides[index], index, isCompact: isCompact),
          ),
          
          // Progress indicators
          Positioned(
            bottom: isCompact ? 12 : 20,
            left: 0,
            right: 0,
            child: _buildProgressIndicators(isCompact: isCompact),
          ),
          
          // Navigation arrows
          Positioned(
            left: isCompact ? 6 : 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavButton(
                icon: Icons.chevron_left,
                onTap: () => _goToPage((_currentPage - 1 + _slides.length) % _slides.length),
                isCompact: isCompact,
              ),
            ),
          ),
          Positioned(
            right: isCompact ? 6 : 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavButton(
                icon: Icons.chevron_right,
                onTap: () => _goToPage((_currentPage + 1) % _slides.length),
                isCompact: isCompact,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSlide(_SlideData slide, int index, {bool isCompact = false}) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        
        return Transform.scale(
          scale: Curves.easeOut.transform(value),
          child: Opacity(
            opacity: Curves.easeOut.transform(value),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: slide.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: slide.gradient.length == 3 
              ? const [0.0, 0.5, 1.0] 
              : null,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Badge în colț (only on larger sizes)
            if (slide.badge != null && !isCompact)
              Positioned(
                top: 16,
                right: 60,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    slide.badge!,
                    style: TextStyle(
                      color: slide.gradient.last,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            
            // Content - responsive padding - TEXT CENTRAT
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 35 : 50, 
                    vertical: isCompact ? 8 : 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center, // Centrare pe orizontală
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  // Icon cu efect de glow
                  Container(
                    width: isCompact ? 36 : 64,
                    height: isCompact ? 36 : 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: isCompact ? null : [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(slide.icon, color: Colors.white, size: isCompact ? 18 : 32),
                  ),
                  SizedBox(height: isCompact ? 6 : 16),
                  
                  // Title cu shadow pentru lizibilitate
                  Text(
                    slide.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isCompact ? 16 : 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: isCompact ? 0.3 : 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Subtitle
                  if (slide.subtitle.isNotEmpty) ...[
                    SizedBox(height: isCompact ? 3 : 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 8 : 16, 
                        vertical: isCompact ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        slide.subtitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 10 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  
                  // Description - only show on non-compact or first slide
                  if (slide.description.isNotEmpty && (!isCompact || slide.features.isEmpty)) ...[
                    SizedBox(height: isCompact ? 6 : 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 16),
                      child: Text(
                        slide.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: isCompact ? 10 : 14,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: isCompact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  
                  // Features - responsive (show only 1 in compact mode) - CENTRAT
                  if (slide.features.isNotEmpty) ...[
                    SizedBox(height: isCompact ? 6 : 18),
                    ...slide.features.take(isCompact ? 1 : 4).map((feature) => Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: isCompact ? 1 : 5),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 6 : 12, 
                            vertical: isCompact ? 3 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(isCompact ? 2 : 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(feature.icon, color: Colors.white, size: isCompact ? 10 : 16),
                              ),
                              SizedBox(width: isCompact ? 4 : 10),
                              Text(
                                feature.text,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isCompact ? 9 : 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                  
                    // Highlight - only on larger sizes
                    if (slide.highlight != null && !isCompact) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          slide.highlight!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicators({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 16, 
        vertical: isCompact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_slides.length, (index) {
          final isActive = index == _currentPage;
          return GestureDetector(
            onTap: () => _goToPage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: isCompact ? 3 : 4),
              width: isActive ? (isCompact ? 20 : 32) : (isCompact ? 6 : 10),
              height: isCompact ? 6 : 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isCompact ? 3 : 5),
                color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: isCompact ? 4 : 8,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: isActive
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(isCompact ? 3 : 5),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(isCompact ? 3 : 5),
                                ),
                              ),
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressController.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(isCompact ? 3 : 5),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon, 
    required VoidCallback onTap,
    bool isCompact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCompact ? 28 : 40,
        height: isCompact ? 28 : 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isCompact ? 4 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: isCompact ? 16 : 24),
      ),
    );
  }
}

// Data classes
class _SlideData {
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<_Feature> features;
  final String? highlight;
  final String? badge;

  const _SlideData({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    this.highlight,
    this.badge,
  });
}

class _Feature {
  final IconData icon;
  final String text;

  const _Feature(this.icon, this.text);
}

// Animated widgets
class _AnimatedIcon extends StatefulWidget {
  final IconData icon;
  final int delay;

  const _AnimatedIcon({required this.icon, required this.delay});

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: Colors.white, size: 30),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int delay;
  final TextAlign textAlign;

  const _AnimatedText({
    required this.text,
    required this.style,
    required this.delay,
    this.textAlign = TextAlign.center,
  });

  @override
  State<_AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<_AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Text(
              widget.text,
              style: widget.style,
              textAlign: widget.textAlign,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedFeatureRow extends StatefulWidget {
  final _Feature feature;
  final int delay;

  const _AnimatedFeatureRow({required this.feature, required this.delay});

  @override
  State<_AnimatedFeatureRow> createState() => _AnimatedFeatureRowState();
}

class _AnimatedFeatureRowState extends State<_AnimatedFeatureRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.feature.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.feature.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedHighlight extends StatefulWidget {
  final String text;
  final int delay;

  const _AnimatedHighlight({required this.text, required this.delay});

  @override
  State<_AnimatedHighlight> createState() => _AnimatedHighlightState();
}

class _AnimatedHighlightState extends State<_AnimatedHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

