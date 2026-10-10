import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_bottom_sheet.dart';
import '../../../core/dialog/app_dialog.dart';
import '../model/wellness_state.dart';
import '../provider/wellness_provider.dart';
import 'widgets/wellness_widgets.dart';

Future<void> showHabitEditor(BuildContext context, {Habit? habit}) =>
    AppBottomSheet.show<void>(context, child: HabitEditor(habit: habit));

/// 输入与滑块属于表单局部状态,保存时才写入共享业务状态。
class HabitEditor extends ConsumerStatefulWidget {
  const HabitEditor({super.key, this.habit});
  final Habit? habit;
  @override
  ConsumerState<HabitEditor> createState() => _HabitEditorState();
}

class _HabitEditorState extends ConsumerState<HabitEditor> {
  late final TextEditingController _title;
  late HabitCategory _category;
  late double _minutes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.habit?.title ?? '');
    _category = widget.habit?.category ?? HabitCategory.body;
    _minutes = (widget.habit?.minutes ?? 15).toDouble();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await saveWellness(
      context,
      () => ref
          .read(wellnessProvider.notifier)
          .saveHabit(
            id: widget.habit?.id,
            title: _title.text,
            category: _category,
            minutes: _minutes.round(),
          ),
      success: '习惯已保存',
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final habit = widget.habit;
    if (_busy || habit == null) return;
    setState(() => _busy = true);
    final confirmed = await AppDialog.confirm(
      context,
      title: '删除这个习惯？',
      content: '它的打卡记录也会一起删除。',
      confirmText: '删除',
      danger: true,
    );
    if (!mounted) return;
    if (!confirmed) {
      setState(() => _busy = false);
      return;
    }
    final ok = await saveWellness(
      context,
      () => ref.read(wellnessProvider.notifier).deleteHabit(habit.id),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => WellnessForm(
    children: [
      const _SheetHandle(),
      const SizedBox(height: 22),
      PageHeading(
        title: widget.habit == null ? '种下一个小习惯' : '调整一下步调',
        subtitle: '从一件很小的事开始，就很好。',
      ),
      _HabitNameField(controller: _title),
      const SizedBox(height: 20),
      _HabitCategoryField(
        value: _category,
        onChanged: (value) => setState(() => _category = value),
      ),
      const SizedBox(height: 20),
      MinutesSelector(
        label: '给它 ${_minutes.round()} 分钟',
        value: _minutes,
        onChanged: (value) => setState(() => _minutes = value),
      ),
      const SizedBox(height: 20),
      TDButton(
        text: _busy ? '正在保存…' : '保存习惯',
        isBlock: true,
        disabled: _busy,
        size: TDButtonSize.large,
        shape: TDButtonShape.round,
        theme: TDButtonTheme.primary,
        onTap: _save,
      ),
      if (widget.habit != null) ...[
        const SizedBox(height: 12),
        TDButton(
          text: '删除习惯',
          isBlock: true,
          disabled: _busy,
          type: TDButtonType.text,
          theme: TDButtonTheme.danger,
          onTap: _delete,
        ),
      ],
    ],
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: TDTheme.of(context).componentBorderColor,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class _HabitNameField extends StatelessWidget {
  const _HabitNameField({required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) => TDInput(
    controller: controller,
    hintText: '例如：睡前读十页书',
    maxLength: 24,
    inputFormatters: [LengthLimitingTextInputFormatter(24)],
    backgroundColor: TDTheme.of(context).bgColorSecondaryContainer,
    showBottomDivider: false,
    onClearTap: controller.clear,
  );
}

class _HabitCategoryField extends StatelessWidget {
  const _HabitCategoryField({required this.value, required this.onChanged});
  final HabitCategory value;
  final ValueChanged<HabitCategory> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('属于哪一种时刻', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final category in HabitCategory.values)
            CategoryChip(
              label: category.label,
              selected: value == category,
              onTap: () => onChanged(category),
            ),
        ],
      ),
    ],
  );
}
