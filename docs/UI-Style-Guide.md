# novelplant UI 风格规范

> 适用范围：novelplant 全部 UIKit 界面代码。新页面、新组件、老页面改版一律以本文档为准。
> 规范来源：基于 `Extension+UIColor.swift`、`Base/`、`Main/` 现有代码沉淀，未引入任何新依赖。
> 最后更新：2026-10-09

---

## 0. 三条铁律

1. **禁止裸值**：业务代码里不允许出现 `.white` / `.black` / `UIColor(hex:)` / `UIFont.systemFont(ofSize:)` 散写。颜色必须用语义色（`Extension+UIColor.swift`），字体按第 3 节阶梯取值。
2. **深色模式一票否决**：所有新 UI 必须同时验收浅色/深色两种外观。语义色已自动适配，用裸 `.white` 会导致深色模式下刺眼白块——这是当前 code review 的重点拦截项。
3. **4pt 网格**：所有尺寸、间距取 4 的倍数（胶囊圆角 = 高度一半等「物理正确」的值除外）。

---

## 1. 色彩系统

### 1.1 语义色总表

唯一定义处：`novelplant/Extension/Extension+UIColor.swift`。全部通过 `UIColor(hex:darkHex:)` 双值定义，跟随系统深色模式自动切换。

| Token | 浅色 | 深色 | 用途 | 禁忌 |
|---|---|---|---|---|
| `.bgColor` | `#F6F7FB` | `#111111` | 页面主背景（`BaseViewController` 已默认设置） | 不要再手动给 `view.backgroundColor` 赋别的值 |
| `.navBgColor` | `#FFFFFF` | `#1C1C1E` | 不透明导航栏/顶部标题容器背景 | 透明导航场景不用（见 6.1） |
| `.cellBgColor` | `#FFFFFF` | `#1E1E1E` | 卡片、Cell、浮层内容背景（比页面背景高一级层次） | 不要用作整页背景 |
| `.themeColor` | `#FF7A2E` | `#FF8A3D` | 品牌橙：主按钮、价格、选中态、书架强调、可点图标 | 不要用于正文长文本 |
| `.readingBgColor` | `#F5EDD8` | `#1C1C1E` | 阅读页护眼底色 | 仅阅读器场景使用 |
| `.textPrimaryColor` | `#1A1A1A` | `#EAEAEA` | 一级文字：标题、正文 | — |
| `.textSecondaryColor` | `#666666` | `#999999` | 二级文字：副标题、说明、tab 未选中 | — |
| `.textTertiaryColor` | `#999999` | `#666666` | 三级文字：占位符、时间戳、辅助信息、chevron 箭头 | 不要用于需要阅读理解的正文 |
| `.separatorColor` | `#E5E6EB` | `#333333` | 分割线、描边 | — |
| `.maskColor` | `#000000` @40% | `#000000` @60% | 弹窗/菜单遮罩 | 不要自己 `withAlphaComponent` 拼遮罩 |

### 1.2 层次模型

```
.bgColor（页面底）  →  .cellBgColor（卡片/Cell）  →  .themeColor（强调点）
文字三级：.textPrimaryColor → .textSecondaryColor → .textTextTertiaryColor 依次减弱
```

卡片浮在页面背景上的层次感来自「页面浅灰底 + 卡片纯白底」的明度差，**不要靠给卡片加彩色底制造层次**。

### 1.3 新增颜色的流程

1. 先判断能否用现有 token 组合满足（90% 的需求是「想用 themeColor 但透明度不同」→ 用 `themeColor.withAlphaComponent()` 是允许的，橙系强调例外）。
2. 确需新色：在 `Extension+UIColor.swift` 补 `static let` + 中文注释（写清用途），**必须同时给 darkHex**。
3. 功能色（成功/警告/错误）目前未定义，需要时按此流程补充，建议命名 `.successColor` / `.warningColor` / `.errorColor`。

### 1.4 现存违规（整改清单）

以下代码用了裸 `.white`，深色模式下会出现刺眼白块，排期整改，新代码严禁模仿：

| 位置 | 现状 | 应改为 |
|---|---|---|
| `HomeViewController.swift:14,48` | `titleView`/`view` 背景 `.white` | 标题容器 `.navBgColor`，页面背景删掉手动赋值（Base 已设 `.bgColor`） |
| `MeViewController.swift:23` + `MeHeaderView` | header `.white` | `.cellBgColor` |
| `BaseTabbar.swift:17` | `backgroundColor = .white` | `.navBgColor`（或新增 `.tabbarBgColor`） |

---

## 2. 明暗模式

- 全部颜色走语义色，禁止浅色模式下肉眼调好就交付。
- 验收方式：Xcode → Debug → View Environment → Override Dark Appearance，或模拟器 ⌘⇧A 切换。
- 图片资源：需要区分明暗的切图在 Assets.xcassets 里配 Appearance → Any/Dark；SF Symbols 的 tint 走语义色即自动适配。
- 深色模式下注意：`.maskColor` 已自动加深（0.4→0.6），不要重复叠加。

---

## 3. 字体规范

当前全项目使用系统字体（SF Pro），**不引入自定义字体**。导航标题/页面大标题用 `boldSystemFont`，其余用 `systemFont`（如需 Medium 层级用 `systemFont(ofSize:weight:)`）。

### 3.1 字号阶梯

| 层级 | 字号/字重 | 颜色 | 场景 |
|---|---|---|---|
| 大标题 | **18 bold** | `.textPrimaryColor` | 导航标题（`BaseNavigationController` 已内置）、页面头部标题（如 Me 昵称） |
| 卡片标题 | 16 semibold（`.systemFont(ofSize: 16, weight: .semibold)`） | `.textPrimaryColor` | 书名、列表项标题 |
| 正文 | 15 regular | `.textPrimaryColor` | 列表正文、详情段落 |
| 次要正文 | 14 regular | `.textSecondaryColor` | 摘要、说明 |
| 辅助信息 | 13 regular | `.textSecondaryColor` | 标签、计数 |
| 占位/时间戳 | 12 regular | `.textTertiaryColor` | 占位文案、章节更新时间 |
| 角标 | 10 regular | 白 | badge（`Extension+UIButton` 默认） |
| 阅读器正文 | 17–19，用户可调 | 用户可调 | 阅读页专项，字体/行距/配色由阅读器设置模块单独管理 |

现状对照：Home 搜索占位 14、Me 昵称 18 bold、导航标题 18 bold，与本阶梯一致；`HomeViewController.swift:28` 的 14 号占位用 `.textTertiaryColor` 正确。

### 3.2 落地方式

字体暂无语义 token，直接按上表数值书写；重复出现的组合建议后续在 `Extension+UIColor.swift` 旁新增 `Extension+UIFont`（见附录 A）。

---

## 4. 间距与布局

### 4.1 间距阶梯（4pt 网格）

`4 / 8 / 12 / 16 / 20 / 24`，常用值含义：

| 值 | 用途 |
|---|---|
| 4 | 图文微间距、badge padding |
| 8 | 同组元素内间距 |
| 12 | 图文主间距（头像→文字）、紧凑水平边距（导航内搜索条） |
| 16 | **页面标准水平边距**、卡片外边距、列表分组间距 |
| 20 / 24 | 区块间距、页面留白 |

布局一律用 SnapKit 约束，禁止 frame 布局（`MeHeaderView` 的 frame 初始化属 tableHeaderView 特例，允许）。

### 4.2 固定尺寸

| 项 | 值 | 出处 |
|---|---|---|
| 导航栏高度 | 44 + 状态栏（用全局 `navHeight`，勿写死） | `Const.swift:13` |
| TabBar 高度 | 49 + 底部安全区（全局 `tabbarHeight`） | `Const.swift:14` |
| 最小点击热区 | 44 × 44（视觉小图标也要撑满热区，参考 Home 礼包按钮 `size.equalTo(44)`） | — |
| 导航内搜索条 | 高 30、圆角 15（胶囊） | `HomeViewController` |
| 列表 Cell 高度 | ≥ 56（含 16 上下留白），信息密集型 ≥ 44 |
| 头像 | 列表 40 / 个人页 88（现状 `MeHeaderView` 88） |

### 4.3 安全区

- 顶部用 `safeAreaTopSpace`，底部用 `safeAreaBottomSpace`（`Global.swift` 全局计算属性），不要在 VC 里自己 `safeAreaInsets`。
- 侧滑返回、push 的页面底部长列表记得最后Cell 底部留 `tabbarHeight` 或安全区缓冲。

---

## 5. 圆角、阴影、分割线

### 5.1 圆角阶梯

| Token（语义） | 值 | 场景 |
|---|---|---|
| 小圆角 | 4 | 输入框、小标签 |
| 卡片圆角 | 8 | 卡片、Cell 内嵌图 |
| 弹层圆角 | 10 | 弹窗、Toast（Toast.swift 现值 10）、浮层 |
| 胶囊 | 高度 × 0.5 | 按钮、搜索条（30 高 → 15，参考 Home 搜索） |
| 全圆 | width = height | 头像、badge |

### 5.2 阴影

- 卡片默认**不加阴影**，靠 `.bgColor` vs `.cellBgColor` 明度差分层（见 1.2）。
- 需要悬浮感（弹层、悬浮按钮）时用 `UIView.shadow(_:)` 扩展（`Extension+UIView.swift:133`，默认黑 40%、offset 0）或按 Toast 现值：opacity 0.8 → 建议降到 0.1–0.15、radius 6、offset (0, 4) 的浅投影。
- 阴影与圆角冲突时用 `shadowPath`（扩展已内置）。

### 5.3 分割线

- 颜色一律 `.separatorColor`，线高 0.5。
- 可用 `addBottomLine/addTopLine`（`Extension+UIView.swift:179`，默认色 `#F5F5F5` 裸值待统一为 `.separatorColor`），或直接用 Cell 自带 separator + 16 的左右 inset。

---

## 6. 组件规范

### 6.1 导航栏

- 全局样式由 `BaseNavigationController` 统一：**透明背景、白色前景、标题 18 bold 白色**。
- 透明导航 = 导航内容叠在页面内容上，**页面顶部第一个可见元素必须自带深色衬底**（或改用 `hiddenNavigationBar = true` 自绘标题区，背景用 `.navBgColor`）。当前 Home 页面背景是白色系，导航白字在浅色内容上不可读，属已知隐患（见附录 B）。
- 返回按钮切图名为 `"left"`（Assets 未导入，当前显示空图）。导入后无需改代码。
- 隐藏导航：`hiddenNavigationBar = true`（`BaseViewController` 已处理显隐逻辑），如 Me 页。

### 6.2 TabBar

- 选中 `.themeColor`，未选中 `.textSecondaryColor`（`BaseTabbar` 已内置）。
- 图标：SF Symbols（`house`/`books.vertical`/`person` 及 `.fill` 选中态），往 Assets 放同名切图即零代码替换。
- 新增 tab：只在 `BaseTabbarViewController.addChildVC()` 改配置，不另写 tabbar 逻辑。

### 6.3 按钮

| 类型 | 样式 | 规格 |
|---|---|---|
| 主按钮 | `.themeColor` 底 + 白字 16 semibold | 高 44，圆角 22（胶囊），按下态 `themeColor.withAlphaComponent(0.8)` |
| 次按钮 | `.cellBgColor` 底 + `.themeColor` 字 + `.themeColor` 0.5pt 描边 | 高 44，圆角 22 |
| 文字按钮 | 无底，`.themeColor` 字 15 | 热区 ≥ 44 |
| 图标按钮 | SF Symbol，`.themeColor` tint | 图标 22–24，热区 44（Home 礼包按钮为标准示例） |

图文混排用 `adjustImageTitlePosition(_:spacing:)`（`Extension+UIButton.swift:31`，iOS 15 configuration 实现）。

### 6.4 搜索条（导航内仿搜索框）

以 `HomeViewController.searchButton` 为标准：

- 背景 `.bgColor`（浅灰胶囊嵌在白/`navBgColor` 容器里）、圆角 15、高 30；
- 放大镜图标 + 占位文案同用 `.textTertiaryColor`、字号 14；
- 左对齐，图标与文案间距 8；
- 点击后 push 真正搜索页，本组件只做入口。

### 6.5 列表与 Cell

- Cell 背景 `.cellBgColor`；分组列表第一组顶部、最后一组底部距屏幕边 16。
- Cell 内布局：左 16 起，图文间距 12，右侧箭头 `chevron.forward` tint `.textTertiaryColor` 距右 16。
- 书籍类 Cell 建议：封面 75×100（3:4）、书名 16 semibold primary、作者/简介 13 secondary、未读标识用 `.themeColor`。

### 6.6 Toast 与 Loading

- 统一入口 `XHToastManager`：`makeToast(_:)` 文字提示、`makeToastActivity()`/`hideToastActivity()` 转圈。禁止业务代码直接调 keyWindow 的 toast API。
- 样式为 Toast.swift 默认（黑 80% 底白字圆角 10），全局不改。
- 请求失败提示文案由网络层 `msg` 字段给出，业务侧不重复 toast。

### 6.7 空态 / 加载态

- 空态用 `EmptyDataSet-Swift`（Podfile 已引入）：图标 + 一行 `.textSecondaryColor` 13 说明 + 可选重试按钮（次按钮样式）。
- 列表下拉刷新/上拉加载用 MJRefresh；footer 已统一隐藏 stateLabel（`Extension+MJRefresh.swift`），勿再开启。
- 图片加载用 Kingfisher（`kf.setImage`），必须给 placeholder（灰底或 SF Symbol 占位）。

### 6.8 键盘

- IQKeyboardManagerSwift 全局接管 toolbar/自动位移，业务代码不要手动监听键盘调整 inset（阅读页等特殊场景除外）。
- 点空白收键盘已由 `BaseViewController.touchesBegan` 全局处理。

---

## 7. 图标规范

- **首选 SF Symbols**（当前最低 iOS 15，可用到 SF Symbols 4 的符号），用 `UIImage(systemName:)`。
- 设计稿出图时放入 `Assets.xcassets`，命名与 SF Symbol 同名（如 `house`、`magnifyingglass`），代码走 `UIImage(named:) ?? UIImage(systemName:)` 回落链（tabbar 已内置此逻辑，其余场景照抄）。
- tint 语义：`.themeColor` = 可点击/强调；`.textSecondaryColor` = 中性功能；`.textTertiaryColor` = 纯装饰/箭头。
- 图标视觉尺寸 20–24，点击热区一律 44。

---

## 8. 文案与本地化

- 所有面向用户的字符串必须 `NSLocalizedString(_:comment:)` 包裹（现状 Home/Me/Tabbar 已遵守）。
- 语言：key 用英文原文（如 `"Coming soon"`），中文翻译在 Localizable.strings 维护（当前工程尚无 strings 文件，接入时补）。
- 按钮文案动词开头、≤ 4 字（「登录」「立即阅读」）；Toast 一句话、≤ 15 字。

---

## 9. 交互动效

- 时长：微交互 0.2s，过渡 0.25–0.3s（与 badge 缩放 0.2/移除 0.25 现值一致）。
- 系统 standard 曲线优先，弹跳感仅用于 badge 这类强提醒（现值 controlPoints(0.4, 1.3, 1, 1)）。
- push/pop 由 `BaseNavigationController` 统一；modal 统一 `.overFullScreen`（Base 已强制）。

---

## 10. Code Review 检查项（UI 部分）

- [ ] 无裸色：`.white` / `.black` / `UIColor(hex` / `.rgb(` 出现在业务文件 → 打回（语义色定义文件除外）
- [ ] 深色模式两种外观都看过
- [ ] 颜色/圆角/间距/字号取自本文档阶梯
- [ ] 布局用 SnapKit，安全区用全局属性
- [ ] 点击热区 ≥ 44
- [ ] 文案有 NSLocalizedString
- [ ] Toast 走 XHToastManager
- [ ] 图片有 placeholder
- [ ] 新增 tab/导航配置改在 Base 类，未在业务 VC 重复造轮子

> 快速自查命令（工程根目录执行）：
> ```bash
> grep -rn "\.white\b\|\.black\b\|UIColor(hex" novelplant --include="*.swift" | grep -v "Extension+UIColor\|Tools/"
> ```

---

## 附录 A：待落地缺口（代码层尚未支撑，需排期）

| # | 缺口 | 建议 |
|---|---|---|
| A1 | 字体无语义 token | 新增 `Extension+UIFont.swift`：`.fontTitle`（18 bold）/ `.fontCardTitle`（16 semibold）/ `.fontBody`（15）/ `.fontSub`（14）/ `.fontCaption`（13）/ `.fontTiny`（12） |
| A2 | 间距无常量 | `Const.swift` 加 `struct UI { static let margin: CGFloat = 16 ... }` 或枚举 `Spacing` |
| A3 | `navBgColor` 已定义未使用 | 透明导航的页面自绘标题区时启用，或导航改不透明时启用 |
| A4 | `addBottomLine` 等默认 `#F5F5F5` 裸值 | 改默认 `.separatorColor` |
| A5 | 功能色缺失 | 按需补 `.successColor` / `.warningColor` / `.errorColor`（双模式） |

## 附录 B：本次盘点发现的真实视觉隐患

1. **导航白字可读性**：`BaseNavigationController` 固定白色标题/tint，而 Home 页面背景为白色系，标题在浅色内容上不可见。整改方向二选一：页面顶部加深色衬底，或导航前景色改为动态色（浅色模式 `.textPrimaryColor`、深色模式白色）。
2. **深色模式白块**：见 1.4 违规清单。
3. **返回按钮空图**：`"left"` 切图未导入 Assets，push 二级页返回按钮目前不可见。
