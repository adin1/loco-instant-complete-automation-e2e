import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../services/backend_api_service.dart';

enum ProblemCategory {
  workNotCompleted,
  poorQuality,
  differentFromAgreed,
  damageCaused,
  noShow,
  overcharged,
  other,
}

extension ProblemCategoryExtension on ProblemCategory {
  String get apiValue {
    switch (this) {
      case ProblemCategory.workNotCompleted:
        return 'work_not_completed';
      case ProblemCategory.poorQuality:
        return 'poor_quality';
      case ProblemCategory.differentFromAgreed:
        return 'different_from_agreed';
      case ProblemCategory.damageCaused:
        return 'damage_caused';
      case ProblemCategory.noShow:
        return 'no_show';
      case ProblemCategory.overcharged:
        return 'overcharged';
      case ProblemCategory.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case ProblemCategory.workNotCompleted:
        return 'Lucrarea nu e finalizată';
      case ProblemCategory.poorQuality:
        return 'Calitate slabă';
      case ProblemCategory.differentFromAgreed:
        return 'Diferit de ce s-a agreat';
      case ProblemCategory.damageCaused:
        return 'Daune provocate';
      case ProblemCategory.noShow:
        return 'Prestatorul nu s-a prezentat';
      case ProblemCategory.overcharged:
        return 'Suprataxat';
      case ProblemCategory.other:
        return 'Altele';
    }
  }

  IconData get icon {
    switch (this) {
      case ProblemCategory.workNotCompleted:
        return Icons.pending_actions;
      case ProblemCategory.poorQuality:
        return Icons.thumb_down;
      case ProblemCategory.differentFromAgreed:
        return Icons.compare;
      case ProblemCategory.damageCaused:
        return Icons.dangerous;
      case ProblemCategory.noShow:
        return Icons.person_off;
      case ProblemCategory.overcharged:
        return Icons.money_off;
      case ProblemCategory.other:
        return Icons.help_outline;
    }
  }
}

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  late final BackendApiService _api;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  ProblemCategory? _selectedCategory;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _whatNotWorkingController = TextEditingController();
  final _technicalDetailsController = TextEditingController();
  
  final List<XFile> _evidencePhotos = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final isAndroidEmulator =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final baseUrl =
        isAndroidEmulator ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    _api = BackendApiService(baseUrl: baseUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _whatNotWorkingController.dispose();
    _technicalDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickEvidence() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cameră'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final List<XFile> files;
      if (source == ImageSource.gallery) {
        files = await _picker.pickMultiImage(imageQuality: 80);
      } else {
        final file = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );
        files = file != null ? [file] : [];
      }

      if (files.isNotEmpty) {
        setState(() {
          _evidencePhotos.addAll(files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la selectare: $e')),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _evidencePhotos.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selectează categoria problemei'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_evidencePhotos.isEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lipsesc dovezile'),
          content: const Text(
            'Nu ai încărcat nicio dovadă foto.\n\n'
            'Reclamațiile fără dovezi sunt mult mai greu de analizat și pot fi respinse.\n\n'
            'Ești sigur că vrei să continui fără dovezi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Adaugă dovezi'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Continuă fără'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload evidence photos first
      final List<String> evidenceUrls = [];
      for (final photo in _evidencePhotos) {
        try {
          // Get upload URL and upload
          final uploadUrlResponse = await _api.getEvidenceUploadUrl(
            orderId: widget.orderId,
            evidenceType: 'problem_report',
            mediaType: 'image',
            fileName: photo.name,
            fileSize: await photo.length(),
          );

          final uploadData = uploadUrlResponse.data as Map<String, dynamic>;
          evidenceUrls.add(uploadData['fileUrl'] as String);

          // Create evidence record
          await _api.createEvidence(
            orderId: widget.orderId,
            evidenceType: 'problem_report',
            mediaType: 'image',
            fileUrl: uploadData['fileUrl'] as String,
          );
        } catch (e) {
          debugPrint('Error uploading evidence: $e');
        }
      }

      // Create dispute
      await _api.createDispute(
        orderId: widget.orderId,
        category: _selectedCategory!.apiValue,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        whatNotWorking: _whatNotWorkingController.text.trim().isEmpty
            ? null
            : _whatNotWorkingController.text.trim(),
        technicalDetails: _technicalDetailsController.text.trim().isEmpty
            ? null
            : _technicalDetailsController.text.trim(),
        evidenceUrls: evidenceUrls.isEmpty ? null : evidenceUrls,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reclamația a fost înregistrată'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raportează o problemă'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber,
                        color: Colors.orange.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reclamațiile false pot duce la blocarea contului',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adaugă dovezi foto/video pentru a susține reclamația. Reclamațiile nefondate vor fi respinse.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category selection
              Text(
                'Categoria problemei *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ProblemCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    avatar: Icon(
                      category.icon,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    label: Text(category.displayName),
                    selected: isSelected,
                    selectedColor: Colors.red.shade600,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titlu scurt *',
                  hintText: 'ex: Priza nu funcționează',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introdu un titlu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descriere detaliată *',
                  hintText: 'Descrie problema cât mai detaliat...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introdu o descriere';
                  }
                  if (value.trim().length < 20) {
                    return 'Descrierea trebuie să aibă cel puțin 20 caractere';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // What's not working
              TextFormField(
                controller: _whatNotWorkingController,
                decoration: const InputDecoration(
                  labelText: 'Ce exact nu funcționează?',
                  hintText: 'ex: Întrerupătorul din dormitor, priza de lângă TV',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Technical details
              TextFormField(
                controller: _technicalDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Detalii tehnice (opțional)',
                  hintText: 'ex: Circuit 3, siguranța de 16A',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Evidence photos
              Text(
                'Dovezi foto/video *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adaugă fotografii sau video care demonstrează problema',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),

              // Photos grid
              if (_evidencePhotos.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _evidencePhotos.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: kIsWeb
                              ? const Center(child: Icon(Icons.image, size: 40))
                              : Image.file(
                                  File(entry.value.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            iconSize: 22,
                            onPressed: () => _removePhoto(entry.key),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              OutlinedButton.icon(
                onPressed: _pickEvidence,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(_evidencePhotos.isEmpty
                    ? 'Adaugă dovezi foto'
                    : 'Adaugă mai multe'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Trimite reclamația',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Info text
              Center(
                child: Text(
                  'Echipa noastră va analiza reclamația în 24-48 ore',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

