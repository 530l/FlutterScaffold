import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_toast.dart';
import '../../../core/router/route_names.dart';

/// 创作占位页。
class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创作')),
      body: Center(
        child: TDButton(
          text: '打开详情',
          theme: TDButtonTheme.primary,
          onTap: () async {
            final result = await context.push<String>(
              Uri(
                path: RoutePaths.detail,
                queryParameters: {'title': '创作'},
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
