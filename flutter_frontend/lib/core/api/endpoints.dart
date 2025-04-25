class Endpoints {
  static const String baseUrl = 'http://localhost:8000/api';

  // 'http://10.0.2.2:8000/api' Android emulator and make sure to run "php artisan serve --host=0.0.0.0 --port=8000"
  // 'http://localhost:8000/api' Web or other platforms

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';

  // User
  static const String profile = '/profile';
  static const String updatePassword = '/password';
  static const String userProfile = '/users/';

  // Posts
  static const String posts = '/posts';
  static const String post = '/posts/';
  static const String userPosts = '/user-posts';
  static const String userPostsById = '/users/';

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
