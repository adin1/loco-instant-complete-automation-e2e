import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Dimensions, ActivityIndicator, TouchableOpacity } from 'react-native';
import MapView, { Marker, Region } from 'react-native-maps';
import * as Location from 'expo-location';
import { useQuery } from '@tanstack/react-query';
import { api } from '../lib/api';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../App';

type Provider = {
  id: number;
  name: string;
  service_names?: string[];
  rating_avg?: number;
  location?: {
    lat: number;
    lon: number;
  };
};

const { width, height } = Dimensions.get('window');
const ASPECT_RATIO = width / height;
const LATITUDE_DELTA = 0.05;
const LONGITUDE_DELTA = LATITUDE_DELTA * ASPECT_RATIO;

export const HomeScreen: React.FC = () => {
  const [region, setRegion] = useState<Region>({
    latitude: 46.770439,
    longitude: 23.591423,
    latitudeDelta: LATITUDE_DELTA,
    longitudeDelta: LONGITUDE_DELTA,
  });
  const [selectedProvider, setSelectedProvider] = useState<Provider | null>(null);
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();

  const { data, isLoading, refetch } = useQuery({
    queryKey: ['providers', region.latitude, region.longitude],
    queryFn: async () => {
      const res = await api.get<Provider[]>('/providers/nearby', {
        params: {
          lat: region.latitude,
          lon: region.longitude,
          radiusMeters: 3000,
        },
      });
      return res.data;
    },
  });

  useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        return;
      }
      const loc = await Location.getCurrentPositionAsync({});
      setRegion((prev) => ({
        ...prev,
        latitude: loc.coords.latitude,
        longitude: loc.coords.longitude,
      }));
      refetch();
    })();
  }, []);

  const providers = data ?? [];

  const handleDetectLocation = async () => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== 'granted') {
      return;
    }
    const loc = await Location.getCurrentPositionAsync({});
    setRegion((prev) => ({
      ...prev,
      latitude: loc.coords.latitude,
      longitude: loc.coords.longitude,
    }));
    refetch();
  };

  const handleOpenProviderDetails = () => {
    if (!selectedProvider) return;
    navigation.navigate('ProviderDetails', {
      providerId: selectedProvider.id,
      providerName: selectedProvider.name,
    });
  };

  return (
    <View style={styles.container}>
      <MapView
        style={StyleSheet.absoluteFillObject}
        region={region}
        onRegionChangeComplete={setRegion}
      >
        {providers.map((p) =>
          p.location ? (
            <Marker
              key={p.id}
              coordinate={{
                latitude: p.location.lat,
                longitude: p.location.lon,
              }}
              title={p.name}
              description={p.service_names?.join(', ')}
              onPress={() => setSelectedProvider(p)}
            />
          ) : null,
        )}
      </MapView>

      <View style={styles.topBar}>
        <Text style={styles.title}>LOCO Instant</Text>
        <TouchableOpacity style={styles.locationButton} onPress={handleDetectLocation}>
          <Text style={styles.locationText}>Detectează locația</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.bottomSheet}>
        {isLoading ? (
          <ActivityIndicator />
        ) : (
          <>
            <Text style={styles.sheetTitle}>
              {selectedProvider?.name ?? 'Alege o mașină / prestator de pe hartă'}
            </Text>
            <Text style={styles.sheetSubtitle}>
              {selectedProvider?.service_names?.join(', ') ??
                'Prestatori locali disponibili în apropiere'}
            </Text>
            <TouchableOpacity style={styles.button} onPress={handleOpenProviderDetails}>
              <Text style={styles.buttonText}>Detalii prestator</Text>
            </TouchableOpacity>
          </>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  topBar: {
    position: 'absolute',
    top: 50,
    left: 20,
    right: 20,
    padding: 12,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.95)',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  title: {
    fontWeight: '600',
    fontSize: 18,
  },
  locationButton: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 999,
    backgroundColor: '#2563eb',
  },
  locationText: {
    color: '#fff',
    fontSize: 12,
  },
  bottomSheet: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    padding: 16,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    backgroundColor: '#fff',
  },
  sheetTitle: {
    fontSize: 16,
    fontWeight: '600',
  },
  sheetSubtitle: {
    marginTop: 4,
    fontSize: 13,
    color: '#666',
  },
  button: {
    marginTop: 16,
    alignSelf: 'flex-end',
    paddingHorizontal: 24,
    paddingVertical: 10,
    borderRadius: 24,
    backgroundColor: '#2563eb',
  },
  buttonText: {
    color: '#fff',
    fontWeight: '600',
  },
});


