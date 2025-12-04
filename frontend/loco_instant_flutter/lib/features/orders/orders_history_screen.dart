import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0;

  // Date demo
  final List<_Order> _activeOrders = [
    _Order(
      id: 1,
      providerName: 'Ion Popescu',
      providerPhoto: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150&h=150&fit=crop&crop=face',
      category: 'Electrician',
      service: 'Reparație priză',
      status: 'În așteptare',
      statusIcon: Icons.hourglass_top,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      price: 150.0,
      statusColor: const Color(0xFFF59E0B),
      address: 'Str. Memorandumului 12, Cluj-Napoca',
    ),
    _Order(
      id: 2,
      providerName: 'Maria Ionescu',
      providerPhoto: 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=150&h=150&fit=crop&crop=face',
      category: 'Curățenie',
      service: 'Curățenie generală',
      status: 'În lucru',
      statusIcon: Icons.build,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      price: 200.0,
      statusColor: const Color(0xFF3B82F6),
      address: 'Str. Eroilor 45, Cluj-Napoca',
      estimatedTime: '30 min rămase',
    ),
  ];

  final List<_Order> _completedOrders = [
    _Order(
      id: 3,
      providerName: 'Andrei Vasile',
      providerPhoto: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150&h=150&fit=crop&crop=face',
      category: 'Instalator',
      service: 'Reparație robinet',
      status: 'Finalizat',
      statusIcon: Icons.check_circle,
      date: DateTime.now().subtract(const Duration(days: 2)),
      price: 120.0,
      statusColor: const Color(0xFF10B981),
      hasReview: true,
      rating: 5,
      address: 'Str. Clinicilor 8, Cluj-Napoca',
    ),
    _Order(
      id: 4,
      providerName: 'Elena Dumitrescu',
      providerPhoto: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=150&h=150&fit=crop&crop=face',
      category: 'Electrician',
      service: 'Montaj lustră',
      status: 'Finalizat',
      statusIcon: Icons.check_circle,
      date: DateTime.now().subtract(const Duration(days: 5)),
      price: 180.0,
      statusColor: const Color(0xFF10B981),
      hasReview: true,
      rating: 4,
      address: 'Bd. 21 Decembrie 56, Cluj-Napoca',
    ),
    _Order(
      id: 5,
      providerName: 'Gheorghe Marin',
      providerPhoto: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=150&h=150&fit=crop&crop=face',
      category: 'Zugrăveli',
      service: 'Zugrăvit cameră',
      status: 'Anulat',
      statusIcon: Icons.cancel,
      date: DateTime.now().subtract(const Duration(days: 7)),
      price: 350.0,
      statusColor: const Color(0xFFEF4444),
      address: 'Str. Plopilor 23, Cluj-Napoca',
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Active
                _buildOrdersList(_activeOrders, isEmpty: _activeOrders.isEmpty),
                // Tab Istoric
                _buildOrdersList(_completedOrders, isEmpty: _completedOrders.isEmpty),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comenzile mele',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Gestionează și urmărește comenzile',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, color: Color(0xFF2DD4BF), size: 22),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Statistici rapide
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${_activeOrders.length}', 'Active', const Color(0xFF3B82F6)),
                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                  _buildStatItem('${_completedOrders.where((o) => o.status == 'Finalizat').length}', 'Finalizate', const Color(0xFF10B981)),
                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                  _buildStatItem('${(_activeOrders.fold(0.0, (sum, o) => sum + o.price) + _completedOrders.fold(0.0, (sum, o) => sum + o.price)).toStringAsFixed(0)}', 'RON Total', const Color(0xFFF59E0B)),
                ],
              ),
            ),
            
            // Tab bar modern
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pending_actions, size: 18),
                        const SizedBox(width: 8),
                        const Text('Active'),
                        if (_activeOrders.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_activeOrders.length}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 18),
                        const SizedBox(width: 8),
                        const Text('Istoric'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_completedOrders.length}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<_Order> orders, {required bool isEmpty}) {
    if (isEmpty) {
      return _EmptyState(
        icon: orders == _activeOrders ? Icons.pending_actions : Icons.history,
        message: orders == _activeOrders ? 'Nu ai comenzi active' : 'Nu ai comenzi în istoric',
        subtitle: orders == _activeOrders 
          ? 'Caută un prestator și plasează prima comandă'
          : 'Comenzile finalizate vor apărea aici',
        actionText: orders == _activeOrders ? 'Caută prestatori' : null,
        onAction: orders == _activeOrders ? () => context.go('/') : null,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _OrderCard(
        order: orders[index],
        onTap: () => _showOrderDetails(orders[index]),
        onChat: () => _openChat(orders[index]),
        onCancel: orders[index].status == 'În așteptare' ? () => _cancelOrder(orders[index]) : null,
        onReview: orders[index].status == 'Finalizat' && !orders[index].hasReview ? () => _addReview(orders[index]) : null,
        onReorder: orders[index].status == 'Finalizat' ? () => _reorder(orders[index]) : null,
      ),
    );
  }
  
  void _showOrderDetails(_Order order) {
    context.go('/order/${order.id}');
  }
  
  void _openChat(_Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(order.providerPhoto),
            ),
            const SizedBox(width: 12),
            Text('Deschid chat cu ${order.providerName}...'),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  void _cancelOrder(_Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber, color: Color(0xFFEF4444)),
            ),
            const SizedBox(width: 12),
            const Text('Anulare comandă'),
          ],
        ),
        content: Text('Ești sigur că vrei să anulezi comanda pentru "${order.service}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Nu', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comanda a fost anulată'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Da, anulează', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _addReview(_Order order) {
    context.go('/review/${order.id}');
  }
  
  void _reorder(_Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.replay, color: Colors.white),
            const SizedBox(width: 12),
            Text('Se recreează comanda pentru ${order.service}...'),
          ],
        ),
        backgroundColor: const Color(0xFF2DD4BF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _Order {
  final int id;
  final String providerName;
  final String providerPhoto;
  final String category;
  final String service;
  final String status;
  final IconData statusIcon;
  final DateTime date;
  final double price;
  final Color statusColor;
  final String address;
  final bool hasReview;
  final int? rating;
  final String? estimatedTime;

  _Order({
    required this.id,
    required this.providerName,
    required this.providerPhoto,
    required this.category,
    required this.service,
    required this.status,
    required this.statusIcon,
    required this.date,
    required this.price,
    required this.statusColor,
    required this.address,
    this.hasReview = false,
    this.rating,
    this.estimatedTime,
  });
}

class _OrderCard extends StatelessWidget {
  final _Order order;
  final VoidCallback onTap;
  final VoidCallback? onChat;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;
  final VoidCallback? onReorder;

  const _OrderCard({
    required this.order,
    required this.onTap,
    this.onChat,
    this.onCancel,
    this.onReview,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header cu status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [order.statusColor, order.statusColor.withOpacity(0.8)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(order.statusIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (order.estimatedTime != null)
                        Text(
                          order.estimatedTime!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#${order.id.toString().padLeft(4, '0')}',
                    style: TextStyle(
                      color: order.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Prestator info
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: order.statusColor.withOpacity(0.3), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(order.providerPhoto),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.providerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: order.statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    order.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: order.statusColor,
                                    ),
                                  ),
                                ),
                                if (order.hasReview && order.rating != null) ...[
                                  const SizedBox(width: 8),
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      i < order.rating! ? Icons.star : Icons.star_border,
                                      size: 14,
                                      color: const Color(0xFFF59E0B),
                                    )),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${order.price.toStringAsFixed(0)} RON',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF2DD4BF),
                            ),
                          ),
                          Text(
                            _formatDate(order.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Serviciu și adresă
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.handyman, size: 18, color: Colors.grey.shade500),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                order.service,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade500),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                order.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Butoane acțiuni
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onChat != null)
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: 'Chat',
                            onTap: onChat!,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      if (onCancel != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.close,
                            label: 'Anulează',
                            onTap: onCancel!,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                      if (onReview != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.star_outline,
                            label: 'Recenzie',
                            onTap: onReview!,
                            color: const Color(0xFFF59E0B),
                            isPrimary: true,
                          ),
                        ),
                      ],
                      if (onReorder != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.replay,
                            label: 'Recomandă',
                            onTap: onReorder!,
                            color: const Color(0xFF2DD4BF),
                            isPrimary: true,
                          ),
                        ),
                      ],
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.arrow_forward,
                          label: 'Detalii',
                          onTap: onTap,
                          color: const Color(0xFF2DD4BF),
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 60) {
      return 'Acum ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Acum ${diff.inHours} ore';
    } else if (diff.inDays == 1) {
      return 'Ieri';
    } else if (diff.inDays < 7) {
      return 'Acum ${diff.inDays} zile';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary 
            ? LinearGradient(colors: [color, color.withOpacity(0.8)])
            : null,
          color: isPrimary ? null : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: const Color(0xFF2DD4BF)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DD4BF).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        actionText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
