import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
} from 'react-native';
import * as Location from 'expo-location';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../App';
import { api } from '../lib/api';

type Props = NativeStackScreenProps<RootStackParamList, 'NewRequest'>;

const CATEGORIES = ['plumber', 'electrician', 'locksmith', 'cleaning'];

export const NewRequestScreen: React.FC<Props> = ({ route, navigation }) => {
  const [category, setCategory] = useState<string>('plumber');
  const [description, setDescription] = useState('');
  const [coords, setCoords] = useState<{ lat: number; lon: number } | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permisiune locație', 'Permite accesul la locație pentru a crea cererea.');
        return;
      }
      const loc = await Location.getCurrentPositionAsync({});
      setCoords({ lat: loc.coords.latitude, lon: loc.coords.longitude });
    })();
  }, []);

  const handleSubmit = async () => {
    if (!coords) {
      Alert.alert('Locație', 'Așteaptă detectarea locației înainte de a trimite.');
      return;
    }
    if (!description.trim()) {
      Alert.alert('Descriere', 'Te rugăm să adaugi o descriere.');
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await api.post('/requests', {
        category,
        description,
        lat: coords.lat,
        lon: coords.lon,
        providerId: route.params?.providerId,
      });
      const request = res.data;
      navigation.replace('RequestDetails', { requestId: request.id });
    } catch (err) {
      console.error('Create request error', err);
      Alert.alert('Eroare', 'Nu s-a putut crea cererea. Verifică backend-ul.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Cerere nouă</Text>
      {route.params?.providerName && (
        <Text style={styles.subtitle}>Către: {route.params.providerName}</Text>
      )}

      <Text style={styles.label}>Categorie</Text>
      <View style={styles.chipsRow}>
        {CATEGORIES.map((c) => (
          <TouchableOpacity
            key={c}
            style={[styles.chip, category === c && styles.chipActive]}
            onPress={() => setCategory(c)}
          >
            <Text style={[styles.chipText, category === c && styles.chipTextActive]}>
              {c}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <Text style={styles.label}>Descriere</Text>
      <TextInput
        style={styles.textArea}
        placeholder="Descrie problema (ex: țeavă spartă, fără apă caldă...)"
        multiline
        numberOfLines={4}
        value={description}
        onChangeText={setDescription}
      />

      <TouchableOpacity
        style={[styles.button, isSubmitting && { opacity: 0.7 }]}
        disabled={isSubmitting}
        onPress={handleSubmit}
      >
        <Text style={styles.buttonText}>Trimite cerere</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f9fafb',
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#4b5563',
    marginBottom: 12,
  },
  label: {
    marginTop: 12,
    marginBottom: 4,
    fontSize: 14,
    fontWeight: '600',
  },
  chipsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  chip: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: '#d1d5db',
    backgroundColor: '#fff',
  },
  chipActive: {
    backgroundColor: '#2563eb',
    borderColor: '#2563eb',
  },
  chipText: {
    fontSize: 13,
    color: '#4b5563',
  },
  chipTextActive: {
    color: '#fff',
  },
  textArea: {
    marginTop: 4,
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 8,
    padding: 12,
    minHeight: 100,
    textAlignVertical: 'top',
    backgroundColor: '#fff',
  },
  button: {
    marginTop: 24,
    paddingVertical: 12,
    borderRadius: 999,
    backgroundColor: '#2563eb',
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontWeight: '600',
  },
});


