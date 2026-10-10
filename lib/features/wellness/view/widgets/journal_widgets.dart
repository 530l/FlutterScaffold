import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../../core/dialog/app_dialog.dart';
import '../../model/mood.dart';
import '../../model/wellness_state.dart';
import '../../provider/wellness_provider.dart';
import 'wellness_widgets.dart';

/// 列表只排列卡片，每张卡片负责自己的展示和删除确认。
class JournalCard extends ConsumerWidget {
  const JournalCard({super.key, required this.entry});
  final JournalEntry entry;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: '删除这篇手记？',
      content: '删除后无法恢复。',
      confirmText: '删除',
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    await saveWellness(
      context,
      () => ref.read(wellnessProvider.notifier).deleteEntry(entry.id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabled = ref.watch(
      wellnessProvider.select((s) => s.isSaving || s.loadFailed),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: WellnessCard(
        child: _JournalContent(
          entry: entry,
          onDelete: disabled ? null : () => _delete(context, ref),
        ),
      ),
    );
  }
}

class _JournalContent extends StatelessWidget {
  const _JournalContent({required this.entry, required this.onDelete});
  final JournalEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _JournalHeader(entry: entry, onDelete: onDelete),
      const SizedBox(height: 16),
      Text(
        entry.text,
        style: TextStyle(
          fontSize: 15,
          height: 1.85,
          color: TDTheme.of(context).textColorPrimary,
        ),
      ),
    ],
  );
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({required this.entry, required this.onDelete});
  final JournalEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(moodSymbols[entry.mood], style: const TextStyle(fontSize: 26)),
      const SizedBox(width: 12),
      Expanded(child: _JournalTimestamp(date: entry.createdAt)),
      TDTag(
        moodLabels[entry.mood],
        shape: TDTagShape.round,
        size: TDTagSize.small,
        theme: TDTagTheme.primary,
        isLight: true,
      ),
      IconButton(
        tooltip: '删除手记',
        icon: const Icon(TDIcons.delete, size: 18),
        onPressed: onDelete,
      ),
    ],
  );
}

class _JournalTimestamp extends StatelessWidget {
  const _JournalTimestamp({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${date.month} 月 ${date.day} 日',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      Text(
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          fontSize: 11,
          color: TDTheme.of(context).textColorSecondary,
        ),
      ),
    ],
  );
}

class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('现在的心情', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      Row(
        children: [
          for (var index = 0; index < moodLabels.length; index++)
            Expanded(
              child: _MoodOption(
                index: index,
                selected: value == index,
                onTap: () => onChanged(index),
              ),
            ),
        ],
      ),
    ],
  );
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: moodLabels[index],
    button: true,
    selected: selected,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: _MoodSurface(index: index, selected: selected),
    ),
  );
}

class _MoodSurface extends StatelessWidget {
  const _MoodSurface({required this.index, required this.selected});
  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: selected ? td.brandLightColor : td.bgColorSecondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? td.brandNormalColor : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Text(moodSymbols[index], style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          Text(
            moodShortLabels[index],
            style: TextStyle(fontSize: 11, color: td.textColorSecondary),
          ),
        ],
      ),
    );
  }
}
