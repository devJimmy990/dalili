const read = (value: string | undefined): string => (value ?? '').trim();

export const API_BASE_URL = read(import.meta.env.VITE_API_BASE_URL).replace(/\/+$/, '') ||
  'https://dalili-e0qh.onrender.com/api';

/** Empty hides the "Get the app" button. */
export const APP_DOWNLOAD_URL = read(import.meta.env.VITE_APP_DOWNLOAD_URL);

export const ANDROID_PACKAGE = read(import.meta.env.VITE_ANDROID_PACKAGE) || 'com.example.dalili';
