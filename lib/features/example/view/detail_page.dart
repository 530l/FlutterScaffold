import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 演示 query 传入参数和 pop 返回结果。
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('详情')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('收到参数:'),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 32),
            TDButton(
              text: '返回一个值',
              theme: TDButtonTheme.primary,
              onTap: () => context.pop('我是从详情页带回的值'),
            ),
          ],
        ),
      ),
    );
  }
}
