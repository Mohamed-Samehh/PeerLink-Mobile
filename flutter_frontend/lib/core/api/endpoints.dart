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
  static const String userPosts = '/user-posts';

  // Follow
  static const String follow = '/follow/';
  static const String search = '/search';
  static const String following = '/following';
  static const String followers = '/followers';
  static const String followBack = '/follow-back';
  static const String explore = '/explore';

  // Like
  static const String like = '/like/';
  static const String likes = '/likes/';
}
