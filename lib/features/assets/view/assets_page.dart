import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_toast.dart';
import '../../../core/router/route_names.dart';

/// 资产占位页。
class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('资产')),
      body: Center(
        child: TDButton(
          text: '打开详情',
          theme: TDButtonTheme.primary,
          onTap: () async {
            final result = await context.push<String>(
              Uri(
                path: RoutePaths.detail,
                queryParameters: {'title': '资产'},
              ).toString(),
            );
            if (result != null && context.mounted) {
              AppToast.show('详情页返回: $result');
            }
          },
        ),
      ),
    );
  }
}
