import 'dart:async';
import 'dart:convert';
import 'dart:math';

/// Model pentru un mesaj de chat
class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime sentAt;
  final MessageStatus status;
  final String? senderName;
  final String? senderAvatar;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.sentAt,
    this.status = MessageStatus.sent,
    this.senderName,
    this.senderAvatar,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? sentAt,
    MessageStatus? status,
    String? senderName,
    String? senderAvatar,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Serviciu de chat cu simulare WebSocket pentru demo
class ChatService {
  final int orderId;
  final String baseUrl;
  
  final _messagesController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<bool>.broadcast();
  final List<ChatMessage> _messages = [];
  Timer? _typingTimer;
  Timer? _responseTimer;
  final _random = Random();

  ChatService({
    required this.orderId,
    required this.baseUrl,
  });

  /// Stream de mesaje noi
  Stream<ChatMessage> get messagesStream => _messagesController.stream;

  /// Stream pentru indicator "typing"
  Stream<bool> get typingStream => _typingController.stream;

  /// Lista tuturor mesajelor
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Conectează la chat (simulat)
  Future<void> connect() async {
    // În producție, aici s-ar conecta la WebSocket
    // Pentru demo, simulăm conexiunea
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Adaugă mesaj de bun venit
    final welcomeMessage = ChatMessage(
      id: _generateId(),
      text: 'Bună! Sunt Ion, prestatorul tău pentru comanda #$orderId. Cu ce te pot ajuta?',
      isMe: false,
      sentAt: DateTime.now(),
      senderName: 'Ion Popescu',
    );
    _addMessage(welcomeMessage);
  }

  /// Trimite un mesaj
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Creează mesajul
    final message = ChatMessage(
      id: _generateId(),
      text: text.trim(),
      isMe: true,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    _addMessage(message);

    // Simulează trimiterea
    await Future.delayed(const Duration(milliseconds: 300 + _random.nextInt(300)));

    // Actualizează status la "sent"
    _updateMessageStatus(message.id, MessageStatus.sent);

    // Simulează "delivered" după un scurt delay
    await Future.delayed(const Duration(milliseconds: 500));
    _updateMessageStatus(message.id, MessageStatus.delivered);

    // Simulează răspuns automat pentru demo
    _simulateResponse(text);
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    _messagesController.add(message);
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final updatedMessage = _messages[index].copyWith(status: status);
      _messages[index] = updatedMessage;
      _messagesController.add(updatedMessage);
    }
  }

  /// Simulează răspuns automat
  void _simulateResponse(String userMessage) {
    // Cancel previous timers
    _typingTimer?.cancel();
    _responseTimer?.cancel();

    // Start typing indicator
    _typingTimer = Timer(const Duration(milliseconds: 800), () {
      _typingController.add(true);
    });

    // Generate response after "typing"
    final responseDelay = Duration(milliseconds: 2000 + _random.nextInt(2000));
    _responseTimer = Timer(responseDelay, () {
      _typingController.add(false);

      final response = _generateResponse(userMessage);
      final responseMessage = ChatMessage(
        id: _generateId(),
        text: response,
        isMe: false,
        sentAt: DateTime.now(),
        senderName: 'Ion Popescu',
      );

      _addMessage(responseMessage);

      // Mark user's last message as read
      final lastUserMessage = _messages.lastWhere(
        (m) => m.isMe,
        orElse: () => _messages.first,
      );
      _updateMessageStatus(lastUserMessage.id, MessageStatus.read);
    });
  }

  String _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('preț') || lowerMessage.contains('cost') || lowerMessage.contains('cât')) {
      return 'Prețul estimat pentru serviciu este de aproximativ 50-75 RON, în funcție de complexitate. Vrei să confirm comanda?';
    }

    if (lowerMessage.contains('timp') || lowerMessage.contains('durează') || lowerMessage.contains('când')) {
      return 'Pot ajunge în aproximativ 15-20 de minute. Te anunț când sunt în drum!';
    }

    if (lowerMessage.contains('locație') || lowerMessage.contains('adresă') || lowerMessage.contains('unde')) {
      return 'Am văzut locația ta pe hartă. E corectă? Dacă da, pornesc imediat!';
    }

    if (lowerMessage.contains('mulțumesc') || lowerMessage.contains('mersi')) {
      return 'Cu plăcere! Dacă ai alte întrebări, sunt aici. 😊';
    }

    if (lowerMessage.contains('ok') || lowerMessage.contains('da') || lowerMessage.contains('bine')) {
      return 'Perfect! Pornesc acum spre tine. Te anunț când ajung! 🚗';
    }

    if (lowerMessage.contains('nu') || lowerMessage.contains('anulează')) {
      return 'Înțeleg. Dacă te răzgândești, sunt aici. Spor!';
    }

    // Răspunsuri generice
    final genericResponses = [
      'Am înțeles. Mai ai și alte întrebări?',
      'Sigur! Altceva cu care te pot ajuta?',
      'Notez asta. Vom rezolva împreună!',
      'Perfect, mulțumesc pentru informație!',
      'OK, voi ține cont de asta.',
    ];

    return genericResponses[_random.nextInt(genericResponses.length)];
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(10000).toString();
  }

  /// Deconectează de la chat
  void disconnect() {
    _typingTimer?.cancel();
    _responseTimer?.cancel();
    _messagesController.close();
    _typingController.close();
  }
}

