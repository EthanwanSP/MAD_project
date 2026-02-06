class AuthSession {
  static String? idToken;
  static String? userId;
  static String displayName = '';
  static String email = '';

  static bool get isSignedIn => idToken != null && userId != null;

  static void clear() {
    idToken = null;
    userId = null;
    displayName = '';
    email = '';
  }
}
