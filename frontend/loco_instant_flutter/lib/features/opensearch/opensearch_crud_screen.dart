import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/opensearch_providers.dart';

class OpensearchCrudScreen extends ConsumerStatefulWidget {
  const OpensearchCrudScreen({super.key});

  @override
  ConsumerState<OpensearchCrudScreen> createState() => _OpensearchCrudScreenState();
}

class _OpensearchCrudScreenState extends ConsumerState<OpensearchCrudScreen> {
  final _indexController = TextEditingController(text: 'orders');
  final _idController = TextEditingController();
  final _bodyController = TextEditingController(text: '{"field": "value"}');

  // Helper: afișează snackbar cu mesaj
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _createDocument() async {
    try {
      final api = ref.read(opensearchApiServiceProvider);
      final body = jsonDecode(_bodyController.text) as Map<String, dynamic>;
      final res = await api.createDocument(
        index: _indexController.text,
        id: _idController.text,
        document: body,
      );
      ref.read(opensearchResponseProvider.notifier).state =
          jsonEncode(res.data, toEncodable: (v) => v.toString());
      _showMessage('Document created successfully!');
    } catch (e) {
      ref.read(opensearchResponseProvider.notifier).state = 'Error:\n$e';
      _showMessage('Failed to create document', isError: true);
    }
  }

  Future<void> _getDocument() async {
    try {
      final api = ref.read(opensearchApiServiceProvider);
      final res = await api.getDocument(
        index: _indexController.text,
        id: _idController.text,
      );
      ref.read(opensearchResponseProvider.notifier).state =
          jsonEncode(res.data, toEncodable: (v) => v.toString());
      _showMessage('Document retrieved successfully!');
    } catch (e) {
      ref.read(opensearchResponseProvider.notifier).state = 'Error:\n$e';
      _showMessage('Failed to retrieve document', isError: true);
    }
  }

  Future<void> _updateDocument() async {
    try {
      final api = ref.read(opensearchApiServiceProvider);
      final body = jsonDecode(_bodyController.text) as Map<String, dynamic>;
      final res = await api.updateDocument(
        index: _indexController.text,
        id: _idController.text,
        document: body,
      );
      ref.read(opensearchResponseProvider.notifier).state =
          jsonEncode(res.data, toEncodable: (v) => v.toString());
      _showMessage('Document updated successfully!');
    } catch (e) {
      ref.read(opensearchResponseProvider.notifier).state = 'Error:\n$e';
      _showMessage('Failed to update document', isError: true);
    }
  }

  Future<void> _deleteDocument() async {
    try {
      final api = ref.read(opensearchApiServiceProvider);
      final res = await api.deleteDocument(
        index: _indexController.text,
        id: _idController.text,
      );
      ref.read(opensearchResponseProvider.notifier).state =
          jsonEncode(res.data, toEncodable: (v) => v.toString());
      _showMessage('Document deleted successfully!');
    } catch (e) {
      ref.read(opensearchResponseProvider.notifier).state = 'Error:\n$e';
      _showMessage('Failed to delete document', isError: true);
    }
  }

  Future<void> _searchDocuments() async {
    try {
      final api = ref.read(opensearchApiServiceProvider);
      final body = _bodyController.text.trim().isNotEmpty
          ? jsonDecode(_bodyController.text) as Map<String, dynamic>
          : <String, dynamic>{};
      final res = await api.searchDocuments(
        index: _indexController.text,
        body: body,
      );
      ref.read(opensearchResponseProvider.notifier).state =
          jsonEncode(res.data, toEncodable: (v) => v.toString());
      _showMessage('Search completed!');
    } catch (e) {
      ref.read(opensearchResponseProvider.notifier).state = 'Error:\n$e';
      _showMessage('Search failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final response = ref.watch(opensearchResponseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('OpenSearch CRUD')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _indexController,
              decoration: const InputDecoration(labelText: 'Index name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Document ID (for get/update/delete)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Request body (JSON)'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(onPressed: _createDocument, child: const Text('Create')),
                ElevatedButton(onPressed: _getDocument, child: const Text('Get')),
                ElevatedButton(onPressed: _updateDocument, child: const Text('Update')),
                ElevatedButton(onPressed: _deleteDocument, child: const Text('Delete')),
                ElevatedButton(onPressed: _searchDocuments, child: const Text('Search')),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text('Response:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(
              response ?? '',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _indexController.dispose();
    _idController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
