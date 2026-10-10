import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../wellness/view/habits_page.dart';
import '../../wellness/view/journal_page.dart';
import '../../wellness/view/profile_page.dart';
import '../../wellness/view/today_page.dart';

/// 通过 IndexedStack 保留表单外的页面状态,切换页面时暂停隐藏页的动画。
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (final (index, page) in const [
            TodayPage(),
            HabitsPage(),
            JournalPage(),
            ProfilePage(),
          ].indexed)
            TickerMode(enabled: _currentIndex == index, child: page),
        ],
      ),
      bottomNavigationBar: _MainNavigation(
        index: _currentIndex,
        onSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// 导航的组件参数与页面状态分开，主壳只管理当前索引。
class _MainNavigation extends StatelessWidget {
  const _MainNavigation({required this.index, required this.onSelected});
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = TDTheme.of(context);
    Icon tabIcon(IconData icon, bool selected) => Icon(
      icon,
      size: 24,
      color: selected ? theme.brandNormalColor : theme.textColorPrimary,
    );
    return TDBottomTabBar(
      TDBottomTabBarBasicType.iconText,
      currentIndex: index,
      backgroundColor: theme.bgColorContainer,
      selectedBgColor: theme.brandLightColor,
      showTopBorder: false,
      barHeight: 64,
      indicatorAnimation: TDBottomTabBarIndicatorAnimation.elastic,
      navigationTabs: [
        TDBottomTabBarTabConfig(
          tabText: '今日',
          selectedIcon: tabIcon(TDIcons.home_filled, true),
          unselectedIcon: tabIcon(TDIcons.home, false),
          onTap: () => onSelected(0),
        ),
        TDBottomTabBarTabConfig(
          tabText: '习惯',
          selectedIcon: tabIcon(TDIcons.task_checked_filled, true),
          unselectedIcon: tabIcon(TDIcons.task_checked, false),
          onTap: () => onSelected(1),
        ),
        TDBottomTabBarTabConfig(
          tabText: '手记',
          selectedIcon: tabIcon(TDIcons.book_filled, true),
          unselectedIcon: tabIcon(TDIcons.book, false),
          onTap: () => onSelected(2),
        ),
        TDBottomTabBarTabConfig(
          tabText: '我的',
          selectedIcon: tabIcon(TDIcons.user, true),
          unselectedIcon: tabIcon(TDIcons.user, false),
          onTap: () => onSelected(3),
        ),
      ],
    );
  }
}
