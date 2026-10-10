import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../model/wellness_state.dart';
import '../provider/wellness_provider.dart';
import 'habit_editor.dart';
import 'widgets/today_widgets.dart';
import 'widgets/wellness_widgets.dart';

/// 页面只组合业务区块，区块内部的布局由独立组件负责。
class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});
  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(currentDayProvider);
    final state = ref.watch(wellnessProvider);
    final day = _selectedDay ?? today;
    final done = state.completedOn(day);
    final progress = state.habits.isEmpty ? 0.0 : done / state.habits.length;
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    return WellnessPage(
      children: [
        PageHeading(
          title: '慢慢',
          subtitle:
              '${today.month} 月 ${today.day} 日 · 星期${weekdays[today.weekday - 1]}',
          action: TDAvatar(
            type: TDAvatarType.icon,
            icon: TDIcons.sunny,
            backgroundColor: TDTheme.of(context).brandLightColor,
            size: TDAvatarSize.small,
          ),
        ),
        const TodayWelcomeCard(),
        const SizedBox(height: 22),
        RecentDaysPicker(
          today: today,
          day: day,
          state: state,
          onSelected: (date) => setState(() => _selectedDay = date),
          onToday: () => setState(() => _selectedDay = null),
        ),
        SectionHeading(
          dayKey(day) == dayKey(today)
              ? '今日的小事'
              : '${day.month} 月 ${day.day} 日的小事',
          trailing: TDButton(
            text: '添一件',
            icon: TDIcons.add,
            size: TDButtonSize.small,
            type: TDButtonType.text,
            theme: TDButtonTheme.primary,
            onTap: () => showHabitEditor(context),
          ),
        ),
        HabitProgressCard(
          done: done,
          total: state.habits.length,
          progress: progress,
        ),
        const SizedBox(height: 12),
        if (state.habits.isEmpty)
          WellnessEmpty(
            icon: TDIcons.flag,
            text: '从一个小习惯开始',
            actionText: '添加习惯',
            padding: const EdgeInsets.all(24),
            onTap: () => showHabitEditor(context),
          ),
        ...state.habits.map((h) => HabitTile(habit: h, day: day)),
        const SizedBox(height: 8),
        const FocusInvitationCard(),
        const SizedBox(height: 22),
        LocalDataNotice(loadFailed: state.loadFailed),
      ],
    );
  }
}
