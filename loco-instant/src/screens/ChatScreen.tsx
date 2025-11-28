import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  FlatList,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { io, Socket } from 'socket.io-client';
import type { RootStackParamList } from '../App';
import { api } from '../lib/api';
import { useAuthStore } from '../store/useAuthStore';

type Props = NativeStackScreenProps<RootStackParamList, 'Chat'>;

type ChatMessage = {
  id: number;
  text: string;
  from?: string;
  sentAt: string;
};

export const ChatScreen: React.FC<Props> = ({ route }) => {
  const { requestId } = route.params;
  const token = useAuthStore((s) => s.token);
  const user = useAuthStore((s) => s.user);

  const [socket, setSocket] = useState<Socket | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [text, setText] = useState('');

  useEffect(() => {
    if (!token) return;

    const s = io(api.defaults.baseURL ?? '', {
      transports: ['websocket'],
      query: {
        token,
        requestId: String(requestId),
      },
    });

    s.on('connect_error', (err) => {
      console.log('Socket connect error', err);
    });

    s.on('chat:message', (msg: ChatMessage) => {
      setMessages((prev) => [...prev, msg]);
    });

    setSocket(s);

    return () => {
      s.disconnect();
    };
  }, [token, requestId]);

  const handleSend = async () => {
    if (!text.trim()) return;

    const payload = {
      requestId,
      text,
      from: user?.email ?? 'client',
    };

    // local echo
    setMessages((prev) => [
      ...prev,
      {
        id: prev.length + 1,
        text,
        from: payload.from,
        sentAt: new Date().toISOString(),
      },
    ]);

    setText('');

    try {
      socket?.emit('chat:message', payload);
    } catch {}

    try {
      await api.post('/chat/send', payload);
    } catch (err) {
      console.error('Chat send error', err);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={80}
    >
      <FlatList
        style={styles.list}
        data={messages}
        keyExtractor={(item) => String(item.id)}
        renderItem={({ item }) => (
          <View
            style={[
              styles.messageBubble,
              item.from === user?.email ? styles.messageOutgoing : styles.messageIncoming,
            ]}
          >
            <Text style={styles.messageText}>{item.text}</Text>
            <Text style={styles.messageMeta}>{item.from}</Text>
          </View>
        )}
        contentContainerStyle={{ padding: 12 }}
      />

      <View style={styles.inputRow}>
        <TextInput
          style={styles.input}
          placeholder="Scrie un mesaj..."
          value={text}
          onChangeText={setText}
        />
        <TouchableOpacity style={styles.sendButton} onPress={handleSend}>
          <Text style={styles.sendText}>Trimite</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  list: {
    flex: 1,
  },
  messageBubble: {
    maxWidth: '80%',
    padding: 10,
    borderRadius: 12,
    marginBottom: 8,
  },
  messageIncoming: {
    alignSelf: 'flex-start',
    backgroundColor: '#e5e7eb',
  },
  messageOutgoing: {
    alignSelf: 'flex-end',
    backgroundColor: '#2563eb',
  },
  messageText: {
    color: '#111827',
  },
  messageMeta: {
    marginTop: 4,
    fontSize: 10,
    color: '#6b7280',
  },
  inputRow: {
    flexDirection: 'row',
    padding: 8,
    borderTopWidth: 1,
    borderTopColor: '#e5e7eb',
    backgroundColor: '#fff',
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8,
    marginRight: 8,
    backgroundColor: '#fff',
  },
  sendButton: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 999,
    backgroundColor: '#2563eb',
    alignItems: 'center',
    justifyContent: 'center',
  },
  sendText: {
    color: '#fff',
    fontWeight: '600',
  },
});


