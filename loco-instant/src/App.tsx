import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { QueryProvider } from './providers/QueryProvider';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { HomeScreen } from './screens/HomeScreen';
import { AuthScreen } from './screens/AuthScreen';
import { ProviderDetailsScreen } from './screens/ProviderDetailsScreen';
import { NewRequestScreen } from './screens/NewRequestScreen';
import { RequestDetailsScreen } from './screens/RequestDetailsScreen';
import { ChatScreen } from './screens/ChatScreen';
import { useAuthStore } from './store/useAuthStore';
import { useNotifications } from './hooks/useNotifications';

export type RootStackParamList = {
  Auth: undefined;
  Home: undefined;
  ProviderDetails: { providerId: number; providerName?: string } | undefined;
  NewRequest: { providerId?: number; providerName?: string } | undefined;
  RequestDetails: { requestId: number };
  Chat: { requestId: number; providerId?: number };
};

const Stack = createNativeStackNavigator<RootStackParamList>();

const AppStack: React.FC = () => {
  const token = useAuthStore((s) => s.token);
  useNotifications();

  return (
    <NavigationContainer>
      <Stack.Navigator>
        {token ? (
          <>
            <Stack.Screen
              name="Home"
              component={HomeScreen}
              options={{ title: 'LOCO Instant' }}
            />
            <Stack.Screen
              name="ProviderDetails"
              component={ProviderDetailsScreen}
              options={{ title: 'Detalii prestator' }}
            />
            <Stack.Screen
              name="NewRequest"
              component={NewRequestScreen}
              options={{ title: 'Cerere nouă' }}
            />
            <Stack.Screen
              name="RequestDetails"
              component={RequestDetailsScreen}
              options={{ title: 'Detalii cerere' }}
            />
            <Stack.Screen
              name="Chat"
              component={ChatScreen}
              options={{ title: 'Chat' }}
            />
          </>
        ) : (
          <Stack.Screen
            name="Auth"
            component={AuthScreen}
            options={{ headerShown: false }}
          />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};

const App: React.FC = () => {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <QueryProvider>
        <AppStack />
        <StatusBar style="auto" />
      </QueryProvider>
    </GestureHandlerRootView>
  );
};

export default App;

