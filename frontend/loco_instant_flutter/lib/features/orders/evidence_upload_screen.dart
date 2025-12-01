import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../services/backend_api_service.dart';

enum EvidenceType {
  beforeWork,
  duringWork,
  afterWork,
  testProof,
}

extension EvidenceTypeExtension on EvidenceType {
  String get apiValue {
    switch (this) {
      case EvidenceType.beforeWork:
        return 'before_work';
      case EvidenceType.duringWork:
        return 'during_work';
      case EvidenceType.afterWork:
        return 'after_work';
      case EvidenceType.testProof:
        return 'test_proof';
    }
  }

  String get displayName {
    switch (this) {
      case EvidenceType.beforeWork:
        return 'Înainte de lucrare';
      case EvidenceType.duringWork:
        return 'În timpul lucrării';
      case EvidenceType.afterWork:
        return 'După lucrare';
      case EvidenceType.testProof:
        return 'Dovadă testare';
    }
  }

  String get description {
    switch (this) {
      case EvidenceType.beforeWork:
        return 'Fotografiază starea inițială înainte de intervenție';
      case EvidenceType.duringWork:
        return 'Documentează progresul lucrării';
      case EvidenceType.afterWork:
        return 'Fotografiază rezultatul final';
      case EvidenceType.testProof:
        return 'Video cu testarea funcționalității (ex: lumina se aprinde)';
    }
  }

  IconData get icon {
    switch (this) {
      case EvidenceType.beforeWork:
        return Icons.photo_camera_back;
      case EvidenceType.duringWork:
        return Icons.construction;
      case EvidenceType.afterWork:
        return Icons.photo_camera_front;
      case EvidenceType.testProof:
        return Icons.videocam;
    }
  }

  Color get color {
    switch (this) {
      case EvidenceType.beforeWork:
        return Colors.orange;
      case EvidenceType.duringWork:
        return Colors.blue;
      case EvidenceType.afterWork:
        return Colors.green;
      case EvidenceType.testProof:
        return Colors.purple;
    }
  }
}

class EvidenceUploadScreen extends StatefulWidget {
  const EvidenceUploadScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<EvidenceUploadScreen> createState() => _EvidenceUploadScreenState();
}

class _EvidenceUploadScreenState extends State<EvidenceUploadScreen> {
  late final BackendApiService _api;
  final ImagePicker _picker = ImagePicker();
  
  List<dynamic>? _existingEvidence;
  bool _isLoading = true;
  bool _isUploading = false;

  final Map<EvidenceType, List<XFile>> _selectedFiles = {
    EvidenceType.beforeWork: [],
    EvidenceType.duringWork: [],
    EvidenceType.afterWork: [],
    EvidenceType.testProof: [],
  };

  @override
  void initState() {
    super.initState();
    final isAndroidEmulator =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final baseUrl =
        isAndroidEmulator ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    _api = BackendApiService(baseUrl: baseUrl);
    _loadExistingEvidence();
  }

  Future<void> _loadExistingEvidence() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getEvidence(widget.orderId);
      if (mounted) {
        setState(() {
          _existingEvidence = response.data as List<dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(EvidenceType type) async {
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
          _selectedFiles[type]!.addAll(files);
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

  Future<void> _pickVideo(EvidenceType type) async {
    try {
      final file = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (file != null) {
        setState(() {
          _selectedFiles[type]!.add(file);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la înregistrare: $e')),
        );
      }
    }
  }

  void _removeFile(EvidenceType type, int index) {
    setState(() {
      _selectedFiles[type]!.removeAt(index);
    });
  }

  Future<void> _uploadAll() async {
    final hasFiles = _selectedFiles.values.any((list) => list.isNotEmpty);
    if (!hasFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectează cel puțin o imagine')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      int uploaded = 0;
      int failed = 0;

      for (final entry in _selectedFiles.entries) {
        for (final file in entry.value) {
          try {
            // First get upload URL
            final uploadUrlResponse = await _api.getEvidenceUploadUrl(
              orderId: widget.orderId,
              evidenceType: entry.key.apiValue,
              mediaType: file.path.endsWith('.mp4') ? 'video' : 'image',
              fileName: file.name,
              fileSize: await file.length(),
            );

            final uploadData = uploadUrlResponse.data as Map<String, dynamic>;
            final fileUrl = uploadData['fileUrl'] as String;

            // TODO: Actually upload file to storage
            // For now, we'll just create the evidence record with a mock URL

            // Create evidence record
            await _api.createEvidence(
              orderId: widget.orderId,
              evidenceType: entry.key.apiValue,
              mediaType: file.path.endsWith('.mp4') ? 'video' : 'image',
              fileUrl: fileUrl,
            );

            uploaded++;
          } catch (e) {
            failed++;
            debugPrint('Error uploading file: $e');
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failed == 0
                  ? '✅ $uploaded fișiere încărcate cu succes!'
                  : '⚠️ $uploaded încărcate, $failed eșuate',
            ),
            backgroundColor: failed == 0 ? Colors.green : Colors.orange,
          ),
        );

        // Clear selected files and reload
        setState(() {
          for (final list in _selectedFiles.values) {
            list.clear();
          }
        });
        _loadExistingEvidence();
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
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dovezi foto/video'),
        actions: [
          if (_selectedFiles.values.any((list) => list.isNotEmpty))
            TextButton.icon(
              onPressed: _isUploading ? null : _uploadAll,
              icon: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Încarcă'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Dovezile foto/video sunt esențiale pentru a demonstra calitatea lucrării și pentru rezolvarea eventualelor dispute.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Evidence type sections
                  for (final type in EvidenceType.values) ...[
                    _buildEvidenceSection(type, isDark),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildEvidenceSection(EvidenceType type, bool isDark) {
    final existingCount = _existingEvidence
            ?.where((e) => e['evidence_type'] == type.apiValue)
            .length ??
        0;
    final selectedCount = _selectedFiles[type]!.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: type.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(type.icon, color: type.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            type.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (existingCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$existingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        type.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selected files preview
                if (selectedCount > 0) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedFiles[type]!.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: entry.value.path.endsWith('.mp4')
                                ? const Center(
                                    child: Icon(Icons.videocam, size: 32),
                                  )
                                : kIsWeb
                                    ? const Center(
                                        child: Icon(Icons.image, size: 32),
                                      )
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
                              iconSize: 20,
                              onPressed: () => _removeFile(type, entry.key),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Add buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(type),
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Adaugă foto'),
                      ),
                    ),
                    if (type == EvidenceType.testProof) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickVideo(type),
                          icon: const Icon(Icons.videocam),
                          label: const Text('Adaugă video'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

