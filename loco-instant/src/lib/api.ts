import axios from 'axios';
import { getApiBaseUrl } from '../config/env';

export const api = axios.create({
  baseURL: getApiBaseUrl(),
  timeout: 10000,
});


