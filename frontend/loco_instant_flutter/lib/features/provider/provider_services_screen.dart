import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/provider_service.dart';
import '../../providers/provider_state.dart';
import '../../widgets/animated_widgets.dart';

class ProviderServicesScreen extends ConsumerStatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  ConsumerState<ProviderServicesScreen> createState() =>
      _ProviderServicesScreenState();
}

class _ProviderServicesScreenState
    extends ConsumerState<ProviderServicesScreen> {
  @override
  void initState() {
    super.initState();
    // Inițializează cu servicii demo dacă nu există
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDemoServices();
    });
  }

  void _initDemoServices() {
    final profile = ref.read(providerProfileProvider);
    if (profile == null) {
      // Creează un profil demo
      ref.read(providerProfileProvider.notifier).setProfile(
            ProviderProfile(
              id: '1',
              name: 'Ion Popescu',
              email: 'ion@loco-instant.ro',
              phone: '+40 721 234 567',
              rating: 4.8,
              isAvailable: true,
              isVerified: true,
              categories: ['transport', 'livrare'],
              services: [
                ProviderServiceItem(
                  id: '1',
                  name: 'Transport local',
                  description: 'Transport în oraș și împrejurimi',
                  price: 25.0,
                  durationMinutes: 30,
                  isActive: true,
                  category: 'transport',
                ),
                ProviderServiceItem(
                  id: '2',
                  name: 'Transport aeroport',
                  description: 'Transfer la/de la aeroportul Cluj',
                  price: 80.0,
                  durationMinutes: 45,
                  isActive: true,
                  category: 'transport',
                ),
                ProviderServiceItem(
                  id: '3',
                  name: 'Livrare colete',
                  description: 'Livrare rapidă în Cluj-Napoca',
                  price: 15.0,
                  durationMinutes: 30,
                  isActive: false,
                  category: 'livrare',
                ),
              ],
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(providerProfileProvider);
    final services = profile?.services ?? [];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeServices = services.where((s) => s.isActive).length;
    final inactiveServices = services.where((s) => !s.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviciile mele'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(),
          ),
        ],
      ),
      body: services.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistici
                  SlideInWidget(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Active',
                            activeServices.toString(),
                            Icons.check_circle,
                            Colors.green,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Inactive',
                            inactiveServices.toString(),
                            Icons.pause_circle,
                            Colors.grey,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            services.length.toString(),
                            Icons.list,
                            theme.colorScheme.primary,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categorii
                  SlideInWidget(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Categorii',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SlideInWidget(
                    delay: const Duration(milliseconds: 150),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ServiceCategories.all.map((category) {
                        final isSelected =
                            profile?.categories.contains(category.id) ?? false;
                        return FilterChip(
                          label: Text('${category.icon} ${category.name}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            final categories =
                                List<String>.from(profile?.categories ?? []);
                            if (selected) {
                              categories.add(category.id);
                            } else {
                              categories.remove(category.id);
                            }
                            ref
                                .read(providerProfileProvider.notifier)
                                .updateCategories(categories);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lista servicii
                  SlideInWidget(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Servicii oferite',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...services.asMap().entries.map((entry) {
                    return SlideInWidget(
                      delay: Duration(milliseconds: 250 + entry.key * 50),
                      child: _buildServiceCard(entry.value, isDark),
                    );
                  }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Adaugă serviciu'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Nu ai servicii adăugate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adaugă serviciile pe care le oferi pentru a primi comenzi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddServiceDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Adaugă primul serviciu'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ProviderServiceItem service, bool isDark) {
    final theme = Theme.of(context);
    final category = ServiceCategories.all.firstWhere(
      (c) => c.id == service.category,
      orElse: () => const ServiceCategory(id: 'altele', name: 'Altele', icon: '📋'),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: service.isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: service.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.isActive ? 'Activ' : 'Inactiv',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: service.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${service.durationMinutes} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.category, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editează'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  onTap: () => _showEditServiceDialog(service),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      service.isActive ? Icons.pause : Icons.play_arrow,
                    ),
                    title: Text(service.isActive ? 'Dezactivează' : 'Activează'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  onTap: () {
                    ref
                        .read(providerProfileProvider.notifier)
                        .toggleServiceActive(service.id);
                  },
                ),
                PopupMenuItem(
                  child: const ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Șterge', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  onTap: () => _confirmDeleteService(service),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Switch(
                      value: service.isActive,
                      onChanged: (value) {
                        ref
                            .read(providerProfileProvider.notifier)
                            .toggleServiceActive(service.id);
                      },
                      activeColor: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.isActive ? 'Disponibil' : 'Indisponibil',
                      style: TextStyle(
                        fontSize: 13,
                        color: service.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${service.price.toStringAsFixed(0)} ${service.currency}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog() {
    _showServiceDialog(null);
  }

  void _showEditServiceDialog(ProviderServiceItem service) {
    _showServiceDialog(service);
  }

  void _showServiceDialog(ProviderServiceItem? existingService) {
    final isEditing = existingService != null;
    final nameController = TextEditingController(text: existingService?.name);
    final descController =
        TextEditingController(text: existingService?.description);
    final priceController =
        TextEditingController(text: existingService?.price.toString());
    final durationController =
        TextEditingController(text: existingService?.durationMinutes.toString());
    String selectedCategory = existingService?.category ?? 'transport';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    isEditing ? 'Editează serviciu' : 'Adaugă serviciu nou',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Nume serviciu
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nume serviciu *',
                      hintText: 'ex: Transport local',
                      prefixIcon: Icon(Icons.build),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descriere
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descriere',
                      hintText: 'Descrie serviciul oferit',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categorie
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categorie',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: ServiceCategories.all.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text('${category.icon} ${category.name}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Preț și durată
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Preț (RON) *',
                            hintText: '0',
                            prefixIcon: Icon(Icons.payments),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Durată (min)',
                            hintText: '60',
                            prefixIcon: Icon(Icons.timer),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Butoane
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Anulează'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final price =
                                double.tryParse(priceController.text) ?? 0;

                            if (name.isEmpty || price <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Completează numele și prețul serviciului'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final service = ProviderServiceItem(
                              id: existingService?.id ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              name: name,
                              description: descController.text.trim().isNotEmpty
                                  ? descController.text.trim()
                                  : null,
                              price: price,
                              durationMinutes:
                                  int.tryParse(durationController.text) ?? 60,
                              isActive: existingService?.isActive ?? true,
                              category: selectedCategory,
                            );

                            if (isEditing) {
                              ref
                                  .read(providerProfileProvider.notifier)
                                  .updateService(service);
                            } else {
                              ref
                                  .read(providerProfileProvider.notifier)
                                  .addService(service);
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEditing
                                    ? 'Serviciu actualizat!'
                                    : 'Serviciu adăugat!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child:
                              Text(isEditing ? 'Salvează' : 'Adaugă serviciu'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteService(ProviderServiceItem service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge serviciu'),
        content: Text(
            'Ești sigur că vrei să ștergi serviciul "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(providerProfileProvider.notifier)
                  .removeService(service.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Serviciu șters'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
  }
}

