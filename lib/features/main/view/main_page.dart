import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../assets/view/assets_page.dart';
import '../../create/view/create_page.dart';
import '../../home/view/home_screen.dart';
import '../../mine/view/mine_page.dart';

/// 主壳页:底部 4 tab(探索/创作/资产/我的)
///
/// tab 当前索引是纯本地 UI 状态,不进信号;
/// body 用 IndexedStack 让四个 tab 页面同时挂载,切 tab 不重建、不丢状态。
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// 当前选中的 tab 索引
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 图标配色:iconText 模式要求同时传 selectedIcon/unselectedIcon,
    // 组件只是在二者间切换、不会自动给 Icon 上色,这里按选中/未选中手动配色,
    // 颜色与 tab 文字的选中/未选中颜色(组件自动处理)保持一致
    final theme = TDTheme.of(context);
    Icon tabIcon(IconData icon, bool selected) => Icon(
          icon,
          size: 24,
          color: selected ? theme.brandNormalColor : theme.textColorPrimary,
        );

    return Scaffold(
      // children 顺序与 navigationTabs 一一对应:探索/创作/资产/我的
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          CreatePage(),
          AssetsPage(),
          MinePage(),
        ],
      ),
      bottomNavigationBar: TDBottomTabBar(
        TDBottomTabBarBasicType.iconText,
        // 受控用法:索引由本 State 持有,tab 回调里 setState 切换
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
