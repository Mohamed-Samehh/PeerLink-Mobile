const String baseUrl = 'http://localhost:8000/api';

// For Android emulator
// const String baseUrl = 'http://10.0.2.2:8000/api';

String getImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return '$baseUrl/storage/$path';
}
