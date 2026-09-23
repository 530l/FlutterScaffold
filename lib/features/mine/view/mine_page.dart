import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_toast.dart';
import '../../../core/router/route_names.dart';

/// 我的页(占位 tab):演示 push 传值 / pop 回值的标准写法,可复制为新模块骨架
class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: Center(
        child: TDButton(
          text: '打开详情',
          theme: TDButtonTheme.primary,
          onTap: () async {
            // push 携带 query 参数进详情页,await 接住 pop 回传的值
            final result = await context.push<String>(
              Uri(
                path: RoutePaths.detail,
                queryParameters: {'title': '我的'},
              ).toString(),
            );
            // 返回非空才提示(pop 未带值时静默)
            if (result != null && context.mounted) {
              AppToast.show('详情页返回: $result');
            }
          },
        ),
      ),
    );
  }
}
