# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

iOS 小说阅读类 App（UIKit，纯代码布局，无 Storyboard 页面）。最低部署目标 iOS 15.0，Swift 5，CocoaPods 管理依赖（`use_frameworks!` 动态库）。

## 构建与运行

```bash
# 编译（必须用 workspace 而不是 xcodeproj，否则链接不到 Pods）
xcodebuild -workspace novelplant.xcworkspace -scheme novelplant -destination 'generic/platform=iOS Simulator' build

# 安装/更新依赖
pod install
```

- 没有 unit test target，不要虚构测试命令。
- **不要主动跑 xcodebuild 编译验证**——用户会在 Xcode 手动编译。改完代码报告改动点即可，编译结果由用户自己确认。
- Podfile 的 source 指向清华镜像（trunk CDN 的 302 目标被墙），不要改回官方源。
- Podfile `post_install` 把所有 Pods 的部署目标抬到 15.0（否则新 Xcode 链接已删除的 libarclite 报错），升级依赖后需保留这段。
- `inhibit_all_warnings!` 已开启，三方库警告无需处理。

## 架构

### 启动与 Tab 结构

Scene 生命周期（Info.plist 有 `UIApplicationSceneManifest`，已删除 `UISceneStoryboardFile`）。根窗口在 `SceneDelegate.scene(_:willConnectTo:)` 中手动创建，rootViewController 为 `BaseTabbarViewController`：

- 每个 tab 的 VC 包一层 `BaseNavigationController` 再 addChild。
- Tab 图标解析顺序：`UIImage(named:)` 优先， miss 后回落 `UIImage(systemName:)`（SF Symbols）。往 `Assets.xcassets` 放同名切图即可零代码替换。
- 自定义 tabbar 通过 KVC 替换：`setValue(BaseTabbar(), forKey: "tabBar")`。

### Base 类体系（novelplant/Base/）

- `BaseViewController`：背景色 `.bgColor`；`hiddenNavigationBar` 属性控制导航栏隐藏；modal 固定 `.overFullScreen`；状态栏 lightContent；deinit 移除通知观察者。
- `BaseNavigationController`：透明导航栏（背景图/阴影图均为空 UIImage）；重写 `pushViewController` 统一注入返回按钮（图片名 `"left"`，该切图目前**不在 Assets 里**）并设置 `hidesBottomBarWhenPushed`。
- `BaseTabbarViewController`：tab 配置集中在 `addChildVC()`，当前为 Home / Library / Me 三个 tab（VC 在 `novelplant/Main/` 下）。

### 网络层（novelplant/Network/）

Moya 封装，全局函数式调用（不是类方法）：

- `NetWorkRequest(target, completion:failed:errorResult:)` 三个重载，按需选用；`NetWorkRequestWithAnyCode` 不校验 code 直接回调；`NetWorkRequestWithAllData` 只要请求成功就回调。
- 接口契约：`{code, msg, data}`；`code == 200` 成功回调 data（data 为空时回落拼 `total/rows/statistical`）；`code == 401` 统一走登出（toast + `User.deleteUser()` + `gotoLogin()`，后者目前是空实现）。
- 新接口：定义 struct 遵循 `TargetType` 即可，`BaseTargetType.swift` 的 extension 已提供默认 `baseURL`（`URLConst.baseURL`）、`headers`（自动带 `Authorization: Bearer <token>` + appId/appVersion/os）、`sampleData`、超时。数组参数体用 `JSONArrayEncoding.default`。
- 模型转换用 KakaJSON（`Convertible` 协议，见 `User.swift`）。
- 注意：`URLConst.swift` 里的域名（magicchair.net 等）是从旧项目拷来的遗留值，接入本项目的真实后端时需整体替换，DEBUG/RELEASE 用 `#if` 区分。

### 全局环境（novelplant/Custom/）

- `Global.swift`：全局计算属性（`keyWindow`、`safeAreaTopSpace/BottomSpace`、`currentViewController`、`isLogin`、`isNetworkConnect` 等）和全局函数（`gotoLogin()`、`logoutUser()`、`toJSONString()`）。
- `Const.swift`：`screenW/screenH/navHeight/tabbarHeight/appDelegate` 等常量。
- `User.swift`：登录态模型（id/token），持久化在 UserDefaults；网络层 headers 直接读它。
- `HeaderGlobal.swift`：`@_exported import` 所有三方库——**全工程无需写 import 语句**，新文件里不要画蛇添足。

### 颜色规范（Extension+UIColor.swift）

语义色全部带深色模式适配（`UIColor(hex:darkHex:)`）：`.bgColor` 页面背景、`.themeColor` 主题橙 #FF7A2E、`.textPrimaryColor/textSecondaryColor/textTertiaryColor` 三级文字、`.cellBgColor`、`.separatorColor`、`.readingBgColor` 阅读页护眼底色等。**不要在业务代码里写裸 hex**，加色先在这里补语义定义。

完整 UI 风格规范（字号/间距/圆角阶梯、组件样式、Code Review 检查项）见 `docs/UI-Style-Guide.md`，写 UI 代码前先对齐该文档。

### 目录约定

```
novelplant/
├── Base/        # Base 类（VC/Nav/Tabbar）
├── Extension/   # UIKit/Foundation 扩展（UIColor/UIView/String/MJRefresh...）
├── Network/     # Moya 封装 + URL 常量
├── Custom/      # 全局属性/常量/User/HeaderGlobal
├── Tools/       # Toast（XHToastManager）
└── Main/        # 业务模块，按 <模块名>/<模块名>ViewController.swift 组织
                 # 现有：Home、Libaray（目录名拼写即如此）、Login、Me
```

新业务模块放 `Main/<模块名>/` 下，继承对应的 Base 类。

## 已知遗留问题

- `gotoLogin()` 已接通（present `LoginViewController`，苹果登录已实现）；401/登出跳登录的完整流程尚未接通（网络层现为 code==0/10003 体系）。
- 文件头注释为 "Moyi"（2023 年）的文件是从旧项目拷贝的，属正常情况。
- Assets.xcassets 目前只有 AppIcon/AccentColor，`"left"` 返回按钮切图及 tabbar 切图均未导入，当前 tab 图标走 SF Symbols。
