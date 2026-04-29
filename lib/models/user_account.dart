/// One user of the app. The shape is deliberately Firebase-friendly so the
/// LocalAuthService can be swapped for FirebaseAuth later without touching
/// the UI.
class UserAccount {
  final String id;
  final String? email;
  final String displayName;
  final bool isAnonymous;
  final DateTime createdAt;

  const UserAccount({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.email,
    this.isAnonymous = false,
  });

  /// Create a fresh anonymous user (no email, generated id).
  factory UserAccount.anonymous() {
    final now = DateTime.now();
    return UserAccount(
      id: 'anon_${now.microsecondsSinceEpoch}',
      displayName: 'Guest',
      createdAt: now,
      isAnonymous: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'isAnonymous': isAnonymous,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: (json['displayName'] as String?) ?? 'User',
      isAnonymous: (json['isAnonymous'] as bool?) ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  UserAccount copyWith({String? displayName, String? email}) {
    return UserAccount(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isAnonymous: isAnonymous,
      createdAt: createdAt,
    );
  }
}
