import 'package:flutter/material.dart';

/// Model pentru filtrele de căutare
class SearchFilters {
  final double? maxDistance; // km
  final double? minRating;
  final double? maxPrice;
  final double? minPrice;
  final List<String> categories;
  final bool onlyInstant;
  final bool onlyAvailable;
  final SortOption sortBy;

  const SearchFilters({
    this.maxDistance,
    this.minRating,
    this.maxPrice,
    this.minPrice,
    this.categories = const [],
    this.onlyInstant = false,
    this.onlyAvailable = true,
    this.sortBy = SortOption.distance,
  });

  SearchFilters copyWith({
    double? maxDistance,
    double? minRating,
    double? maxPrice,
    double? minPrice,
    List<String>? categories,
    bool? onlyInstant,
    bool? onlyAvailable,
    SortOption? sortBy,
  }) {
    return SearchFilters(
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      categories: categories ?? this.categories,
      onlyInstant: onlyInstant ?? this.onlyInstant,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Verifică dacă sunt aplicate filtre
  bool get hasActiveFilters =>
      maxDistance != null ||
      minRating != null ||
      maxPrice != null ||
      minPrice != null ||
      categories.isNotEmpty ||
      onlyInstant ||
      sortBy != SortOption.distance;
}

enum SortOption {
  distance,
  rating,
  priceAsc,
  priceDesc,
  name,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.distance:
        return 'Distanță';
      case SortOption.rating:
        return 'Rating';
      case SortOption.priceAsc:
        return 'Preț (crescător)';
      case SortOption.priceDesc:
        return 'Preț (descrescător)';
      case SortOption.name:
        return 'Nume';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.distance:
        return Icons.near_me;
      case SortOption.rating:
        return Icons.star;
      case SortOption.priceAsc:
        return Icons.arrow_upward;
      case SortOption.priceDesc:
        return Icons.arrow_downward;
      case SortOption.name:
        return Icons.sort_by_alpha;
    }
  }
}

/// Bottom sheet pentru filtre avansate
class AdvancedSearchFiltersSheet extends StatefulWidget {
  final SearchFilters initialFilters;
  final List<String> availableCategories;
  final void Function(SearchFilters) onApply;

  const AdvancedSearchFiltersSheet({
    super.key,
    required this.initialFilters,
    required this.availableCategories,
    required this.onApply,
  });

  @override
  State<AdvancedSearchFiltersSheet> createState() =>
      _AdvancedSearchFiltersSheetState();
}

class _AdvancedSearchFiltersSheetState
    extends State<AdvancedSearchFiltersSheet> {
  late SearchFilters _filters;
  late double _distanceSlider;
  late double _ratingSlider;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _distanceSlider = _filters.maxDistance ?? 10;
    _ratingSlider = _filters.minRating ?? 0;
    _priceRange = RangeValues(
      _filters.minPrice ?? 0,
      _filters.maxPrice ?? 500,
    );
  }

  void _resetFilters() {
    setState(() {
      _filters = const SearchFilters();
      _distanceSlider = 10;
      _ratingSlider = 0;
      _priceRange = const RangeValues(0, 500);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtre avansate',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Resetează'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Distanță maximă
              _buildSectionTitle('Distanță maximă', Icons.near_me),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _distanceSlider,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_distanceSlider.toInt()} km',
                      onChanged: (value) {
                        setState(() {
                          _distanceSlider = value;
                          _filters = _filters.copyWith(maxDistance: value);
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_distanceSlider.toInt()} km',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Rating minim
              _buildSectionTitle('Rating minim', Icons.star),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _ratingSlider,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _ratingSlider == 0
                          ? 'Orice'
                          : '${_ratingSlider.toStringAsFixed(1)}+',
                      onChanged: (value) {
                        setState(() {
                          _ratingSlider = value;
                          _filters = _filters.copyWith(
                            minRating: value > 0 ? value : null,
                          );
                        });
                      },
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return Icon(
                        _ratingSlider >= starValue
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Interval de preț
              _buildSectionTitle('Interval de preț (RON)', Icons.payments),
              const SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 500,
                divisions: 50,
                labels: RangeLabels(
                  '${_priceRange.start.toInt()} RON',
                  '${_priceRange.end.toInt()} RON',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                    _filters = _filters.copyWith(
                      minPrice: values.start > 0 ? values.start : null,
                      maxPrice: values.end < 500 ? values.end : null,
                    );
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_priceRange.start.toInt()} RON',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${_priceRange.end.toInt()} RON',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Categorii
              if (widget.availableCategories.isNotEmpty) ...[
                _buildSectionTitle('Categorii', Icons.category),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.availableCategories.map((category) {
                    final isSelected = _filters.categories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          final newCategories =
                              List<String>.from(_filters.categories);
                          if (selected) {
                            newCategories.add(category);
                          } else {
                            newCategories.remove(category);
                          }
                          _filters =
                              _filters.copyWith(categories: newCategories);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Opțiuni rapide
              _buildSectionTitle('Opțiuni', Icons.tune),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Doar servicii instant'),
                subtitle: const Text('Disponibili imediat'),
                value: _filters.onlyInstant,
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(onlyInstant: value);
                  });
                },
                secondary: const Icon(Icons.flash_on, color: Colors.amber),
              ),
              SwitchListTile(
                title: const Text('Doar disponibili'),
                subtitle: const Text('Filtrează prestatorii ocupați'),
                value: _filters.onlyAvailable,
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(onlyAvailable: value);
                  });
                },
                secondary: const Icon(Icons.check_circle_outline,
                    color: Colors.green),
              ),
              const SizedBox(height: 20),

              // Sortare
              _buildSectionTitle('Sortare', Icons.sort),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SortOption.values.map((option) {
                  final isSelected = _filters.sortBy == option;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(option.icon, size: 16),
                        const SizedBox(width: 4),
                        Text(option.label),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filters = _filters.copyWith(sortBy: option);
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Butoane acțiune
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Anulează'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_filters);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check),
                          const SizedBox(width: 8),
                          const Text('Aplică filtre'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// Chip-uri active pentru filtrele aplicate
class ActiveFiltersChips extends StatelessWidget {
  final SearchFilters filters;
  final VoidCallback onClearAll;
  final void Function(SearchFilters) onRemoveFilter;

  const ActiveFiltersChips({
    super.key,
    required this.filters,
    required this.onClearAll,
    required this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (!filters.hasActiveFilters) return const SizedBox.shrink();

    final chips = <Widget>[];

    if (filters.maxDistance != null) {
      chips.add(_buildChip(
        context,
        '< ${filters.maxDistance!.toInt()} km',
        Icons.near_me,
        () => onRemoveFilter(filters.copyWith(maxDistance: null)),
      ));
    }

    if (filters.minRating != null) {
      chips.add(_buildChip(
        context,
        '${filters.minRating!.toStringAsFixed(1)}+ ⭐',
        Icons.star,
        () => onRemoveFilter(filters.copyWith(minRating: null)),
      ));
    }

    if (filters.minPrice != null || filters.maxPrice != null) {
      final priceText =
          '${filters.minPrice?.toInt() ?? 0}-${filters.maxPrice?.toInt() ?? '∞'} RON';
      chips.add(_buildChip(
        context,
        priceText,
        Icons.payments,
        () => onRemoveFilter(filters.copyWith(minPrice: null, maxPrice: null)),
      ));
    }

    if (filters.onlyInstant) {
      chips.add(_buildChip(
        context,
        'Instant',
        Icons.flash_on,
        () => onRemoveFilter(filters.copyWith(onlyInstant: false)),
      ));
    }

    for (final category in filters.categories) {
      chips.add(_buildChip(
        context,
        category,
        Icons.category,
        () {
          final newCategories = List<String>.from(filters.categories)
            ..remove(category);
          onRemoveFilter(filters.copyWith(categories: newCategories));
        },
      ));
    }

    if (filters.sortBy != SortOption.distance) {
      chips.add(_buildChip(
        context,
        filters.sortBy.label,
        filters.sortBy.icon,
        () => onRemoveFilter(filters.copyWith(sortBy: SortOption.distance)),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...chips,
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onClearAll,
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Șterge tot'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onRemove,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

