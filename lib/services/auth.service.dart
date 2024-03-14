
import 'dart:collection';

class AuthService {
  Map<String, String> userpassDB = HashMap();
  // ignore: non_constant_identifier_names
  bool _logged_in = false;

  AuthService() {
    userpassDB["user1"] = "password";
  }

  bool get isLoggedIn {
    return _logged_in;
  }

  bool login(username, password) {
    _logged_in = userpassDB.containsKey(username) 
      && password == userpassDB[username];

    return _logged_in;
  }

  void logout() {
    _logged_in = false;
  }

  bool register(username, email, password) {
    if(userpassDB.containsKey(username)) {
      _logged_in = false;
      return false;
    }

    userpassDB[username] = password;
    _logged_in = true;
    return true;
  }
}