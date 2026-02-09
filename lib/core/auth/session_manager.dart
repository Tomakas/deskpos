import '../data/models/user_model.dart';

class SessionManager {
  UserModel? _activeUser;
  final Map<String, UserModel> _loggedInUsers = {};

  UserModel? get activeUser => _activeUser;

  List<UserModel> get loggedInUsers => _loggedInUsers.values.toList();

  bool get isAuthenticated => _activeUser != null;

  void login(UserModel user) {
    _loggedInUsers[user.id] = user;
    _activeUser = user;
  }

  void switchTo(String userId) {
    final user = _loggedInUsers[userId];
    if (user != null) {
      _activeUser = user;
    }
  }

  void logoutActive() {
    if (_activeUser != null) {
      _loggedInUsers.remove(_activeUser!.id);
      _activeUser = _loggedInUsers.values.isNotEmpty ? _loggedInUsers.values.first : null;
    }
  }

  void logoutAll() {
    _loggedInUsers.clear();
    _activeUser = null;
  }

  bool isLoggedIn(String userId) => _loggedInUsers.containsKey(userId);
}
