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
      gradient: [Color(0xFF1565C0), Color(0xFF2DD4BF)],
      icon: Icons.bolt,
      title: 'LOCO INSTANT',
      subtitle: 'la un pas de tine',
      description: 'Platforma care conectează rapid clienții cu prestatorii de servicii verificați',
      features: [],
    ),
    // Slide 2: Beneficii Client
    _SlideData(
      gradient: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      icon: Icons.person,
      title: 'Pentru CLIENȚI',
      subtitle: 'Comandă în siguranță',
      description: '',
      features: [
        _Feature(Icons.bolt, 'Comandă în câteva secunde'),
        _Feature(Icons.verified_user, 'Prestatori verificați'),
        _Feature(Icons.lock, 'Plată sigură ESCROW'),
      ],
      highlight: 'Banii sunt blocați până la finalizarea lucrării!',
    ),
    // Slide 3: Beneficii Prestator
    _SlideData(
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
      icon: Icons.handyman,
      title: 'Pentru PRESTATORI',
      subtitle: 'Crește-ți afacerea',
      description: '',
      features: [
        _Feature(Icons.notifications_active, 'Comenzi instant'),
        _Feature(Icons.schedule, 'Fără negocieri'),
        _Feature(Icons.payments, 'Plată garantată'),
        _Feature(Icons.star, 'Profil & recenzii'),
      ],
      highlight: 'Vizibilitate crescută în oraș!',
    ),
    // Slide 4: ESCROW Security
    _SlideData(
      gradient: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      icon: Icons.security,
      title: 'Sistem ESCROW',
      subtitle: 'Protecție maximă',
      description: 'Banii sunt ținuți în siguranță până când lucrarea este finalizată și confirmată',
      features: [
        _Feature(Icons.check_circle, 'Client protejat'),
        _Feature(Icons.check_circle, 'Prestator plătit garantat'),
      ],
      highlight: 'Zero riscuri pentru ambele părți!',
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
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
      child: Container(
        height: widget.height ?? 320,
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
            itemBuilder: (context, index) => _buildSlide(_slides[index], index),
          ),
          
          // Progress indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildProgressIndicators(),
          ),
          
          // Navigation arrows
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavButton(
                icon: Icons.chevron_left,
                onTap: () => _goToPage((_currentPage - 1 + _slides.length) % _slides.length),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavButton(
                icon: Icons.chevron_right,
                onTap: () => _goToPage((_currentPage + 1) % _slides.length),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSlide(_SlideData slide, int index) {
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
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(slide.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              
              // Title
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              // Subtitle
              if (slide.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  slide.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              // Description
              if (slide.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  slide.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Features - show only first 3
              if (slide.features.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...slide.features.take(3).map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(feature.icon, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        feature.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              
              // Highlight
              if (slide.highlight != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    slide.highlight!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
            ),
            child: isActive
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
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

  const _SlideData({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    this.highlight,
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

