import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../assets/view/assets_page.dart';
import '../../create/view/create_page.dart';
import '../../home/view/home_screen.dart';
import '../../mine/view/mine_page.dart';

/// 通过 IndexedStack 保留各 tab 的页面状态。
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = TDTheme.of(context);
    Icon tabIcon(IconData icon, bool selected) => Icon(
      icon,
      size: 24,
      color: selected ? theme.brandNormalColor : theme.textColorPrimary,
    );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomeScreen(), CreatePage(), AssetsPage(), MinePage()],
      ),
      bottomNavigationBar: TDBottomTabBar(
        TDBottomTabBarBasicType.iconText,
        currentIndex: _currentIndex,
        navigationTabs: [
          TDBottomTabBarTabConfig(
            tabText: '探索',
            selectedIcon: tabIcon(TDIcons.explore, true),
            unselectedIcon: tabIcon(TDIcons.explore, false),
            onTap: () => setState(() => _currentIndex = 0),
          ),
          TDBottomTabBarTabConfig(
            tabText: '创作',
            selectedIcon: tabIcon(TDIcons.edit, true),
            unselectedIcon: tabIcon(TDIcons.edit, false),
            onTap: () => setState(() => _currentIndex = 1),
          ),
          TDBottomTabBarTabConfig(
            tabText: '资产',
            selectedIcon: tabIcon(TDIcons.wallet, true),
            unselectedIcon: tabIcon(TDIcons.wallet, false),
            onTap: () => setState(() => _currentIndex = 2),
          ),
          TDBottomTabBarTabConfig(
            tabText: '我的',
            selectedIcon: tabIcon(TDIcons.user, true),
            unselectedIcon: tabIcon(TDIcons.user, false),
            onTap: () => setState(() => _currentIndex = 3),
          ),
        ],
      ),
    );
  }
}
