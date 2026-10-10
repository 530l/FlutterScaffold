import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../../core/dialog/app_toast.dart';
import '../../model/wellness_state.dart';
import '../../provider/wellness_provider.dart';

/// 页面保留自然留白,宽屏限制阅读宽度,小屏可完整滚动。
class WellnessPage extends StatelessWidget {
  const WellnessPage({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: children,
        ),
      ),
    ),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      children: [
        Expanded(
          child: _HeadingText(title: title, subtitle: subtitle),
        ),
        // Dart 3.8 起，空感知集合元素会跳过 null，无需使用 !。
        ?action,
      ],
    ),
  );
}

class WellnessCard extends StatelessWidget {
  const WellnessCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? TDTheme.of(context).bgColorContainer,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: TDTheme.of(context).componentBorderColor.withValues(alpha: .6),
      ),
    ),
    child: child,
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

IconData categoryIcon(HabitCategory category) => switch (category) {
  HabitCategory.body => TDIcons.sunny,
  HabitCategory.mind => TDIcons.book,
  HabitCategory.rest => TDIcons.heart,
};

/// 标签只展示分类,点击与选中由页面自身管理。
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TDTag(
            label,
            shape: TDTagShape.round,
            size: TDTagSize.large,
            backgroundColor: selected
                ? td.brandNormalColor
                : td.bgColorSecondaryContainer,
            textColor: selected ? td.bgColorPage : td.textColorSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          ),
        ),
      ),
    );
  }
}

/// 存储异常在交互处显示,保持页面可继续操作并允许重试。
Future<bool> saveWellness(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
    if (context.mounted && success != null) {
      AppToast.success(success);
    }
    return true;
  } catch (error) {
    if (context.mounted) {
      final message = switch (error) {
        ArgumentError(:final message) => '$message',
        StateError(:final message) => message,
        _ => '暂时没能保存，请再试一次',
      };
      AppToast.error(message);
    }
    return false;
  }
}

/// 打卡结果由共享 provider 管理,首页和习惯页会同时更新。
class HabitTile extends ConsumerWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.day,
    this.onEdit,
  });
  final Habit habit;
  final DateTime day;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = habit.completedOn(day);
    final saving = ref.watch(
      wellnessProvider.select((s) => s.isSaving || s.loadFailed),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WellnessCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        child: Row(
          children: [
            _HabitIcon(category: habit.category),
            const SizedBox(width: 14),
            Expanded(
              child: _HabitDescription(habit: habit, done: done),
            ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                tooltip: '编辑习惯',
                icon: const Icon(TDIcons.edit, size: 19),
              ),
            _HabitCheck(
              habit: habit,
              done: done,
              saving: saving,
              onChanged: () => saveWellness(
                context,
                () => ref
                    .read(wellnessProvider.notifier)
                    .toggleHabit(habit.id, day),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmallStat extends StatelessWidget {
  const SmallStat({super.key, required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 7),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: TDTheme.of(context).textColorSecondary,
        ),
      ),
    ],
  );
}

class _HeadingText extends StatelessWidget {
  const _HeadingText({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: TDTheme.of(context).textColorSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _HabitIcon extends StatelessWidget {
  const _HabitIcon({required this.category});
  final HabitCategory category;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: td.brandLightColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(categoryIcon(category), color: td.brandNormalColor, size: 23),
    );
  }
}

class _HabitDescription extends StatelessWidget {
  const _HabitDescription({required this.habit, required this.done});
  final Habit habit;
  final bool done;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          habit.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: done ? td.textColorSecondary : td.textColorPrimary,
            decoration: done ? TextDecoration.lineThrough : null,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '${habit.category.label} · ${habit.minutes} 分钟',
          style: TextStyle(fontSize: 12, color: td.textColorSecondary),
        ),
      ],
    );
  }
}

class _HabitCheck extends StatelessWidget {
  const _HabitCheck({
    required this.habit,
    required this.done,
    required this.saving,
    required this.onChanged,
  });
  final Habit habit;
  final bool done;
  final bool saving;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${habit.title}，${done ? '已完成' : '未完成'}',
      child: SizedBox(
        width: 44,
        child: _CheckControl(
          habit: habit,
          done: done,
          saving: saving,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CheckControl extends StatelessWidget {
  const _CheckControl({
    required this.habit,
    required this.done,
    required this.saving,
    required this.onChanged,
  });
  final Habit habit;
  final bool done;
  final bool saving;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) {
    return TDCheckbox(
      key: ValueKey('${habit.id}:$done:$saving'),
      checked: done,
      enable: !saving,
      style: TDCheckboxStyle.circle,
      showDivider: false,
      insetSpacing: 0,
      spacing: 0,
      checkBoxLeftSpace: 0,
      customSpace: const EdgeInsets.symmetric(vertical: 12),
      backgroundColor: Colors.transparent,
      customContentBuilder: (_, _, _) => const SizedBox.shrink(),
      onCheckBoxChanged: (_) => onChanged(),
    );
  }
}

/// 表单统一处理键盘避让，页面只需要按顺序声明字段。
class WellnessForm extends StatelessWidget {
  const WellnessForm({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AnimatedPadding(
    duration: const Duration(milliseconds: 180),
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}

class WellnessEmpty extends StatelessWidget {
  const WellnessEmpty({
    super.key,
    required this.icon,
    required this.text,
    required this.actionText,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 40),
  });
  final IconData icon;
  final String text;
  final String actionText;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: TDEmpty(
      icon: icon,
      emptyText: text,
      operationText: actionText,
      onTapEvent: onTap,
    ),
  );
}

/// 两个页面共用统计排版，统计数据由调用方提供。
class StatsCard extends StatelessWidget {
  const StatsCard({super.key, required this.stats});
  final List<SmallStat> stats;

  @override
  Widget build(BuildContext context) => WellnessCard(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: stats,
    ),
  );
}

/// 所有时长设置共用同一范围和刻度。
class MinutesSelector extends StatelessWidget {
  const MinutesSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      TDSlider(
        value: value,
        leftLabel: '5',
        rightLabel: '60',
        sliderThemeData: TDSliderThemeData(
          context: context,
          min: 5,
          max: 60,
          divisions: 11,
        ),
        onChanged: onChanged,
      ),
    ],
  );
}

/// 提示卡片的图标和文案布局。
class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => WellnessCard(
    color: TDTheme.of(context).brandLightColor,
    child: Row(
      children: [
        Icon(icon, size: 30),
        const SizedBox(width: 16),
        Expanded(
          child: _MessageText(title: title, subtitle: subtitle),
        ),
      ],
    ),
  );
}

class _MessageText extends StatelessWidget {
  const _MessageText({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 7),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          height: 1.7,
          color: TDTheme.of(context).textColorSecondary,
        ),
      ),
    ],
  );
}
