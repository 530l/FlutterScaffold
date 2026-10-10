import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../model/wellness_state.dart';
import '../provider/wellness_provider.dart';
import 'habit_editor.dart';
import 'widgets/wellness_widgets.dart';

class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});
  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> {
  String _query = '';
  int _category = 0;

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    final state = ref.watch(wellnessProvider);
    final today = ref.watch(currentDayProvider);
    final habits = state.habits
        .where(
          (h) =>
              (_category == 0 ||
                  h.category == HabitCategory.values[_category - 1]) &&
              h.title.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList();
    return WellnessPage(
      children: [
        PageHeading(
          title: '小习惯',
          subtitle: '不求一次改变，只求每天靠近一点。',
          action: TDButton(
            icon: TDIcons.add,
            shape: TDButtonShape.circle,
            theme: TDButtonTheme.primary,
            onTap: () => showHabitEditor(context),
          ),
        ),
        StatsCard(
          stats: [
            SmallStat(value: '${state.habits.length}', label: '正在养成'),
            SmallStat(value: '${state.completedOn(today)}', label: '今日完成'),
            SmallStat(value: '${state.totalCheckIns}', label: '累计打卡'),
          ],
        ),
        const SizedBox(height: 22),
        TDSearchBar(
          placeHolder: '找一件喜欢的小事',
          style: TDSearchStyle.round,
          padding: EdgeInsets.zero,
          backgroundColor: td.bgColorContainer,
          onTextChanged: (text) => setState(() => _query = text),
          onClearClick: (_) {
            setState(() => _query = '');
            return false;
          },
        ),
        const SizedBox(height: 16),
        _HabitFilterTabs(
          onChanged: (index) => setState(() => _category = index),
        ),
        const SizedBox(height: 20),
        if (habits.isEmpty)
          WellnessEmpty(
            icon: TDIcons.book,
            text: _query.isNotEmpty ? '没有找到这件小事' : '这里还没有习惯',
            actionText: '添加习惯',
            onTap: () => showHabitEditor(context),
          ),
        ...habits.map(
          (h) => HabitTile(
            habit: h,
            day: today,
            onEdit: () => showHabitEditor(context, habit: h),
          ),
        ),
        const SizedBox(height: 16),
        TDButton(
          text: '种下一个新习惯',
          icon: TDIcons.add,
          isBlock: true,
          type: TDButtonType.outline,
          shape: TDButtonShape.round,
          theme: TDButtonTheme.primary,
          disabled: state.isSaving || state.loadFailed,
          onTap: () => showHabitEditor(context),
        ),
      ],
    );
  }
}

class _HabitFilterTabs extends StatelessWidget {
  const _HabitFilterTabs({required this.onChanged});
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return DefaultTabController(
      length: 4,
      // 使用公开导出的 TDTabBar，内部的 TDHorizontalTabBar 不属于公共接口。
      child: TDTabBar(
        tabs: const [
          TDTab(text: '全部'),
          TDTab(text: '生活'),
          TDTab(text: '成长'),
          TDTab(text: '留白'),
        ],
        labelColor: td.brandNormalColor,
        unselectedLabelColor: td.textColorSecondary,
        indicatorColor: td.brandNormalColor,
        showIndicator: true,
        backgroundColor: td.bgColorPage,
        dividerHeight: 0,
        onTap: onChanged,
      ),
    );
  }
}
