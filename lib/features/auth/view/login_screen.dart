import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../core/dialog/app_toast.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/result.dart';
import '../auth_provider.dart';

/// 登录页:本地假登录,验证 token 存取与登录后跳转
///
/// 登录按钮的 loading 绑定登录态信号的异步态:
/// 启动恢复 token 与 login 请求期间均为 loading(禁用防重复提交)。
class LoginScreen extends SignalStatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    // 登录异步态:isLoading = 恢复会话中 或 登录请求中(读 .value 即自动订阅重建)
    final loading = authState.value.isLoading;

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
                // 登录中禁用,防重复提交(TDButton 禁用后不响应 onTap)
                disabled: loading,
                onTap: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 执行登录:穷举匹配 Result,不使用 try/catch
  Future<void> _handleLogin() async {
    final result = await login(
      _usernameController.text,
      _passwordController.text,
    );
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
