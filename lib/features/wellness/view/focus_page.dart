import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_dialog.dart';
import '../provider/wellness_provider.dart';
import 'widgets/focus_widgets.dart';
import 'widgets/wellness_widgets.dart';

/// 倒计时使用截止时间计算,返回前台时补上后台流逝的时间。
class FocusPage extends ConsumerStatefulWidget {
  const FocusPage({super.key});
  @override
  ConsumerState<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends ConsumerState<FocusPage>
    with WidgetsBindingObserver {
  late int _minutes;
  late int _remaining;
  Timer? _timer;
  DateTime? _deadline;
  bool _running = false;
  bool _started = false;
  bool _finished = false;
  bool _saved = false;
  bool _saving = false;
  bool _allowExit = false;
  bool _confirmingExit = false;

  @override
  void initState() {
    super.initState();
    _minutes = ref.read(wellnessProvider).focusMinutes;
    _remaining = _minutes * 60;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _running) _tick();
  }

  void _tick() {
    final deadline = _deadline;
    if (!mounted || !_running || deadline == null) return;
    final seconds = (deadline.difference(DateTime.now()).inMilliseconds / 1000)
        .ceil()
        .clamp(0, _minutes * 60)
        .toInt();
    setState(() => _remaining = seconds);
    if (seconds == 0) {
      _timer?.cancel();
      setState(() {
        _running = false;
        _finished = true;
      });
      unawaited(_saveSession());
    }
  }

  void _toggle() {
    if (_running) {
      _tick();
      if (_finished) return;
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      _deadline = DateTime.now().add(Duration(seconds: _remaining));
      setState(() {
        _started = true;
        _running = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  Future<void> _saveSession() async {
    if (_saved || _saving) return;
    setState(() => _saving = true);
    final ok = await saveWellness(
      context,
      () => ref.read(wellnessProvider.notifier).recordFocus(_minutes),
      success: '这段时间，完整地属于你',
    );
    if (mounted) {
      setState(() {
        _saving = false;
        _saved = ok;
      });
    }
  }

  Future<void> _exit() async {
    // 连续返回只展示一个确认框，避免多个回调重复退出路由。
    if (_confirmingExit || _saving || _allowExit) return;
    _confirmingExit = true;
    try {
      final confirmed = await AppDialog.confirm(
        context,
        title: '结束这次专注？',
        content: '离开后，尚未保存的记录不会计入统计。',
        confirmText: '结束专注',
        cancelText: '继续专注',
      );
      if (!mounted || !confirmed || _saving) return;
      setState(() => _allowExit = true);
      // 等待返回拦截条件更新后再退出,兼容系统返回和导航栏返回。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    } finally {
      _confirmingExit = false;
    }
  }

  void _handleAction() {
    if (!_finished) {
      _toggle();
    } else if (_saved) {
      Navigator.pop(context);
    } else {
      unawaited(_saveSession());
    }
  }

  void _setMinutes(double value) => setState(() {
    _minutes = value.round();
    _remaining = _minutes * 60;
  });

  @override
  Widget build(BuildContext context) {
    // 是否开始过不能只看剩余秒数：首秒内暂停也应保持时长并允许继续。
    final started = _started;
    final display =
        '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}';
    final content = WellnessPage(
      children: [
        const SizedBox(height: 20),
        const PageHeading(title: '世界可以等一会儿', subtitle: '放下分心，把注意力还给当下。'),
        FocusDial(
          minutes: _minutes,
          remaining: _remaining,
          display: display,
          finished: _finished,
          running: _running,
          started: started,
        ),
        const SizedBox(height: 35),
        if (!started)
          WellnessCard(
            child: MinutesSelector(
              label: '这次专注 $_minutes 分钟',
              value: _minutes.toDouble(),
              onChanged: _setMinutes,
            ),
          ),
        const SizedBox(height: 24),
        TDButton(
          text: _actionText(started),
          icon: switch ((_finished, _running)) {
            (true, _) => null,
            (_, true) => TDIcons.pause,
            _ => TDIcons.play,
          },
          disabled: _saving,
          isBlock: true,
          shape: TDButtonShape.round,
          theme: TDButtonTheme.primary,
          size: TDButtonSize.large,
          onTap: _handleAction,
        ),
        const SizedBox(height: 28),
        const FocusReminder(),
      ],
    );

    return PopScope(
      canPop: _allowExit || (!started && !_saving) || (_finished && _saved),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_saving) unawaited(_exit());
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('专注时刻')),
        body: content,
      ),
    );
  }

  String _actionText(bool started) {
    if (_saving) return '正在保存…';
    if (_finished) return _saved ? '带着好状态回去' : '重新保存记录';
    if (_running) return '暂停一下';
    return started ? '继续专注' : '开始专注';
  }
}
