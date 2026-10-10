import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/wellness_state.dart';

part 'wellness_provider.g.dart';

/// 本地存储单独注入,页面和控制器不直接访问存储插件。
class WellnessRepository {
  Future<WellnessState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('slow_life_v1');
    if (raw == null) return WellnessState.seed();
    return WellnessState.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  Future<void> save(WellnessState state) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      if (!await prefs.setString('slow_life_v1', jsonEncode(state.toJson()))) {
        throw StateError('本地保存失败');
      }
    } catch (_) {
      // 插件可能在写入完成前更新内存缓存,失败时重新读取持久化数据。
      await prefs.reload();
      rethrow;
    }
  }
}

// 函数名原样保留，再追加 Provider：wellnessRepository → wellnessRepositoryProvider。
// 注解生成 provider；ref 获取依赖，ProviderScope 可覆盖依赖，例如启动时注入仓库。
// keepAlive: true 让仓库在根作用域内保持可用。
@Riverpod(keepAlive: true)
WellnessRepository wellnessRepository(Ref ref) => WellnessRepository();

/// 启动时覆盖恢复的初值；默认值让独立页面和测试作用域也能使用。
@Riverpod(keepAlive: true)
WellnessState initialWellnessState(Ref ref) => WellnessState.seed();

/// 类负责可修改的业务状态，持久化成功后才提交新状态。
/// 类名首字母转小写，再追加 Provider：Wellness → wellnessProvider。
/// _$Wellness 是生成的基类；build 返回初值，页面通过 notifier 调用修改方法。
@Riverpod(keepAlive: true)
class Wellness extends _$Wellness {
  @override
  WellnessState build() => ref.watch(initialWellnessStateProvider);

  Future<void> _commit(WellnessState Function(WellnessState) change) async {
    if (state.isSaving) throw StateError('正在保存,请稍候');
    // 恢复失败时保留原始存储,避免用空状态覆盖用户的数据。
    if (state.loadFailed) throw StateError('数据未能读取,请重启应用后再试');
    final previous = state;
    final next = change(previous);
    state = previous.copyWith(isSaving: true);
    try {
      await ref.read(wellnessRepositoryProvider).save(next);
      if (ref.mounted) state = next;
    } catch (_) {
      if (ref.mounted) state = previous;
      rethrow;
    }
  }

  Future<void> toggleHabit(String id, DateTime day) => _commit(
    (s) => s.copyWith(
      habits: s.habits.map((h) => h.id == id ? h.toggle(day) : h).toList(),
    ),
  );

  Future<void> saveHabit({
    String? id,
    required String title,
    required HabitCategory category,
    required int minutes,
  }) => _commit((s) {
    final text = title.trim();
    if (text.isEmpty || text.length > 24) {
      throw ArgumentError('习惯名称需为 1–24 个字');
    }
    final habit = Habit(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: text,
      category: category,
      minutes: minutes.clamp(5, 60).toInt(),
      completedDays: id == null
          ? []
          : s.habits.firstWhere((h) => h.id == id).completedDays,
    );
    return s.copyWith(
      habits: id == null
          ? [...s.habits, habit]
          : s.habits.map((h) => h.id == id ? habit : h).toList(),
    );
  });

  Future<void> deleteHabit(String id) => _commit(
    (s) => s.copyWith(habits: s.habits.where((h) => h.id != id).toList()),
  );

  Future<void> addEntry(String text, int mood) => _commit((s) {
    final content = text.trim();
    if (content.isEmpty || content.length > 500) {
      throw ArgumentError('手记需为 1–500 个字');
    }
    final now = DateTime.now();
    return s.copyWith(
      entries: [
        JournalEntry(
          id: now.microsecondsSinceEpoch.toString(),
          text: content,
          mood: mood.clamp(0, 4).toInt(),
          createdAt: now,
        ),
        ...s.entries,
      ],
    );
  });

  Future<void> deleteEntry(String id) => _commit(
    (s) => s.copyWith(entries: s.entries.where((e) => e.id != id).toList()),
  );

  Future<void> recordFocus(int minutes) => _commit(
    (s) => s.copyWith(
      sessions: [
        ...s.sessions,
        FocusSession(minutes: minutes, completedAt: DateTime.now()),
      ],
    ),
  );

  Future<void> setDarkMode(bool value) =>
      _commit((s) => s.copyWith(darkMode: value));
  Future<void> setFocusMinutes(int value) =>
      _commit((s) => s.copyWith(focusMinutes: value.clamp(5, 60).toInt()));
}

/// 跨过午夜后更新日期,页面无需重启即可开始新一天的打卡。
@Riverpod(keepAlive: true)
class CurrentDay extends _$CurrentDay {
  @override
  DateTime build() {
    final timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final now = DateTime.now();
      if (ref.mounted && dayKey(state) != dayKey(now)) {
        state = DateTime(now.year, now.month, now.day);
      }
    });
    ref.onDispose(timer.cancel);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
