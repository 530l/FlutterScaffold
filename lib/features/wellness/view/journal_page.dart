import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_bottom_sheet.dart';
import '../provider/wellness_provider.dart';
import 'widgets/journal_widgets.dart';
import 'widgets/wellness_widgets.dart';

Future<void> showJournalComposer(BuildContext context) =>
    AppBottomSheet.show<void>(context, child: const _JournalComposer());

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(
      wellnessProvider.select((state) => state.entries),
    );
    return WellnessPage(
      children: [
        PageHeading(
          title: '生活手记',
          subtitle: '把普通的一天，认真收藏起来。',
          action: TDButton(
            text: '写一页',
            icon: TDIcons.edit,
            shape: TDButtonShape.round,
            theme: TDButtonTheme.primary,
            size: TDButtonSize.small,
            onTap: () => showJournalComposer(context),
          ),
        ),
        const MessageCard(
          icon: TDIcons.book,
          title: '今天有什么值得记住？',
          subtitle: '一顿好吃的饭，一次散步，或一个念头。',
        ),
        SectionHeading('属于你的 ${entries.length} 页'),
        if (entries.isEmpty)
          WellnessEmpty(
            icon: TDIcons.edit,
            text: '这里留着，等你的第一篇手记',
            actionText: '写下今天',
            padding: const EdgeInsets.symmetric(vertical: 48),
            onTap: () => showJournalComposer(context),
          ),
        ...entries.map((entry) => JournalCard(entry: entry)),
      ],
    );
  }
}

/// 表单草稿保留在弹层内,保存成功后再关闭。
class _JournalComposer extends ConsumerStatefulWidget {
  const _JournalComposer();
  @override
  ConsumerState<_JournalComposer> createState() => _JournalComposerState();
}

class _JournalComposerState extends ConsumerState<_JournalComposer> {
  final _text = TextEditingController();
  int _mood = 2;
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await saveWellness(
      context,
      () => ref.read(wellnessProvider.notifier).addEntry(_text.text, _mood),
      success: '今天，已经被好好收藏',
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
      const PageHeading(title: '写下这一刻', subtitle: '不用写得漂亮，写真实的自己就好。'),
      MoodPicker(
        value: _mood,
        onChanged: (value) => setState(() => _mood = value),
      ),
      const SizedBox(height: 22),
      _JournalTextField(controller: _text),
      const SizedBox(height: 24),
      TDButton(
        text: _busy ? '正在收藏…' : '收藏这一页',
        isBlock: true,
        disabled: _busy,
        shape: TDButtonShape.round,
        size: TDButtonSize.large,
        theme: TDButtonTheme.primary,
        onTap: _save,
      ),
    ],
  );
}

class _JournalTextField extends StatelessWidget {
  const _JournalTextField({required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) => TDTextarea(
    controller: controller,
    hintText: '今天，我想记住……',
    maxLength: 500,
    indicator: true,
    minLines: 5,
    maxLines: 8,
    backgroundColor: TDTheme.of(context).bgColorSecondaryContainer,
    showBottomDivider: false,
    padding: const EdgeInsets.all(16),
  );
}
