import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  FlatList,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import type { RootStackParamList } from '../App';

type Props = NativeStackScreenProps<RootStackParamList, 'RequestDetails'>;

type Request = {
  id: number;
  status: string;
  category?: string;
  description?: string;
};

type Offer = {
  id: number;
  status: string;
  price?: number;
  requestId?: number;
  providerName?: string;
};

export const RequestDetailsScreen: React.FC<Props> = ({ route, navigation }) => {
  const { requestId } = route.params;
  const queryClient = useQueryClient();

  const { data: request, isLoading: loadingRequest } = useQuery<Request>({
    queryKey: ['request', requestId],
    queryFn: async () => {
      const res = await api.get(`/requests/${requestId}`);
      return res.data;
    },
  });

  const {
    data: offers = [],
    isLoading: loadingOffers,
    refetch: refetchOffers,
  } = useQuery<Offer[]>({
    queryKey: ['offers', requestId],
    queryFn: async () => {
      const res = await api.get<Offer[]>('/offers');
      return res.data.filter((o) => o.requestId === requestId);
    },
  });

  const handleAcceptOffer = async (offer: Offer) => {
    try {
      await api.post(`/requests/${requestId}/accept/${offer.id}`);
      await refetchOffers();
      await queryClient.invalidateQueries({ queryKey: ['request', requestId] });
      navigation.navigate('Chat', {
        requestId,
      });
    } catch (err) {
      console.error('Accept offer error', err);
      Alert.alert('Eroare', 'Nu s-a putut accepta oferta.');
    }
  };

  if (loadingRequest) {
    return (
      <View style={styles.center}>
        <ActivityIndicator />
      </View>
    );
  }

  if (!request) {
    return (
      <View style={styles.center}>
        <Text>Cererea nu a fost găsită.</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Cerere #{request.id}</Text>
      <Text style={styles.subtitle}>
        Status: <Text style={styles.badge}>{request.status}</Text>
      </Text>
      {request.category && <Text>Categorie: {request.category}</Text>}
      {request.description && <Text>Descriere: {request.description}</Text>}

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Oferte</Text>
        {loadingOffers ? (
          <ActivityIndicator />
        ) : (
          <FlatList
            data={offers}
            keyExtractor={(item) => String(item.id)}
            renderItem={({ item }) => (
              <View style={styles.offerCard}>
                <Text style={styles.offerText}>
                  Oferta #{item.id} - {item.price ?? 'fără preț'} - {item.status}
                </Text>
                <TouchableOpacity
                  style={styles.acceptButton}
                  onPress={() => handleAcceptOffer(item)}
                >
                  <Text style={styles.acceptText}>Acceptă oferta</Text>
                </TouchableOpacity>
              </View>
            )}
            ListEmptyComponent={
              <Text style={styles.emptyText}>
                Nu există încă oferte. (Socket.IO va actualiza această listă în timp real.)
              </Text>
            }
          />
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f9fafb',
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#4b5563',
    marginBottom: 8,
  },
  badge: {
    fontWeight: '600',
  },
  section: {
    marginTop: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  offerCard: {
    padding: 12,
    borderRadius: 8,
    backgroundColor: '#fff',
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#e5e7eb',
  },
  offerText: {
    marginBottom: 8,
  },
  acceptButton: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 999,
    backgroundColor: '#22c55e',
  },
  acceptText: {
    color: '#fff',
    fontWeight: '600',
  },
  emptyText: {
    fontSize: 13,
    color: '#6b7280',
  },
});


