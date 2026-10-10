import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/app.dart';

void main() {
  testWidgets('慢慢的四个入口可以切换,手记初始为空', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('慢慢'), findsOneWidget);
    expect(find.text('今日'), findsOneWidget);

    await tester.tap(find.text('习惯'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('小习惯'), findsOneWidget);

    await tester.tap(find.text('手记'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('生活手记'), findsOneWidget);
    expect(find.text('这里留着，等你的第一篇手记'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('我的小世界'), findsOneWidget);
    // 释放作用域内用于跨日更新的定时器。
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
