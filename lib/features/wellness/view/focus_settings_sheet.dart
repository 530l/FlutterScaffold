import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_bottom_sheet.dart';
import '../provider/wellness_provider.dart';
import 'widgets/wellness_widgets.dart';

Future<void> showFocusSettings(BuildContext context) =>
    AppBottomSheet.show<void>(context, child: const _FocusSettingsSheet());

/// 弹层拥有自己的草稿状态，避免把 StatefulBuilder 嵌进设置列表。
class _FocusSettingsSheet extends ConsumerStatefulWidget {
  const _FocusSettingsSheet();
  @override
  ConsumerState<_FocusSettingsSheet> createState() =>
      _FocusSettingsSheetState();
}

class _FocusSettingsSheetState extends ConsumerState<_FocusSettingsSheet> {
  late double _minutes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _minutes = ref.read(wellnessProvider).focusMinutes.toDouble();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await saveWellness(
      context,
      () =>
          ref.read(wellnessProvider.notifier).setFocusMinutes(_minutes.round()),
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
      const PageHeading(title: '你的专注步调', subtitle: '找到一个适合自己的时间长度。'),
      MinutesSelector(
        label: '默认 ${_minutes.round()} 分钟',
        value: _minutes,
        onChanged: _busy ? null : (value) => setState(() => _minutes = value),
      ),
      const SizedBox(height: 20),
      TDButton(
        text: _busy ? '正在保存…' : '保存设置',
        isBlock: true,
        disabled: _busy,
        shape: TDButtonShape.round,
        theme: TDButtonTheme.primary,
        onTap: _save,
      ),
    ],
  );
}
