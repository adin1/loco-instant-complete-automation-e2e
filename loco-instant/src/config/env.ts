import { Platform } from 'react-native';

export function getApiBaseUrl(): string {
  // On Android emulator, localhost of host is 10.0.2.2
  if (Platform.OS === 'android') {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}


