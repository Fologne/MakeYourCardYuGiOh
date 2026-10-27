class UserModel {
  final String id;
  final String accountId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String gender;
  final String gameOrigin;
  final String plan;
  final String preferredPronoun;

  UserModel({
    required this.id,
    required this.accountId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.gameOrigin,
    this.plan = 'Gratuito',
    this.preferredPronoun = 'Duelista',
  });

  String get fullName => '$firstName $lastName'.trim();

  // Calcula dinamicamente a idade a partir da data de nascimento
  int get age {
    final now = DateTime.now();
    int calculatedAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      calculatedAge--;
    }
    return calculatedAge >= 0 ? calculatedAge : 0;
  }

  // Retorna a data de nascimento formatada como DD/MM/AAAA
  String get formattedBirthDate {
    final day = birthDate.day.toString().padLeft(2, '0');
    final month = birthDate.month.toString().padLeft(2, '0');
    final year = birthDate.year.toString();
    return '$day/$month/$year';
  }

  UserModel copyWith({
    String? id,
    String? accountId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? gender,
    String? gameOrigin,
    String? plan,
    String? preferredPronoun,
  }) {
    return UserModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      gameOrigin: gameOrigin ?? this.gameOrigin,
      plan: plan ?? this.plan,
      preferredPronoun: preferredPronoun ?? this.preferredPronoun,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'age': age,
      'gender': gender,
      'gameOrigin': gameOrigin,
      'plan': plan,
      'preferredPronoun': preferredPronoun,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedBirthDate = DateTime(2000, 1, 1);
    if (map['birthDate'] != null) {
      final parsed = DateTime.tryParse(map['birthDate']);
      if (parsed != null) {
        parsedBirthDate = parsed;
      }
    }

    return UserModel(
      id: map['id'] ?? '',
      accountId: map['accountId'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      birthDate: parsedBirthDate,
      gender: map['gender'] ?? 'Prefiro nao informar',
      gameOrigin: map['gameOrigin'] ?? 'TCG',
      plan: map['plan'] ?? 'Gratuito',
      preferredPronoun: map['preferredPronoun'] ?? 'Duelista',
    );
  }
}
