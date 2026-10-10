import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../../core/router/route_names.dart';
import '../../model/wellness_state.dart';
import 'wellness_widgets.dart';

class TodayWelcomeCard extends StatelessWidget {
  const TodayWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return WellnessCard(
      color: td.brandLightColor,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Expanded(child: _WelcomeCopy()),
          const SizedBox(width: 8),
          const SizedBox(
            width: 96,
            height: 154,
            child: CustomPaint(painter: _PlantPainter()),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCopy extends StatelessWidget {
  const _WelcomeCopy();

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TDTag(
          '一天一点点',
          shape: TDTagShape.round,
          isLight: true,
          theme: TDTagTheme.primary,
          size: TDTagSize.small,
        ),
        const SizedBox(height: 17),
        const Text(
          '把日子过成\n喜欢的样子',
          style: TextStyle(
            fontSize: 27,
            height: 1.4,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '不必赶路，按自己的节奏来。',
          style: TextStyle(
            fontSize: 12,
            height: 1.7,
            color: td.textColorSecondary,
          ),
        ),
      ],
    );
  }
}

class HabitProgressCard extends StatelessWidget {
  const HabitProgressCard({
    super.key,
    required this.done,
    required this.total,
    required this.progress,
  });
  final int done;
  final int total;
  final double progress;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return WellnessCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _ProgressCaption(done: done, total: total, progress: progress),
          const SizedBox(height: 12),
          TDProgress(
            type: TDProgressType.linear,
            value: progress,
            showLabel: false,
            strokeWidth: 6,
            backgroundColor: td.bgColorSecondaryContainer,
            color: td.brandNormalColor,
            linearBorderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class _ProgressCaption extends StatelessWidget {
  const _ProgressCaption({
    required this.done,
    required this.total,
    required this.progress,
  });
  final int done;
  final int total;
  final double progress;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            progress == 1 ? '今天也好好照顾自己了' : '每完成一件，都是向前一步',
            style: TextStyle(fontSize: 12, color: td.textColorSecondary),
          ),
        ),
        Text(
          '$done / $total',
          style: TextStyle(
            fontSize: 13,
            color: td.brandNormalColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class FocusInvitationCard extends StatelessWidget {
  const FocusInvitationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return WellnessCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: td.brandLightColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(TDIcons.time, size: 26),
          ),
          const SizedBox(width: 15),
          const Expanded(child: _FocusInvitation()),
          TDButton(
            text: '开始',
            shape: TDButtonShape.round,
            size: TDButtonSize.small,
            theme: TDButtonTheme.primary,
            onTap: () => context.push(RoutePaths.focus),
          ),
        ],
      ),
    );
  }
}

class _FocusInvitation extends StatelessWidget {
  const _FocusInvitation();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '只做一件事',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6),
        Text('留一段专属于你的时间', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class LocalDataNotice extends StatelessWidget {
  const LocalDataNotice({super.key, required this.loadFailed});
  final bool loadFailed;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return TDNoticeBar(
      content: loadFailed ? '本地数据暂时未能读取，请重启应用后再试。' : '慢慢来，生活里的小进步也值得被看见。',
      prefixIcon: loadFailed ? TDIcons.info_circle : TDIcons.heart,
      maxLines: 2,
      height: 16,
      style: TDNoticeBarStyle(
        context: context,
        backgroundColor: Colors.transparent,
        leftIconColor: td.textColorSecondary,
        textStyle: TextStyle(color: td.textColorSecondary, fontSize: 12),
      ),
    );
  }
}

class RecentDaysPicker extends StatelessWidget {
  const RecentDaysPicker({
    super.key,
    required this.today,
    required this.day,
    required this.state,
    required this.onSelected,
    required this.onToday,
  });
  final DateTime today;
  final DateTime day;
  final WellnessState state;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onToday;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '最近七天',
                style: TextStyle(color: td.textColorSecondary, fontSize: 12),
              ),
            ),
            if (dayKey(day) != dayKey(today))
              TDButton(
                text: '回到今天',
                size: TDButtonSize.extraSmall,
                type: TDButtonType.text,
                theme: TDButtonTheme.primary,
                onTap: onToday,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (index) {
            final date = DateTime(
              today.year,
              today.month,
              today.day - 6 + index,
            );

            return Expanded(
              child: _DayCell(
                date: date,
                selected: dayKey(date) == dayKey(day),
                recorded: state.completedOn(date) > 0,
                onTap: () => onSelected(date),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.selected,
    required this.recorded,
    required this.onTap,
  });
  final DateTime date;
  final bool selected;
  final bool recorded;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        button: true,
        selected: selected,
        label: '${date.month} 月 ${date.day} 日',
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: _DayBackground(
            date: date,
            selected: selected,
            recorded: recorded,
          ),
        ),
      ),
    );
  }
}

class _DayContent extends StatelessWidget {
  const _DayContent({
    required this.date,
    required this.selected,
    required this.recorded,
  });
  final DateTime date;
  final bool selected;
  final bool recorded;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Column(
      children: [
        Text(
          weekdays[date.weekday - 1],
          style: TextStyle(
            fontSize: 11,
            color: selected ? td.bgColorPage : td.textColorSecondary,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: selected ? td.bgColorPage : td.textColorPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: recorded
                ? (selected ? td.bgColorPage : td.brandNormalColor)
                : Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _DayBackground extends StatelessWidget {
  const _DayBackground({
    required this.date,
    required this.selected,
    required this.recorded,
  });
  final DateTime date;
  final bool selected;
  final bool recorded;
  @override
  Widget build(BuildContext context) {
    final td = TDTheme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: selected ? td.brandNormalColor : td.bgColorContainer,
      ),
      child: _DayContent(date: date, selected: selected, recorded: recorded),
    );
  }
}

/// 用矢量笔触画一盆小植物,不依赖图片下载或网络资源。
class _PlantPainter extends CustomPainter {
  const _PlantPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 96, size.height / 154);
    final paint = Paint();
    canvas.drawCircle(
      const Offset(55, 57),
      43,
      paint..color = const Color(0xFFCDDCC8),
    );
    canvas.drawCircle(
      const Offset(70, 31),
      12,
      paint..color = const Color(0xFFF0D8A6),
    );
    final stem = Path()
      ..moveTo(47, 131)
      ..cubicTo(50, 104, 35, 75, 55, 34);
    canvas.drawPath(
      stem,
      paint
        ..color = const Color(0xFF486D51)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    paint.style = PaintingStyle.fill;
    for (final leaf in [
      const Offset(46, 65),
      const Offset(43, 90),
      const Offset(48, 112),
    ]) {
      final left = Path()
        ..moveTo(leaf.dx, leaf.dy)
        ..quadraticBezierTo(
          leaf.dx - 28,
          leaf.dy - 1,
          leaf.dx - 26,
          leaf.dy - 23,
        )
        ..quadraticBezierTo(leaf.dx - 3, leaf.dy - 24, leaf.dx, leaf.dy)
        ..close();
      canvas.drawPath(left, paint..color = const Color(0xFF6E9270));
      final right = Path()
        ..moveTo(leaf.dx + 1, leaf.dy - 10)
        ..quadraticBezierTo(
          leaf.dx + 24,
          leaf.dy - 11,
          leaf.dx + 26,
          leaf.dy - 32,
        )
        ..quadraticBezierTo(
          leaf.dx + 5,
          leaf.dy - 30,
          leaf.dx + 1,
          leaf.dy - 10,
        )
        ..close();
      canvas.drawPath(right, paint..color = const Color(0xFF426B57));
    }
    canvas.drawPath(
      Path()
        ..moveTo(30, 126)
        ..lineTo(68, 126)
        ..lineTo(61, 151)
        ..lineTo(37, 151)
        ..close(),
      paint..color = const Color(0xFFBF9777),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(27, 123, 44, 7),
        const Radius.circular(3),
      ),
      paint..color = const Color(0xFFD6B493),
    );
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) => false;
}
