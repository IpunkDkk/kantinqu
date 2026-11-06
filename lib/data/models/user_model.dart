class UserModel {
  final String id;
  final String name;
  final String email;
  final String title;
  final String avatarUrl;
  final double focusHoursThisWeek;
  final bool enableGentleReminders;
  final String reminderSound;

  const UserModel({
    required this.id,
    this.name = 'Amanda',
    this.email = 'amanda.mindful@myplan.app',
    this.title = 'Penanam Sadar (Mindful Planter)',
    this.avatarUrl = '',
    this.focusHoursThisWeek = 18.5,
    this.enableGentleReminders = true,
    this.reminderSound = 'Alunan Chime Lembut',
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? title,
    String? avatarUrl,
    double? focusHoursThisWeek,
    bool? enableGentleReminders,
    String? reminderSound,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      focusHoursThisWeek: focusHoursThisWeek ?? this.focusHoursThisWeek,
      enableGentleReminders:
          enableGentleReminders ?? this.enableGentleReminders,
      reminderSound: reminderSound ?? this.reminderSound,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'title': title,
      'avatarUrl': avatarUrl,
      'focusHoursThisWeek': focusHoursThisWeek,
      'enableGentleReminders': enableGentleReminders,
      'reminderSound': reminderSound,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? 'user_amanda',
      name: map['name'] as String? ?? 'Amanda',
      email: map['email'] as String? ?? 'amanda.mindful@myplan.app',
      title: map['title'] as String? ?? 'Penanam Sadar (Mindful Planter)',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      focusHoursThisWeek: (map['focusHoursThisWeek'] as num?)?.toDouble() ?? 18.5,
      enableGentleReminders: map['enableGentleReminders'] as bool? ?? true,
      reminderSound: map['reminderSound'] as String? ?? 'Alunan Chime Lembut',
    );
  }
}
