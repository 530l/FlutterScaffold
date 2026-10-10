import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_dialog.dart';
import '../../../core/dialog/app_toast.dart';
import '../model/mood.dart';
import '../model/wellness_state.dart';
import '../provider/wellness_provider.dart';
import 'focus_settings_sheet.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/wellness_widgets.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _copyRecords(BuildContext context, WellnessState state) async {
    final text = StringBuffer('慢慢 · 我的生活记录\n\n习惯\n');
    for (final habit in state.habits) {
      text.writeln(
        '${habit.title} · ${habit.category.label} · ${habit.minutes} 分钟',
      );
      text.writeln(
        '打卡日期：${habit.completedDays.isEmpty ? '暂无' : habit.completedDays.join('、')}',
      );
    }
    text.writeln('\n手记');
    for (final entry in state.entries) {
      text.writeln(
        '${dayKey(entry.createdAt)} · ${moodLabels[entry.mood]}\n${entry.text}\n',
      );
    }
    text.writeln('\n专注');
    for (final session in state.sessions) {
      text.writeln('${dayKey(session.completedAt)} · ${session.minutes} 分钟');
    }
    try {
      await Clipboard.setData(ClipboardData(text: text.toString()));
      if (context.mounted) AppToast.success('已复制，可以粘贴到你的备忘录');
    } catch (_) {
      if (context.mounted) AppToast.error('暂时没能复制，请再试一次');
    }
  }

  void _showAbout(BuildContext context) {
    final td = TDTheme.of(context);
    AppDialog.show<void>(
      context,
      child: TDAlertDialog(
        title: '慢慢',
        content: '习惯、专注，还有值得留下的日常。\n\n记录只保存在这台设备，不需要注册或登录。\n每天一点点，就是很好的生活。',
        backgroundColor: td.bgColorContainer,
        radius: 24,
        rightBtn: TDDialogButtonOptions(
          title: '知道了',
          theme: TDButtonTheme.primary,
          action: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wellnessProvider);
    final today = ref.watch(currentDayProvider);
    return WellnessPage(
      children: [
        const PageHeading(title: '我的小世界', subtitle: '认真生活的你，已经很棒了。'),
        const ProfileIdentityCard(),
        const SizedBox(height: 16),
        StatsCard(
          stats: [
            SmallStat(value: '${state.totalCheckIns}', label: '次小小坚持'),
            SmallStat(value: '${state.totalFocusMinutes}', label: '分钟专注'),
            SmallStat(value: '${state.entries.length}', label: '页生活手记'),
          ],
        ),
        const SectionHeading('这一周的脚印'),
        WeeklyActivityCard(state: state, today: today),
        const SectionHeading('让这里更像你'),
        ProfileSettingsCard(
          state: state,
          onDarkMode: (value) => saveWellness(
            context,
            () => ref.read(wellnessProvider.notifier).setDarkMode(value),
          ),
          onFocusSettings: () => showFocusSettings(context),
          onCopyRecords: () => _copyRecords(context, state),
          onAbout: () => _showAbout(context),
        ),
        const SizedBox(height: 28),
        const LocalPrivacyNote(),
      ],
    );
  }
}
