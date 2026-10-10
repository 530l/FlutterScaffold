/// 使用本地日期作为打卡键,避免时区转换后日期偏移。
String dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

enum HabitCategory {
  body('好好生活'),
  mind('慢慢成长'),
  rest('留白时刻');

  const HabitCategory(this.label);
  final String label;
}

/// 一条习惯保留每天的打卡记录,不在跨日时清除历史。
final class Habit {
  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.minutes,
    List<String> completedDays = const [],
  }) : completedDays = List.unmodifiable(completedDays);

  final String id;
  final String title;
  final HabitCategory category;
  final int minutes;
  final List<String> completedDays;

  bool completedOn(DateTime day) => completedDays.contains(dayKey(day));

  Habit toggle(DateTime day) {
    final days = [...completedDays];
    final key = dayKey(day);
    if (days.contains(key)) {
      days.remove(key);
    } else {
      days.add(key);
    }
    return Habit(
      id: id,
      title: title,
      category: category,
      minutes: minutes,
      completedDays: days,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'minutes': minutes,
    'completedDays': completedDays,
  };

  factory Habit.fromJson(Map<String, Object?> json) => Habit(
    id: json['id'] as String,
    title: json['title'] as String,
    category: HabitCategory.values.byName(json['category'] as String),
    minutes: (json['minutes'] as num).toInt().clamp(5, 60).toInt(),
    completedDays: List<String>.from(json['completedDays'] as List<Object?>),
  );
}

/// 手记存储实际创建时间和心情,列表按新到旧展示。
final class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.text,
    required this.mood,
    required this.createdAt,
  });

  final String id;
  final String text;
  final int mood;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'mood': mood,
    'createdAt': createdAt.toIso8601String(),
  };

  factory JournalEntry.fromJson(Map<String, Object?> json) => JournalEntry(
    id: json['id'] as String,
    text: json['text'] as String,
    mood: (json['mood'] as num).toInt().clamp(0, 4).toInt(),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );
}

final class FocusSession {
  const FocusSession({required this.minutes, required this.completedAt});
  final int minutes;
  final DateTime completedAt;

  Map<String, Object?> toJson() => {
    'minutes': minutes,
    'completedAt': completedAt.toIso8601String(),
  };

  factory FocusSession.fromJson(Map<String, Object?> json) => FocusSession(
    minutes: (json['minutes'] as num).toInt(),
    completedAt: DateTime.parse(json['completedAt'] as String).toLocal(),
  );
}

/// 共享业务状态;搜索词、表单输入和倒计时仍留在各自页面内。
final class WellnessState {
  WellnessState({
    List<Habit> habits = const [],
    List<JournalEntry> entries = const [],
    List<FocusSession> sessions = const [],
    this.darkMode = false,
    this.focusMinutes = 25,
    this.isSaving = false,
    this.loadFailed = false,
  }) : habits = List.unmodifiable(habits),
       entries = List.unmodifiable(entries),
       sessions = List.unmodifiable(sessions);

  /// 仅在内部复用已冻结的列表，避免无关字段变化时触发列表订阅重建。
  WellnessState._({
    required this.habits,
    required this.entries,
    required this.sessions,
    required this.darkMode,
    required this.focusMinutes,
    required this.isSaving,
    required this.loadFailed,
  });

  factory WellnessState.seed() => WellnessState(
    habits: [
      Habit(
        id: 'read',
        title: '读几页喜欢的书',
        category: HabitCategory.mind,
        minutes: 20,
      ),
      Habit(
        id: 'walk',
        title: '出门走一小段路',
        category: HabitCategory.body,
        minutes: 15,
      ),
      Habit(
        id: 'breathe',
        title: '给自己一点留白',
        category: HabitCategory.rest,
        minutes: 5,
      ),
    ],
  );

  final List<Habit> habits;
  final List<JournalEntry> entries;
  final List<FocusSession> sessions;
  final bool darkMode;
  final int focusMinutes;
  final bool isSaving;
  final bool loadFailed;

  int completedOn(DateTime day) =>
      habits.where((h) => h.completedOn(day)).length;
  int get totalCheckIns =>
      habits.fold(0, (sum, h) => sum + h.completedDays.length);
  int get totalFocusMinutes => sessions.fold(0, (sum, s) => sum + s.minutes);

  WellnessState copyWith({
    List<Habit>? habits,
    List<JournalEntry>? entries,
    List<FocusSession>? sessions,
    bool? darkMode,
    int? focusMinutes,
    bool? isSaving,
    bool? loadFailed,
  }) => WellnessState._(
    habits: habits == null ? this.habits : List.unmodifiable(habits),
    entries: entries == null ? this.entries : List.unmodifiable(entries),
    sessions: sessions == null ? this.sessions : List.unmodifiable(sessions),
    darkMode: darkMode ?? this.darkMode,
    focusMinutes: focusMinutes ?? this.focusMinutes,
    isSaving: isSaving ?? this.isSaving,
    loadFailed: loadFailed ?? this.loadFailed,
  );

  Map<String, Object?> toJson() => {
    'habits': habits.map((h) => h.toJson()).toList(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'darkMode': darkMode,
    'focusMinutes': focusMinutes,
  };

  factory WellnessState.fromJson(Map<String, Object?> json) => WellnessState(
    habits: (json['habits'] as List<Object?>)
        .map((h) => Habit.fromJson(h as Map<String, Object?>))
        .toList(),
    entries: (json['entries'] as List<Object?>)
        .map((e) => JournalEntry.fromJson(e as Map<String, Object?>))
        .toList(),
    sessions: (json['sessions'] as List<Object?>)
        .map((s) => FocusSession.fromJson(s as Map<String, Object?>))
        .toList(),
    darkMode: json['darkMode'] as bool,
    focusMinutes: (json['focusMinutes'] as num).toInt().clamp(5, 60).toInt(),
  );
}
