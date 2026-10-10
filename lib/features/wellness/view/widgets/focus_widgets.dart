import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class FocusDial extends StatelessWidget {
  const FocusDial({
    super.key,
    required this.minutes,
    required this.remaining,
    required this.display,
    required this.finished,
    required this.running,
    required this.started,
  });
  final int minutes;
  final int remaining;
  final String display;
  final bool finished;
  final bool running;
  final bool started;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 248,
        height: 248,
        child: _FocusRing(
          minutes: minutes,
          remaining: remaining,
          display: display,
          finished: finished,
          running: running,
          started: started,
        ),
      ),
    );
  }
}

class _FocusRing extends StatelessWidget {
  const _FocusRing({
    required this.minutes,
    required this.remaining,
    required this.display,
    required this.finished,
    required this.running,
    required this.started,
  });
  final int minutes;
  final int remaining;
  final String display;
  final bool finished;
  final bool running;
  final bool started;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        TDProgress(
          type: TDProgressType.circular,
          value: 1 - remaining / (minutes * 60),
          circleRadius: 248,
          strokeWidth: 8,
          showLabel: false,
          color: td.brandNormalColor,
          backgroundColor: td.brandLightColor,
        ),
        _FocusClock(
          display: display,
          finished: finished,
          running: running,
          started: started,
        ),
      ],
    );
  }
}

class _FocusClock extends StatelessWidget {
  const _FocusClock({
    required this.display,
    required this.finished,
    required this.running,
    required this.started,
  });
  final String display;
  final bool finished;
  final bool running;
  final bool started;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(finished ? TDIcons.check_circle : TDIcons.time, size: 27),
        const SizedBox(height: 14),
        Text(
          display,
          style: const TextStyle(
            fontSize: 49,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 10),
        Text(switch ((finished, running, started)) {
          (true, _, _) => '完成一段好时光',
          (_, true, _) => '安心做眼前的事',
          (_, _, true) => '歇一下，也没关系',
          _ => '准备好，就开始',
        }, style: TextStyle(fontSize: 12, color: td.textColorSecondary)),
      ],
    );
  }
}

class FocusReminder extends StatelessWidget {
  const FocusReminder({super.key});

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Center(
      child: Text(
        '不必填满每一分钟，专注也是一种留白。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          height: 1.8,
          color: td.textColorSecondary,
        ),
      ),
    );
  }
}
