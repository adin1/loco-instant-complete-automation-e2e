import { create } from 'zustand';
import * as SecureStore from 'expo-secure-store';

type User = {
  id: number;
  email: string;
  name?: string | null;
  role?: string | null;
};

type AuthState = {
  token: string | null;
  user: User | null;
  setToken: (token: string | null) => void;
  setUser: (user: User | null) => void;
  logout: () => void;
};

const TOKEN_KEY = 'auth_token';

export const useAuthStore = create<AuthState>((set) => ({
  token: null,
  user: null,
  setToken: (token) => {
    set({ token });
    if (token) {
      SecureStore.setItemAsync(TOKEN_KEY, token).catch(() => {
        // ignore persistence errors in UI
      });
    } else {
      SecureStore.deleteItemAsync(TOKEN_KEY).catch(() => {
        // ignore persistence errors in UI
      });
    }
  },
  setUser: (user) => set({ user }),
  logout: () => {
    set({ token: null, user: null });
    SecureStore.deleteItemAsync(TOKEN_KEY).catch(() => {
      // ignore persistence errors in UI
    });
  },
}));

