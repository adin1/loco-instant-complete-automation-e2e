import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _locationEnabled = true;
  String _language = 'Română';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setări'),
      ),
      body: ListView(
        children: [
          // Secțiunea Notificări
          _SectionHeader(title: 'Notificări'),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Notificări push',
            subtitle: 'Primește notificări pe dispozitiv',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
          ),
          _SettingsTile(
            icon: Icons.email,
            title: 'Notificări email',
            subtitle: 'Primește actualizări pe email',
            trailing: Switch(
              value: _emailNotifications,
              onChanged: (value) => setState(() => _emailNotifications = value),
            ),
          ),
          _SettingsTile(
            icon: Icons.sms,
            title: 'Notificări SMS',
            subtitle: 'Primește SMS pentru comenzi',
            trailing: Switch(
              value: _smsNotifications,
              onChanged: (value) => setState(() => _smsNotifications = value),
            ),
          ),
          const Divider(height: 32),

          // Secțiunea Aspect
          _SectionHeader(title: 'Aspect'),
          _buildThemeTile(),
          _SettingsTile(
            icon: Icons.language,
            title: 'Limba',
            subtitle: _language,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(height: 32),

          // Secțiunea Confidențialitate
          _SectionHeader(title: 'Confidențialitate'),
          _SettingsTile(
            icon: Icons.location_on,
            title: 'Servicii de localizare',
            subtitle: 'Permite accesul la locație',
            trailing: Switch(
              value: _locationEnabled,
              onChanged: (value) => setState(() => _locationEnabled = value),
            ),
          ),
          _SettingsTile(
            icon: Icons.lock,
            title: 'Schimbă parola',
            subtitle: 'Actualizează parola contului',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(),
          ),
          _SettingsTile(
            icon: Icons.delete_forever,
            title: 'Șterge contul',
            subtitle: 'Elimină permanent contul și datele',
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            titleColor: Colors.red,
            onTap: () => _showDeleteAccountDialog(),
          ),
          const Divider(height: 32),

          // Secțiunea Despre
          _SectionHeader(title: 'Despre'),
          _SettingsTile(
            icon: Icons.info,
            title: 'Versiunea aplicației',
            subtitle: 'v1.0.0 (Build 1)',
          ),
          _SettingsTile(
            icon: Icons.description,
            title: 'Termeni și condiții',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Politica de confidențialitate',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.help,
            title: 'Ajutor și suport',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildThemeTile() {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    
    return _SettingsTile(
      icon: isDark ? Icons.dark_mode : Icons.light_mode,
      title: 'Mod întunecat',
      subtitle: isDark ? 'Temă întunecată activă' : 'Temă luminoasă activă',
      trailing: Switch(
        value: isDark,
        onChanged: (value) {
          ref.read(themeModeProvider.notifier).toggleTheme();
        },
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selectează limba'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              language: 'Română',
              isSelected: _language == 'Română',
              onTap: () {
                setState(() => _language = 'Română');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              language: 'English',
              isSelected: _language == 'English',
              onTap: () {
                setState(() => _language = 'English');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              language: 'Magyar',
              isSelected: _language == 'Magyar',
              onTap: () {
                setState(() => _language = 'Magyar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schimbă parola'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Parola curentă',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Parola nouă',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmă parola nouă',
              ),
            ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parola a fost actualizată!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge contul'),
        content: const Text(
          'Ești sigur că vrei să ștergi contul? Această acțiune este ireversibilă și toate datele tale vor fi eliminate permanent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Șterge contul'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

