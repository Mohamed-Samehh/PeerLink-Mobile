class Endpoints {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';

  // User
  static const String profile = '/profile';
  static const String updatePassword = '/password';

  // Posts
  static const String posts = '/posts';
  static const String post = '/posts/';

  // Follow
  static const String follow = '/follow/';
  static const String search = '/search';

  // Like
  static const String like = '/like/';
  static const String likes = '/likes/';
}
