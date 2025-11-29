import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notification> _notifications = [
    _Notification(
      id: 1,
      title: 'Comandă acceptată!',
      message: 'Ion Popescu a acceptat cererea ta de serviciu.',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.order,
      isRead: false,
    ),
    _Notification(
      id: 2,
      title: 'Prestator în drum',
      message: 'Maria Ionescu este în drum spre tine. ETA: 15 minute.',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.location,
      isRead: false,
    ),
    _Notification(
      id: 3,
      title: 'Plată procesată',
      message: 'Plata de 150 RON a fost procesată cu succes.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.payment,
      isRead: true,
    ),
    _Notification(
      id: 4,
      title: 'Lasă o recenzie',
      message: 'Cum a fost experiența cu Andrei Vasile? Lasă o recenzie.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.review,
      isRead: true,
    ),
    _Notification(
      id: 5,
      title: 'Promoție specială! 🎉',
      message: '20% reducere la servicii de curățenie. Valabil până duminică!',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.promo,
      isRead: true,
    ),
    _Notification(
      id: 6,
      title: 'Bine ai venit!',
      message: 'Contul tău LOCO Instant a fost creat cu succes.',
      time: DateTime.now().subtract(const Duration(days: 7)),
      type: NotificationType.system,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificări'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Marchează ca citite'),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _EmptyState()
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () => _openNotification(notification),
                  onDismiss: () => _dismissNotification(notification),
                );
              },
            ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toate notificările au fost marcate ca citite'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openNotification(_Notification notification) {
    setState(() {
      notification.isRead = true;
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              notification.icon,
              color: notification.color,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Text(
              _formatTime(notification.time),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Închide'),
          ),
        ],
      ),
    );
  }

  void _dismissNotification(_Notification notification) {
    setState(() {
      _notifications.remove(notification);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notificare ștearsă'),
        action: SnackBarAction(
          label: 'Anulează',
          onPressed: () {
            setState(() {
              _notifications.add(notification);
              _notifications.sort((a, b) => b.time.compareTo(a.time));
            });
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return 'Acum ${diff.inMinutes} minute';
    } else if (diff.inHours < 24) {
      return 'Acum ${diff.inHours} ore';
    } else if (diff.inDays == 1) {
      return 'Ieri';
    } else {
      return 'Acum ${diff.inDays} zile';
    }
  }
}

enum NotificationType { order, location, payment, review, promo, system }

class _Notification {
  final int id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  _Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.location:
        return Icons.location_on;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.review:
        return Icons.star;
      case NotificationType.promo:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.location:
        return Colors.green;
      case NotificationType.payment:
        return Colors.purple;
      case NotificationType.review:
        return Colors.amber;
      case NotificationType.promo:
        return Colors.red;
      case NotificationType.system:
        return Colors.grey;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final _Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
        child: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: notification.color.withOpacity(0.1),
                child: Icon(notification.icon, color: notification.color),
              ),
              if (!notification.isRead)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification.time),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: onTap,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return 'Acum ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'Acum ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Ieri';
    } else {
      return 'Acum ${diff.inDays}z';
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nu ai notificări',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notificările vor apărea aici',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

