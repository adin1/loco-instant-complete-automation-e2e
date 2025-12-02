import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/page_variant.dart';
import '../../providers/page_variant_provider.dart';
import '../../services/page_variant_service.dart';

/// Ecran Admin pentru gestionarea variantelor de pagini
class PageVariantsScreen extends ConsumerStatefulWidget {
  const PageVariantsScreen({super.key});

  @override
  ConsumerState<PageVariantsScreen> createState() => _PageVariantsScreenState();
}

class _PageVariantsScreenState extends ConsumerState<PageVariantsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _pageKeys = ['login', 'homepage'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pageKeys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Page Variants',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2DD4BF),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF2DD4BF),
          tabs: _pageKeys.map((key) => Tab(
            text: _getPageLabel(key),
            icon: Icon(_getPageIcon(key)),
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _pageKeys.map((key) => _PageVariantsList(pageKey: key)).toList(),
      ),
    );
  }

  String _getPageLabel(String key) {
    switch (key) {
      case 'login':
        return 'Login Page';
      case 'homepage':
        return 'Homepage';
      default:
        return key;
    }
  }

  IconData _getPageIcon(String key) {
    switch (key) {
      case 'login':
        return Icons.login;
      case 'homepage':
        return Icons.home;
      default:
        return Icons.pages;
    }
  }
}

/// Lista de variante pentru o pagină
class _PageVariantsList extends ConsumerWidget {
  final String pageKey;

  const _PageVariantsList({required this.pageKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variantsAsync = ref.watch(pageVariantNotifierProvider(pageKey));

    return Column(
      children: [
        // Header cu buton de creare
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Variante disponibile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Salvează varianta curentă'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista de variante
        Expanded(
          child: variantsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Text('Eroare: $err', style: TextStyle(color: Colors.red.shade600)),
            ),
            data: (variants) {
              if (variants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.layers_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Nicio variantă salvată',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: variants.length,
                itemBuilder: (context, index) {
                  return _VariantCard(
                    variant: variants[index],
                    pageKey: pageKey,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salvează varianta curentă'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nume variantă',
                hintText: 'ex: Login v4 - Dark theme',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descriere (opțional)',
                hintText: 'Notițe despre această variantă',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              
              final service = ref.read(pageVariantServiceProvider);
              final activeVariant = service.getActiveVariant(pageKey);
              
              if (activeVariant != null) {
                await ref.read(pageVariantNotifierProvider(pageKey).notifier)
                    .createVariant(
                      nameController.text,
                      descController.text.isNotEmpty ? descController.text : null,
                      activeVariant.config,
                    );
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Variantă salvată!'),
                  backgroundColor: Color(0xFF2DD4BF),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
            ),
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
  }
}

/// Card pentru o variantă individuală
class _VariantCard extends ConsumerWidget {
  final PageVariant variant;
  final String pageKey;

  const _VariantCard({required this.variant, required this.pageKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: variant.isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: variant.isActive
            ? const BorderSide(color: Color(0xFF2DD4BF), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon și nume
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: variant.isActive
                              ? const Color(0xFF2DD4BF).withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          variant.isActive ? Icons.check_circle : Icons.layers,
                          color: variant.isActive
                              ? const Color(0xFF2DD4BF)
                              : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              variant.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(variant.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Active badge
                if (variant.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            // Descriere
            if (variant.description != null && variant.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                variant.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            // Config preview
            const SizedBox(height: 12),
            _buildConfigPreview(),
            // Acțiuni
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!variant.isActive) ...[
                  // Set Active button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(pageVariantNotifierProvider(pageKey).notifier)
                          .activateVariant(variant.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${variant.name} este acum activ!'),
                          backgroundColor: const Color(0xFF2DD4BF),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Activează'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Preview button
                OutlinedButton.icon(
                  onPressed: () {
                    // Open preview dialog
                    _showPreviewDialog(context, ref);
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Duplicate button
                OutlinedButton.icon(
                  onPressed: () => _showDuplicateDialog(context, ref),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Duplică'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (!variant.isActive) ...[
                  const SizedBox(width: 8),
                  // Delete button
                  IconButton(
                    onPressed: () => _confirmDelete(context, ref),
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                    tooltip: 'Șterge',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigPreview() {
    final config = variant.config;
    final chips = <Widget>[];
    
    config.forEach((key, value) {
      chips.add(
        Container(
          margin: const EdgeInsets.only(right: 8, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$key: $value',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
          ),
        ),
      );
    });

    return Wrap(children: chips);
  }

  void _showPreviewDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Preview: ${variant.name}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configurație:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  variant.config.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n'),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF2DD4BF), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        variant.isActive 
                          ? 'Această variantă este deja activă. Du-te la pagină pentru a o vedea.'
                          : 'Click "Activează și vezi" pentru a aplica varianta și a vedea cum arată.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Închide'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Activează varianta dacă nu e deja activă
              if (!variant.isActive) {
                await ref.read(pageVariantNotifierProvider(pageKey).notifier)
                    .activateVariant(variant.id);
              }
              
              Navigator.pop(dialogContext); // Închide dialogul
              Navigator.pop(context); // Închide ecranul Admin
              
              // Navighează la pagină
              if (pageKey == 'login') {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              } else if (pageKey == 'homepage') {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            icon: const Icon(Icons.visibility, size: 16),
            label: Text(variant.isActive ? 'Vezi pagina' : 'Activează și vezi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showDuplicateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: '${variant.name} (copie)');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplică varianta'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nume pentru copia nouă',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              
              await ref.read(pageVariantNotifierProvider(pageKey).notifier)
                  .duplicateVariant(variant.id, nameController.text);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Variantă duplicată!'),
                  backgroundColor: Color(0xFF2DD4BF),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
            ),
            child: const Text('Duplică'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge varianta?'),
        content: Text('Ești sigur că vrei să ștergi "${variant.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(pageVariantNotifierProvider(pageKey).notifier)
                  .deleteVariant(variant.id);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Variantă ștearsă!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
  }
}

