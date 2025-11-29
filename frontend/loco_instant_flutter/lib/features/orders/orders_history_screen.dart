import 'package:flutter/material.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Date demo
  final List<_Order> _activeOrders = [
    _Order(
      id: 1,
      providerName: 'Ion Popescu - Electrician',
      service: 'Reparație priză',
      status: 'În așteptare',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      price: 150.0,
      statusColor: Colors.orange,
    ),
    _Order(
      id: 2,
      providerName: 'Maria Ionescu - Curățenie',
      service: 'Curățenie generală',
      status: 'În lucru',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      price: 200.0,
      statusColor: Colors.blue,
    ),
  ];

  final List<_Order> _completedOrders = [
    _Order(
      id: 3,
      providerName: 'Andrei Vasile - Instalator',
      service: 'Reparație robinet',
      status: 'Finalizat',
      date: DateTime.now().subtract(const Duration(days: 2)),
      price: 120.0,
      statusColor: Colors.green,
      hasReview: true,
      rating: 5,
    ),
    _Order(
      id: 4,
      providerName: 'Elena Dumitrescu - Electrician',
      service: 'Montaj lustră',
      status: 'Finalizat',
      date: DateTime.now().subtract(const Duration(days: 5)),
      price: 180.0,
      statusColor: Colors.green,
      hasReview: true,
      rating: 4,
    ),
    _Order(
      id: 5,
      providerName: 'Gheorghe Marin - Zugrav',
      service: 'Zugrăvit cameră',
      status: 'Anulat',
      date: DateTime.now().subtract(const Duration(days: 7)),
      price: 350.0,
      statusColor: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comenzile mele'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Istoric'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Active
          _activeOrders.isEmpty
              ? _EmptyState(
                  icon: Icons.hourglass_empty,
                  message: 'Nu ai comenzi active',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeOrders.length,
                  itemBuilder: (context, index) => _OrderCard(
                    order: _activeOrders[index],
                    onTap: () => _showOrderDetails(_activeOrders[index]),
                  ),
                ),

          // Tab Istoric
          _completedOrders.isEmpty
              ? _EmptyState(
                  icon: Icons.history,
                  message: 'Nu ai comenzi în istoric',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _completedOrders.length,
                  itemBuilder: (context, index) => _OrderCard(
                    order: _completedOrders[index],
                    onTap: () => _showOrderDetails(_completedOrders[index]),
                  ),
                ),
        ],
      ),
    );
  }

  void _showOrderDetails(_Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Comandă #${order.id}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.person,
                label: 'Prestator',
                value: order.providerName,
              ),
              _DetailRow(
                icon: Icons.build,
                label: 'Serviciu',
                value: order.service,
              ),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Data',
                value: _formatDate(order.date),
              ),
              _DetailRow(
                icon: Icons.attach_money,
                label: 'Preț',
                value: '${order.price.toStringAsFixed(0)} RON',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: order.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (order.hasReview && order.rating != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Rating dat: '),
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < order.rating! ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              if (order.status == 'Finalizat' && !order.hasReview)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navighează la review
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('Lasă o recenzie'),
                  ),
                ),
              if (order.status == 'În așteptare' || order.status == 'În lucru')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Anulează comanda
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Anulează comanda',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inHours < 24) {
      return 'Azi, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ieri';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _Order {
  final int id;
  final String providerName;
  final String service;
  final String status;
  final DateTime date;
  final double price;
  final Color statusColor;
  final bool hasReview;
  final int? rating;

  _Order({
    required this.id,
    required this.providerName,
    required this.service,
    required this.status,
    required this.date,
    required this.price,
    required this.statusColor,
    this.hasReview = false,
    this.rating,
  });
}

class _OrderCard extends StatelessWidget {
  final _Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.providerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: order.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.service,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.price.toStringAsFixed(0)} RON',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2DD4BF),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(order.date),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inHours < 24) {
      return 'Azi';
    } else if (diff.inDays == 1) {
      return 'Ieri';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

