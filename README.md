# 慢慢 · 好好生活

基于 Flutter、Riverpod 和 TDesign Flutter 的本地生活 APP，以暖白和鼠尾草绿为主色，支持夜间模式。

## 功能

- **今日**：查看最近七天、打卡与补记、查看习惯完成进度。
- **习惯**：搜索与分类筛选，添加、编辑、删除习惯，设定投入时长。
- **手记**：选择心情、记录文字、回看与删除手记。
- **专注**：选择 5–60 分钟，开始、暂停、继续，完成后保存记录。
- **我的**：查看真实统计和最近七天的行动，设置夜间模式与默认专注时长，复制生活记录。

首次使用提供三个可编辑的习惯，不预填打卡、专注或手记数据。所有记录通过
`shared_preferences` 保存在当前设备，无需登录或后端。重开应用会恢复记录；
读取失败时提示并阻止覆盖原始数据。

专注计时以截止时间计算，回到前台后更新剩余时间；关闭应用后不恢复未完成的计时。

## 组件

| 场景 | TDesign 组件 |
|---|---|
| 导航与分类 | `TDBottomTabBar`、`TDTabBar`、`TDTab` |
| 打卡与进度 | `TDCheckbox`、`TDProgress` |
| 搜索与表单 | `TDSearchBar`、`TDInput`、`TDTextarea`、`TDSlider` |
| 标签与提示 | `TDTag`、`TDAvatar`、`TDNoticeBar` |
| 设置与反馈 | `TDCellGroup`、`TDCell`、`TDSwitch`、`TDAlertDialog`、`TDButton`、`TDEmpty` |

组件参数对照 [官方组件概览](https://tdesign.tencent.com/flutter/overview) 与项目本地版本。
`third_party/tdesign_flutter` 保留了兼容 Flutter 3.47 的补丁。

## 目录与职责

```text
lib/
├── main.dart                   # 恢复本地记录、注入启动初值
├── app.dart                    # 路由、主题与消息提示
├── core/
│   ├── router/                 # 主页面与专注页路由
│   ├── theme/                  # 明暗主题
│   ├── dialog/                 # 弹窗、底部弹层、消息提示
│   └── utils/                  # 日志
└── features/
    ├── main/view/              # 四个页面的导航主壳
    └── wellness/
        ├── model/              # 生活记录与心情定义
        ├── provider/           # Riverpod 状态与本地存储
        └── view/
            ├── *_page.dart     # 页面状态、交互与区块排列
            ├── habit_editor.dart
            ├── focus_settings_sheet.dart
            └── widgets/        # 按业务区块拆分的组件与公共样式
```

页面的 `build` 按顺序组合独立 Widget。欢迎卡片、日期选择、手记卡片、心情选择、
专注表盘、统计和设置均有各自的组件，避免在主页面中堆叠嵌套布局。
公共组件负责卡片、标题、统计、时长选择、空状态和键盘避让。

四个页面通过 `IndexedStack` 保留状态，`TickerMode` 暂停隐藏页面的动画。
搜索、筛选和表单草稿使用局部状态；习惯、手记、专注记录和设置由
`wellnessProvider` 管理，保存成功后更新。Riverpod 的注解和命名规则见
[docs/riverpod.md](docs/riverpod.md)。

## 常用命令

```bash
flutter pub get
flutter run
dart run build_runner build
```

修改 Riverpod 注解后运行代码生成命令，生成文件不手动编辑。

各平台应用名与图标统一为「慢慢」。图标源码位于 `tool/generate_brand_icons.py`，
使用带 Pillow 的 Python 环境运行即可重新生成 Android、iOS 和 Web 图标。
