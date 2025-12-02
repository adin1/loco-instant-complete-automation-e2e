import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum pentru versiunile de design disponibile
enum DesignVersion {
  v1_gradientClassic,    // Gradient albastru-verde original
  v2_darkLinear,         // Dark theme inspirat de Linear/Vercel
  v3_lightStripe,        // Light theme inspirat de Stripe
}

/// Provider pentru versiunea de design curentă
class DesignVersionManager extends ChangeNotifier {
  static final DesignVersionManager _instance = DesignVersionManager._internal();
  factory DesignVersionManager() => _instance;
  DesignVersionManager._internal();

  DesignVersion _currentVersion = DesignVersion.v1_gradientClassic;
  DesignVersion get currentVersion => _currentVersion;

  Future<void> loadSavedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('design_version') ?? 0;
    _currentVersion = DesignVersion.values[savedIndex.clamp(0, DesignVersion.values.length - 1)];
    notifyListeners();
  }

  Future<void> setVersion(DesignVersion version) async {
    _currentVersion = version;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('design_version', version.index);
    notifyListeners();
  }
}

/// Widget pentru selectarea versiunii de design
class VersionSelectorButton extends StatelessWidget {
  const VersionSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showVersionSelector(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.palette_outlined, color: Colors.white.withOpacity(0.8), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Design',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVersionSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const VersionSelectorSheet(),
    );
  }
}

/// Bottom sheet cu opțiunile de design
class VersionSelectorSheet extends StatefulWidget {
  const VersionSelectorSheet({super.key});

  @override
  State<VersionSelectorSheet> createState() => _VersionSelectorSheetState();
}

class _VersionSelectorSheetState extends State<VersionSelectorSheet> {
  final _manager = DesignVersionManager();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          const Text(
            'Selectează Designul',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alege varianta care îți place',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildVersionOption(
                  version: DesignVersion.v1_gradientClassic,
                  title: 'Gradient Classic',
                  subtitle: 'Fundal albastru-verde, card alb',
                  colors: [Color(0xFF1D4ED8), Color(0xFF22C55E)],
                  icon: Icons.gradient,
                ),
                const SizedBox(height: 12),
                _buildVersionOption(
                  version: DesignVersion.v2_darkLinear,
                  title: 'Dark Modern',
                  subtitle: 'Stil Linear/Vercel, glassmorphism',
                  colors: [Color(0xFF0A0A0F), Color(0xFF161B22)],
                  icon: Icons.dark_mode,
                ),
                const SizedBox(height: 12),
                _buildVersionOption(
                  version: DesignVersion.v3_lightStripe,
                  title: 'Light Stripe',
                  subtitle: 'Fundal deschis, clean & minimal',
                  colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                  icon: Icons.light_mode,
                  textDark: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVersionOption({
    required DesignVersion version,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required IconData icon,
    bool textDark = false,
  }) {
    final isSelected = _manager.currentVersion == version;
    
    return GestureDetector(
      onTap: () async {
        await _manager.setVersion(version);
        setState(() {});
        if (mounted) {
          Navigator.pop(context);
          // Trigger rebuild of the login screen
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2DD4BF) : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2DD4BF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (textDark ? Colors.black : Colors.white).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: textDark ? Colors.black87 : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textDark ? Colors.black87 : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: (textDark ? Colors.black : Colors.white).withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF2DD4BF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

/// Configurație pentru fiecare versiune de design
class DesignConfig {
  final Gradient backgroundGradient;
  final Color cardBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final bool isDark;

  const DesignConfig({
    required this.backgroundGradient,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.isDark,
  });

  static DesignConfig forVersion(DesignVersion version) {
    switch (version) {
      case DesignVersion.v1_gradientClassic:
        return const DesignConfig(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF22C55E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          cardBackground: Colors.white,
          textPrimary: Color(0xFF1A1A2E),
          textSecondary: Color(0xFF6B7280),
          accent: Color(0xFF2DD4BF),
          isDark: false,
        );
      case DesignVersion.v2_darkLinear:
        return const DesignConfig(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF0D1117), Color(0xFF161B22)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardBackground: Color(0x0DFFFFFF),
          textPrimary: Colors.white,
          textSecondary: Color(0x99FFFFFF),
          accent: Color(0xFF2DD4BF),
          isDark: true,
        );
      case DesignVersion.v3_lightStripe:
        return const DesignConfig(
          backgroundGradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardBackground: Colors.white,
          textPrimary: Color(0xFF0F172A),
          textSecondary: Color(0xFF64748B),
          accent: Color(0xFF0EA5E9),
          isDark: false,
        );
    }
  }
}

