import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_toast.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/result.dart';
import '../auth_provider.dart';

/// 登录示例。
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TDInput(
                controller: _usernameController,
                leftLabel: '用户名',
                hintText: '请输入用户名',
              ),
              const SizedBox(height: 8),
              TDInput(
                controller: _passwordController,
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
                disabled: loading,
                onTap: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final result = await ref
        .read(authStateProvider.notifier)
        .login(_usernameController.text, _passwordController.text);
    if (!mounted) return;

    switch (result) {
      case Success():
        AppToast.show('登录成功');
        context.go(RoutePaths.main);
      case Failure(:final error):
        AppToast.error(error.message);
    }
  }
}
