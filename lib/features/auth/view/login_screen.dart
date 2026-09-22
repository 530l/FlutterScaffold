import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_toast.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/router/route_names.dart';
import '../auth_provider.dart';

/// 登录页:本地假登录,验证 token 存取与登录后跳转
///
/// 登录按钮的 loading 绑定 AuthNotifier 的异步态:
/// build 恢复 token 与 login 请求期间均为 loading(禁用防重复提交)。
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 用户名/密码输入控制器,卸载时自动释放
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();

    // 登录异步态:isLoading = 恢复会话中 或 登录请求中
    final auth = ref.watch(authProvider);
    final loading = auth.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Center(
        // 键盘弹起时可滚动,避免输入框被遮挡
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TDInput(
                controller: usernameController,
                leftLabel: '用户名',
                hintText: '请输入用户名',
              ),
              const SizedBox(height: 8),
              TDInput(
                controller: passwordController,
                leftLabel: '密码',
                hintText: '请输入密码',
                obscureText: true,
              ),
              const SizedBox(height: 40),
              TDButton(
                text: loading ? '登录中...' : '登录',
                isBlock: true,
                size: TDButtonSize.large,
                theme: TDButtonTheme.primary,
                // 登录中禁用,防重复提交(TDButton 禁用后不响应 onTap)
                disabled: loading,
                onTap: () => _handleLogin(
                  ref,
                  context,
                  usernameController,
                  passwordController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 执行登录:成功 toast + 跳首页;失败 toast 错误文案
  Future<void> _handleLogin(
    WidgetRef ref,
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController passwordController,
  ) async {
    try {
      await ref.read(authProvider.notifier).login(
            usernameController.text,
            passwordController.text,
          );
      if (!context.mounted) return;
      // 登录成功:提示并跳转首页
      AppToast.show('登录成功');
      context.go(RoutePaths.home);
    } on AppException catch (e) {
      // 登录失败:展示面向用户的中文错误文案
      AppToast.error(e.message);
    }
  }
}
