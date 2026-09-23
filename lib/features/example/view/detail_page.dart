import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 详情页(共享示例):页面传值/回值示范 —— query 参数进,pop 带值出
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.title});

  /// 上一个页面通过 query 参数传入的标题
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
              // pop 携带回传值,上一个页面 await push 的返回值即拿到它
              onTap: () => context.pop('我是从详情页带回的值'),
            ),
          ],
        ),
      ),
    );
  }
}
