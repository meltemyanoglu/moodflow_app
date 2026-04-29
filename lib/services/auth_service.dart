import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';

/// Errors a UI can show. Same shape as we'd surface from FirebaseAuthException.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Abstract auth API.
///
/// Today's implementation lives entirely on-device (LocalAuthService below).
/// Tomorrow you can write a `FirebaseAuthService` that fulfills the same
/// contract, swap it in `main()`, and not touch any other file.
abstract class AuthService extends ChangeNotifier {
  UserAccount? get currentUser;
  bool get isLoggedIn;
  bool get isInitialized;

  Future<void> init();
  Future<UserAccount> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserAccount> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<UserAccount> signInAnonymously();
  Future<void> signOut();

  /// Updates display name / email of the current user. Returns updated user.
  Future<UserAccount> updateProfile({String? displayName});
}

/// SharedPreferences-backed auth.
///
/// Storage layout:
///   `auth_users`   → JSON list of all users (id, email, hashed pass, name…)
///   `auth_current` → currently signed-in user id (or null)
///
/// This is intentionally simple. Passwords are hashed with a tiny built-in
/// hash; this is fine for a local prototype but **don't** ship this to a
/// production app — switch to FirebaseAuth before that.
class LocalAuthService extends ChangeNotifier implements AuthService {
  LocalAuthService._();
  static final LocalAuthService instance = LocalAuthService._();

  static const _kUsersKey = 'auth_users_v1';
  static const _kCurrentKey = 'auth_current_v1';

  bool _initialized = false;
  UserAccount? _currentUser;

  @override
  bool get isInitialized => _initialized;
  @override
  UserAccount? get currentUser => _currentUser;
  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentId = prefs.getString(_kCurrentKey);
      if (currentId != null) {
        final users = await _loadUsers(prefs);
        _currentUser = users
            .map((u) => UserAccount.fromJson(u))
            .where((u) => u.id == currentId)
            .cast<UserAccount?>()
            .firstWhere((_) => true, orElse: () => null);
      }
    } catch (e) {
      debugPrint('LocalAuthService.init error: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  @override
  Future<UserAccount> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadUsers(prefs);
    final emailLower = email.trim().toLowerCase();

    Map<String, dynamic>? match;
    for (final u in users) {
      if ((u['email'] as String?)?.toLowerCase() == emailLower) {
        match = u;
        break;
      }
    }
    if (match == null) {
      throw AuthException('No account found with that email.');
    }
    if (match['passwordHash'] != _hash(password)) {
      throw AuthException('Wrong password.');
    }

    final user = UserAccount.fromJson(match);
    await _setCurrent(prefs, user);
    return user;
  }

  @override
  Future<UserAccount> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      throw AuthException('Please enter a valid email.');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }
    if (displayName.trim().isEmpty) {
      throw AuthException('Please enter your name.');
    }

    final prefs = await SharedPreferences.getInstance();
    final users = await _loadUsers(prefs);
    final emailLower = email.trim().toLowerCase();
    final exists = users.any(
      (u) => (u['email'] as String?)?.toLowerCase() == emailLower,
    );
    if (exists) {
      throw AuthException('An account already exists with that email.');
    }

    final now = DateTime.now();
    final user = UserAccount(
      id: 'user_${now.microsecondsSinceEpoch}',
      email: email.trim(),
      displayName: displayName.trim(),
      createdAt: now,
    );
    final stored = {
      ...user.toJson(),
      'passwordHash': _hash(password),
    };
    users.add(stored);
    await _saveUsers(prefs, users);
    await _setCurrent(prefs, user);
    return user;
  }

  @override
  Future<UserAccount> signInAnonymously() async {
    final prefs = await SharedPreferences.getInstance();
    final user = UserAccount.anonymous();
    final users = await _loadUsers(prefs);
    users.add(user.toJson());
    await _saveUsers(prefs, users);
    await _setCurrent(prefs, user);
    return user;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentKey);
    _currentUser = null;
    notifyListeners();
  }

  @override
  Future<UserAccount> updateProfile({String? displayName}) async {
    final user = _currentUser;
    if (user == null) {
      throw AuthException('Not signed in.');
    }
    final updated = user.copyWith(displayName: displayName);
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadUsers(prefs);
    for (var i = 0; i < users.length; i++) {
      if (users[i]['id'] == user.id) {
        users[i] = {
          ...users[i],
          ...updated.toJson(),
        };
        break;
      }
    }
    await _saveUsers(prefs, users);
    _currentUser = updated;
    notifyListeners();
    return updated;
  }

  // ---------- internals ----------

  Future<List<Map<String, dynamic>>> _loadUsers(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_kUsersKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    } catch (e) {
      debugPrint('LocalAuthService._loadUsers error: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _saveUsers(
    SharedPreferences prefs,
    List<Map<String, dynamic>> users,
  ) async {
    await prefs.setString(_kUsersKey, jsonEncode(users));
  }

  Future<void> _setCurrent(SharedPreferences prefs, UserAccount user) async {
    await prefs.setString(_kCurrentKey, user.id);
    _currentUser = user;
    notifyListeners();
  }

  /// Tiny non-cryptographic hash. Fine for local prototype only.
  String _hash(String input) {
    var h = 0xcbf29ce484222325; // FNV-1a 64-bit offset basis
    const prime = 0x100000001b3;
    for (final code in input.codeUnits) {
      h ^= code;
      h = (h * prime) & 0xFFFFFFFFFFFFFFFF;
    }
    return h.toRadixString(16);
  }
}
