enum NDType { adhd, autism, both, other }

class UserModel {
  final String uid;
  final String name;
  final String username;
  final NDType ndType;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.ndType,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      ndType: NDType.values.firstWhere(
        (e) => e.name == map['ndType'],
        orElse: () => NDType.other,
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'ndType': ndType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
