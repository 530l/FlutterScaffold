import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../model/wellness_state.dart';
import 'wellness_widgets.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return WellnessCard(
      child: Row(
        children: [
          TDAvatar(
            type: TDAvatarType.icon,
            icon: TDIcons.heart,
            size: TDAvatarSize.large,
            backgroundColor: td.brandLightColor,
          ),
          const SizedBox(width: 18),
          const Expanded(child: _ProfileIdentity()),
        ],
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '生活的收藏家',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '把时间，花在喜欢的事情上。',
          style: TextStyle(fontSize: 12, color: td.textColorSecondary),
        ),
        const SizedBox(height: 12),
        const TDTag(
          '自在生长中',
          shape: TDTagShape.round,
          size: TDTagSize.small,
          theme: TDTagTheme.primary,
          isLight: true,
        ),
      ],
    );
  }
}

class WeeklyActivityCard extends StatelessWidget {
  const WeeklyActivityCard({
    super.key,
    required this.state,
    required this.today,
  });
  final WellnessState state;
  final DateTime today;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return WellnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '每一格，都记录着你的行动',
            style: TextStyle(fontSize: 12, color: td.textColorSecondary),
          ),
          const SizedBox(height: 20),
          _ActivityWeek(state: state, today: today),
        ],
      ),
    );
  }
}

class _ActivityWeek extends StatelessWidget {
  const _ActivityWeek({required this.state, required this.today});
  final WellnessState state;
  final DateTime today;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final date = DateTime(today.year, today.month, today.day - 6 + i);
        final count = state.completedOn(date);
        final fraction = state.habits.isEmpty
            ? 0.0
            : count / state.habits.length;
        return Expanded(
          child: _ActivityDay(date: date, count: count, fraction: fraction),
        );
      }),
    );
  }
}

class _ActivityDay extends StatelessWidget {
  const _ActivityDay({
    required this.date,
    required this.count,
    required this.fraction,
  });
  final DateTime date;
  final int count;
  final double fraction;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${date.month} 月 ${date.day} 日完成 $count 件习惯',
      child: _ActivityDayContent(date: date, count: count, fraction: fraction),
    );
  }
}

class _ActivityDayContent extends StatelessWidget {
  const _ActivityDayContent({
    required this.date,
    required this.count,
    required this.fraction,
  });
  final DateTime date;
  final int count;
  final double fraction;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 11, color: td.textColorSecondary),
        ),
        const SizedBox(height: 7),
        _ActivityBar(count: count, fraction: fraction),
        const SizedBox(height: 9),
        Text(
          '${date.day}',
          style: TextStyle(fontSize: 11, color: td.textColorSecondary),
        ),
      ],
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({required this.count, required this.fraction});
  final int count;
  final double fraction;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return SizedBox(
      height: 68,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          height: 8 + 60 * fraction,
          width: 20,
          decoration: BoxDecoration(
            color: count == 0 ? td.brandLightColor : td.brandNormalColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({
    super.key,
    required this.state,
    required this.onDarkMode,
    required this.onFocusSettings,
    required this.onCopyRecords,
    required this.onAbout,
  });
  final WellnessState state;
  final ValueChanged<bool> onDarkMode;
  final VoidCallback onFocusSettings;
  final VoidCallback onCopyRecords;
  final VoidCallback onAbout;
  @override
  Widget build(BuildContext context) {
    return WellnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TDCellGroup(
        cells: [
          TDCell(
            title: '夜间模式',
            leftIcon: TDIcons.moon,
            noteWidget: _DarkModeSwitch(
              value: state.darkMode,
              disabled: state.isSaving || state.loadFailed,
              onChanged: onDarkMode,
            ),
          ),
          TDCell(
            title: '专注时长',
            leftIcon: TDIcons.time,
            note: '${state.focusMinutes} 分钟',
            arrow: true,
            onClick: (_) => onFocusSettings(),
          ),
          TDCell(
            title: '复制生活记录',
            leftIcon: TDIcons.book,
            arrow: true,
            onClick: (_) => onCopyRecords(),
          ),
          TDCell(
            title: '关于慢慢',
            leftIcon: TDIcons.info_circle,
            arrow: true,
            bordered: false,
            onClick: (_) => onAbout(),
          ),
        ],
      ),
    );
  }
}

class _DarkModeSwitch extends StatelessWidget {
  const _DarkModeSwitch({
    required this.value,
    required this.disabled,
    required this.onChanged,
  });
  final bool value;
  final bool disabled;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return TDSwitch(
      isOn: value,
      enable: !disabled,
      onChanged: (value) {
        onChanged(value);
        // 保存后的共享状态决定开关显示，不提前切换内部状态。
        return true;
      },
    );
  }
}

class LocalPrivacyNote extends StatelessWidget {
  const LocalPrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(TDIcons.lock_on, size: 13, color: td.textColorSecondary),
          const SizedBox(width: 6),
          Text(
            '属于你的日常，只留在你身边',
            style: TextStyle(fontSize: 11, color: td.textColorSecondary),
          ),
        ],
      ),
    );
  }
}
