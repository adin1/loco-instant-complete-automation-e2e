import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
} from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { api } from '../lib/api';
import { useAuthStore } from '../store/useAuthStore';
import type { RootStackParamList } from '../App';

type Props = NativeStackScreenProps<RootStackParamList, 'Auth'>;

const TEST_CLIENT = {
  email: 'client@test.com',
  password: 'password123',
  name: 'Client Test',
};

const TEST_PROVIDER = {
  email: 'provider@test.com',
  password: 'password123',
  name: 'Provider Test',
};

export const AuthScreen: React.FC<Props> = ({ navigation }) => {
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [email, setEmail] = useState(TEST_CLIENT.email);
  const [password, setPassword] = useState(TEST_CLIENT.password);
  const [name, setName] = useState(TEST_CLIENT.name);
  const [isLoading, setIsLoading] = useState(false);

  const setToken = useAuthStore((s) => s.setToken);
  const setUser = useAuthStore((s) => s.setUser);

  const handleAuthSuccess = (accessToken: string, user: any) => {
    setToken(accessToken);
    setUser({
      id: user.id,
      email: user.email,
      name: user.name,
      role: (user as any).role ?? null,
    });
    navigation.reset({
      index: 0,
      routes: [{ name: 'Home' }],
    });
  };

  const handleLogin = async (loginEmail: string, loginPassword: string) => {
    setIsLoading(true);
    try {
      const res = await api.post('/auth/login', {
        email: loginEmail,
        password: loginPassword,
      });
      handleAuthSuccess(res.data.access_token, res.data.user);
    } catch (err: any) {
      console.error('Login error', err);
      Alert.alert('Eroare login', 'Verifică email/parola sau backend-ul.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleRegister = async () => {
    setIsLoading(true);
    try {
      await api.post('/auth/register', {
        email,
        password,
        name,
      });
      // după înregistrare, facem automat login
      await handleLogin(email, password);
    } catch (err: any) {
      console.error('Register error', err);
      Alert.alert('Eroare înregistrare', 'Utilizatorul există deja sau backend-ul nu răspunde.');
    } finally {
      setIsLoading(false);
    }
  };

  const createTestUsers = async () => {
    setIsLoading(true);
    try {
      await api.post('/auth/register', TEST_CLIENT);
    } catch {}
    try {
      await api.post('/auth/register', TEST_PROVIDER);
    } catch {}
    Alert.alert(
      'Useri de test',
      'Useri de test:\n\nClient: client@test.com / password123\nProvider: provider@test.com / password123',
    );
    setIsLoading(false);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.card}>
        <Text style={styles.title}>LOCO Instant</Text>
        <View style={styles.tabs}>
          <TouchableOpacity
            style={[styles.tab, mode === 'login' && styles.tabActive]}
            onPress={() => setMode('login')}
          >
            <Text style={[styles.tabText, mode === 'login' && styles.tabTextActive]}>
              Login
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.tab, mode === 'register' && styles.tabActive]}
            onPress={() => setMode('register')}
          >
            <Text style={[styles.tabText, mode === 'register' && styles.tabTextActive]}>
              Register
            </Text>
          </TouchableOpacity>
        </View>

        {mode === 'register' && (
          <TextInput
            style={styles.input}
            placeholder="Nume"
            value={name}
            onChangeText={setName}
          />
        )}

        <TextInput
          style={styles.input}
          placeholder="Email"
          autoCapitalize="none"
          keyboardType="email-address"
          value={email}
          onChangeText={setEmail}
        />
        <TextInput
          style={styles.input}
          placeholder="Parolă"
          secureTextEntry
          value={password}
          onChangeText={setPassword}
        />

        <TouchableOpacity
          style={[styles.button, isLoading && { opacity: 0.7 }]}
          disabled={isLoading}
          onPress={mode === 'login' ? () => handleLogin(email, password) : handleRegister}
        >
          <Text style={styles.buttonText}>
            {mode === 'login' ? 'Autentificare' : 'Înregistrare'}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.secondaryButton}
          onPress={createTestUsers}
          disabled={isLoading}
        >
          <Text style={styles.secondaryText}>Creează useri de test</Text>
        </TouchableOpacity>

        <View style={styles.testInfo}>
          <Text style={styles.testInfoText}>
            Client test: client@test.com / password123{'\n'}
            Provider test: provider@test.com / password123
          </Text>
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#0f172a',
  },
  card: {
    width: '90%',
    padding: 24,
    borderRadius: 16,
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOpacity: 0.15,
    shadowRadius: 10,
    elevation: 4,
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
    marginBottom: 16,
    textAlign: 'center',
  },
  tabs: {
    flexDirection: 'row',
    marginBottom: 16,
    borderRadius: 999,
    backgroundColor: '#e5e7eb',
    padding: 2,
  },
  tab: {
    flex: 1,
    paddingVertical: 8,
    borderRadius: 999,
    alignItems: 'center',
  },
  tabActive: {
    backgroundColor: '#2563eb',
  },
  tabText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#4b5563',
  },
  tabTextActive: {
    color: '#fff',
  },
  input: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginBottom: 10,
  },
  button: {
    marginTop: 8,
    paddingVertical: 12,
    borderRadius: 999,
    backgroundColor: '#2563eb',
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontWeight: '600',
  },
  secondaryButton: {
    marginTop: 12,
    alignItems: 'center',
  },
  secondaryText: {
    color: '#2563eb',
    fontSize: 13,
  },
  testInfo: {
    marginTop: 16,
  },
  testInfoText: {
    fontSize: 12,
    color: '#6b7280',
    textAlign: 'center',
  },
});


