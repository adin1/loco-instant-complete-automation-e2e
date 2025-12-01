import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:async';

import '../../services/backend_api_service.dart';
import '../chat/chat_screen.dart';
import 'evidence_upload_screen.dart';
import 'report_problem_screen.dart';

/// Order statuses for the full workflow
enum OrderStatus {
  draft,
  pending,
  paymentPending,
  fundsHeld,
  assigned,
  providerEnRoute,
  inProgress,
  workCompleted,
  confirmed,
  disputed,
  completed,
  cancelled,
  refunded,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.draft:
        return 'Ciornă';
      case OrderStatus.pending:
        return 'În așteptare';
      case OrderStatus.paymentPending:
        return 'Plată în curs';
      case OrderStatus.fundsHeld:
        return 'Fonduri blocate';
      case OrderStatus.assigned:
        return 'Asignat';
      case OrderStatus.providerEnRoute:
        return 'În drum';
      case OrderStatus.inProgress:
        return 'În lucru';
      case OrderStatus.workCompleted:
        return 'Finalizat (așteaptă confirmare)';
      case OrderStatus.confirmed:
        return 'Confirmat';
      case OrderStatus.disputed:
        return 'În dispută';
      case OrderStatus.completed:
        return 'Finalizat';
      case OrderStatus.cancelled:
        return 'Anulat';
      case OrderStatus.refunded:
        return 'Rambursat';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.draft:
        return Colors.grey;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paymentPending:
        return Colors.amber;
      case OrderStatus.fundsHeld:
        return Colors.blue;
      case OrderStatus.assigned:
        return Colors.indigo;
      case OrderStatus.providerEnRoute:
        return Colors.purple;
      case OrderStatus.inProgress:
        return Colors.teal;
      case OrderStatus.workCompleted:
        return Colors.cyan;
      case OrderStatus.confirmed:
        return Colors.green;
      case OrderStatus.disputed:
        return Colors.red;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.grey;
      case OrderStatus.refunded:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.draft:
        return Icons.edit_note;
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.paymentPending:
        return Icons.payment;
      case OrderStatus.fundsHeld:
        return Icons.lock;
      case OrderStatus.assigned:
        return Icons.person_add;
      case OrderStatus.providerEnRoute:
        return Icons.directions_car;
      case OrderStatus.inProgress:
        return Icons.build;
      case OrderStatus.workCompleted:
        return Icons.check_circle_outline;
      case OrderStatus.confirmed:
        return Icons.verified;
      case OrderStatus.disputed:
        return Icons.gavel;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.replay;
    }
  }
}

OrderStatus parseOrderStatus(String? status) {
  switch (status) {
    case 'draft':
      return OrderStatus.draft;
    case 'pending':
      return OrderStatus.pending;
    case 'payment_pending':
      return OrderStatus.paymentPending;
    case 'funds_held':
      return OrderStatus.fundsHeld;
    case 'assigned':
      return OrderStatus.assigned;
    case 'provider_en_route':
      return OrderStatus.providerEnRoute;
    case 'in_progress':
      return OrderStatus.inProgress;
    case 'work_completed':
      return OrderStatus.workCompleted;
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'disputed':
      return OrderStatus.disputed;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'refunded':
      return OrderStatus.refunded;
    default:
      return OrderStatus.pending;
  }
}

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final BackendApiService _api;
  Map<String, dynamic>? _order;
  List<dynamic>? _timeline;
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    final isAndroidEmulator =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final baseUrl =
        isAndroidEmulator ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    _api = BackendApiService(baseUrl: baseUrl);
    _loadOrder();

    // Auto-refresh every 30 seconds for active orders
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadOrder(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _api.getOrderById(widget.orderId);
      final timelineResponse = await _api.getOrderTimeline(widget.orderId);

      if (mounted) {
        setState(() {
          _order = response.data as Map<String, dynamic>?;
          _timeline = timelineResponse.data as List<dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  OrderStatus get _status => parseOrderStatus(_order?['status']);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comandă #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrder,
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(orderId: widget.orderId),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text('Eroare: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrder,
                        child: const Text('Reîncearcă'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrder,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
                        _buildStatusCard(isDark),
                        const SizedBox(height: 16),

                        // Payment Info (if escrow active)
                        if (_order?['payment_status'] != null)
                          _buildPaymentCard(isDark),
                        const SizedBox(height: 16),

                        // Order Details
                        _buildDetailsCard(isDark),
                        const SizedBox(height: 16),

                        // Evidence Photos
                        _buildEvidenceCard(isDark),
                        const SizedBox(height: 16),

                        // Timeline
                        _buildTimelineCard(isDark),
                        const SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButtons(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    final hoursRemaining = _order?['hours_until_release'] as num?;
    final autoReleaseAt = _order?['auto_release_at'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _status.color.withOpacity(0.8),
            _status.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _status.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_status.icon, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _status.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_status == OrderStatus.workCompleted &&
              hoursRemaining != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Plata se va elibera automat în ${hoursRemaining.round()} ore\ndacă nu confirmi sau raportezi o problemă.',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(bool isDark) {
    final paymentStatus = _order?['payment_status'];
    final totalAmount = _order?['total_amount'];
    final advanceAmount = _order?['advance_amount'];

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.payment, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Plată',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Status plată', _getPaymentStatusText(paymentStatus)),
          if (totalAmount != null)
            _buildInfoRow('Total', '${totalAmount} RON'),
          if (advanceAmount != null && advanceAmount > 0)
            _buildInfoRow('Avans plătit', '${advanceAmount} RON'),
        ],
      ),
    );
  }

  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'În așteptare';
      case 'authorized':
        return 'Pre-autorizat';
      case 'advance_paid':
        return 'Avans plătit';
      case 'fully_paid':
        return 'Plătit integral';
      case 'held':
        return '🔒 În escrow';
      case 'released':
        return '✅ Eliberat';
      case 'refunded':
        return '↩️ Rambursat';
      case 'disputed':
        return '⚠️ În dispută';
      default:
        return status ?? 'Necunoscut';
    }
  }

  Widget _buildDetailsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.teal.shade600),
              const SizedBox(width: 8),
              const Text(
                'Detalii comandă',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_order?['service_name'] != null)
            _buildInfoRow('Serviciu', _order!['service_name']),
          if (_order?['provider_name'] != null)
            _buildInfoRow('Prestator', _order!['provider_name']),
          if (_order?['provider_rating'] != null)
            _buildInfoRow(
                'Rating prestator', '⭐ ${_order!['provider_rating']}'),
          if (_order?['price_estimate'] != null)
            _buildInfoRow('Preț estimat', '${_order!['price_estimate']} RON'),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(bool isDark) {
    final evidenceSummary = _order?['evidenceSummary'] as List<dynamic>?;

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library, color: Colors.purple.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Dovezi foto/video',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EvidenceUploadScreen(orderId: widget.orderId),
                  ),
                ).then((_) => _loadOrder()),
                child: const Text('Vezi toate'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (evidenceSummary == null || evidenceSummary.isEmpty)
            Text(
              'Nu există dovezi încărcate încă',
              style: TextStyle(color: Colors.grey.shade500),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: evidenceSummary.map((e) {
                final type = e['evidence_type'] as String?;
                final count = e['count'];
                return Chip(
                  avatar: Icon(_getEvidenceIcon(type), size: 16),
                  label: Text('${_getEvidenceLabel(type)}: $count'),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  IconData _getEvidenceIcon(String? type) {
    switch (type) {
      case 'before_work':
        return Icons.photo_camera_back;
      case 'after_work':
        return Icons.photo_camera_front;
      case 'test_proof':
        return Icons.videocam;
      case 'problem_report':
        return Icons.warning;
      default:
        return Icons.image;
    }
  }

  String _getEvidenceLabel(String? type) {
    switch (type) {
      case 'before_work':
        return 'Înainte';
      case 'after_work':
        return 'După';
      case 'test_proof':
        return 'Test';
      case 'problem_report':
        return 'Problemă';
      default:
        return type ?? 'Altele';
    }
  }

  Widget _buildTimelineCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              const Text(
                'Istoric status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_timeline == null || _timeline!.isEmpty)
            const Text('Nu există istoric')
          else
            ..._timeline!.take(5).map((item) => _buildTimelineItem(item)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(dynamic item) {
    final status = parseOrderStatus(item['new_status']);
    final createdAt = DateTime.tryParse(item['created_at'] ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(status.icon, size: 14, color: status.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (createdAt != null)
                  Text(
                    _formatDateTime(createdAt),
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
    );
  }

  Widget _buildActionButtons() {
    final List<Widget> buttons = [];

    switch (_status) {
      case OrderStatus.workCompleted:
        // Customer can confirm or report problem
        buttons.add(
          ElevatedButton.icon(
            onPressed: _confirmWork,
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirmă lucrarea'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        buttons.add(const SizedBox(height: 12));
        buttons.add(
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReportProblemScreen(orderId: widget.orderId),
              ),
            ).then((_) => _loadOrder()),
            icon: const Icon(Icons.warning, color: Colors.orange),
            label: const Text(
              'Raportează o problemă',
              style: TextStyle(color: Colors.orange),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.orange),
            ),
          ),
        );
        break;

      case OrderStatus.completed:
        // Can leave review
        buttons.add(
          ElevatedButton.icon(
            onPressed: _leaveReview,
            icon: const Icon(Icons.star),
            label: const Text('Lasă o recenzie'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        break;

      case OrderStatus.disputed:
        buttons.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.gavel, color: Colors.red.shade600, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Dispută în curs de analiză',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Echipa noastră analizează cazul și te va contacta în curând.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        );
        break;

      case OrderStatus.pending:
      case OrderStatus.paymentPending:
        buttons.add(
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to payment screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecționare către plată...')),
              );
            },
            icon: const Icon(Icons.payment),
            label: const Text('Plătește acum'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        break;

      default:
        break;
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }

  Future<void> _confirmWork() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmă lucrarea'),
        content: const Text(
          'Confirmi că lucrarea a fost executată corect?\n\n'
          'După confirmare, plata va fi eliberată către prestator.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _api.confirmOrder(widget.orderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Lucrarea a fost confirmată!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadOrder();
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
      }
    }
  }

  void _leaveReview() {
    // TODO: Navigate to review screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcționalitate în dezvoltare')),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return 'acum ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'acum ${diff.inHours} ore';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}

