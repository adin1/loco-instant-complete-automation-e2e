import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../App';

type Props = NativeStackScreenProps<RootStackParamList, 'ProviderDetails'>;

export const ProviderDetailsScreen: React.FC<Props> = ({ route, navigation }) => {
  const { providerId, providerName } = route.params || {};

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{providerName ?? `Prestator #${providerId}`}</Text>
      <Text style={styles.subtitle}>
        Aici poți afișa detalii suplimentare despre prestator (rating, servicii, descriere).
      </Text>

      <TouchableOpacity
        style={styles.button}
        onPress={() =>
          navigation.navigate('NewRequest', {
            providerId,
            providerName: providerName ?? undefined,
          })
        }
      >
        <Text style={styles.buttonText}>Creează cerere</Text>
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
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#4b5563',
    marginBottom: 24,
  },
  button: {
    marginTop: 16,
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


