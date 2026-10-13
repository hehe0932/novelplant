//
//  ReadPageViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/12.
//

import UIKit

class ReadPageViewController: BaseViewController {

    var bookId: String = ""

    // MARK: - 菜单栏显隐
    private var isMenuVisible = false
    private var bookModel: BookModel?
    private var readModel: ReadModel?

    /// 当前字体配置
    private var currentFontConfig: ReadFontConfig = ReadFontConfig.load()

    /// 当前阅读设置配置
    private var currentSettingConfig: ReadSettingConfig = ReadSettingConfig.load()

    /// 进入阅读页前的原始亮度（用于退出时恢复）
    private var originalBrightness: CGFloat = UIScreen.main.brightness

    /// 排版缓存：[配置哈希: 排版结果]
    private var layoutCache: [String: ReadPageLayoutEngine.LayoutResult] = [:]

    /// 当前章节的原始内容
    private var currentContent: String {
        return readModel?.currentChapterContent?.content ?? ""
    }

    /// 当前章节的排版结果
    private var layoutResult: ReadPageLayoutEngine.LayoutResult? {
        return readModel?.currentChapterContent?.layoutResult
    }

    /// 当前章节总页数
    private var totalPages: Int {
        return layoutResult?.totalPages ?? 0
    }

    private var currentIndex: Int = 0
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        // 恢复原始亮度
        UIScreen.main.brightness = originalBrightness
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO清除所有付费缓存

        hiddenNavigationBar = true
        view.backgroundColor = .white
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)

        setupMenuBar()
        setupGestures()

        // 设置初始页（书籍打开时应为"上次阅读到的页"）
        if let first = contentVC(at: 0) {
            pageViewController.setViewControllers([first], direction: .forward, animated: false)
        }

        // 应用阅读设置配置
        applySettingConfig(currentSettingConfig)

        requestInfo()

    }
    
    
    private func requestInfo() {
        //判断阅读历史
        //没有历史,请求新书
        if false {
            
        } else {
            if let _ = self.bookModel {
                //根据章节信息拿数据
                requsetReadBookModel()
                
            } else {
                //先拿章节信息
                requestBookInfo()
            }
            
        }
    }

    ///请求章节信息
    private func requestBookInfo() {
        
        NetWorkRequest(ReadNetworkManager.bookChaptersNew(bookId: bookId)) { result in
            guard let data = result as? [String: Any] else { return }
            guard let chapters = data["chapters"] as? [[String: Any]] else { return }
            let array = chapters.kj.modelArray(ChapterModel.self)
            
            //存储本地
            let dic: [String: Any] = [
                "chapter_count": array.count,
                "read_chapter_index": 1,
                "read_chapter_page": 1,
                "read_finished": 0,
                "dir_ver": -1
            ]
            
            _ = ReadFileUtilities.saveChapterList(dic, bookId: self.bookId)
            self.bookModel = BookModel()
            self.bookModel?.com_book_id = self.bookId
            self.bookModel?.chapters = array;
            
            self.noHistoryData()
        } failed: { msg, code in
            //TODO显示失败
        }
    }
    
    private func noHistoryData() {
        if let _ = bookModel {
            requsetReadBookModel()
            
        } else {
            requestBookInfo()
        }
    }
    
    private func requsetReadBookModel() {
        
        let dic = ReadFileUtilities.getChapterListWithBookId(bookId: bookId)
        guard let chapterModel = dic?.kj.model(ChapterBookModel.self) else { return }
        
        //            if (!NIIsArrayWithObjects(book.chapters)) {
        //                [self createReadModelWithBook:book historyModel:historyModel chapters:chapterModel.chapters completion:completionBlock type:4 isrefresh:NO];
        //            } else {
        //                [self createReadModelWithBook:book historyModel:historyModel chapters:chapterModel.chapters completion:completionBlock type:2 isrefresh:NO];
        //            }
        //
        //            // 设定“后台增量”游标起点：本地没有章节从 0 拉；有则从已拉数量之后继续拉。
        //            if (!NIIsArrayWithObjects(chapterModel.chapters)) {
        //                self.offset_back = 0;
        //                self.limit_back = 500;
        //            }else{
        //                self.offset_back = chapterModel.chapters.count;
        //                self.limit_back = 500;
        //            }
        
        
        if chapterModel.dir_ver == -1 {
            
            NetWorkRequest(ReadNetworkManager.chapterDirAll(bookId: bookId, dirVer: "-1")) { result in
                guard let data = result as? [String: Any] else { return }
                guard let dic = data["directory"] as? [[String: Any]] else { return }
                let array = dic.kj.modelArray(ChapterModel.self)
                
                //TODO先按全部章节走
                let bookModel = BookModel()
                bookModel.chapters = array
                bookModel.com_book_id = self.bookId
                self.readModel = ReadModel()
                self.readModel?.bookModek = bookModel
                if true {
                   //历史
                } else {
                    
                }
                
                self.readModel?.chapterIndex = 0
                
                self.requestChapterContent(index: 0, displayLastPage: false, isFirstPage: false)
            } failed: { msg, code in
                
                NetWorkRequest(ReadNetworkManager.chapterDirAllFile(bookId: self.bookId)) { result in
                    
                }
            }
            
        } else {
            
        }
        requestBookDetail(bookID: self.bookId)
        
    }
    
    func requestBookDetail(bookID: String) {
        NetWorkRequest(ReadNetworkManager.bookDetail(bookId: bookID, titlePage: 1)) { result in
            
        }
    }
    
    
    func requestChapterContent(index: Int, displayLastPage: Bool, isFirstPage: Bool) {
        
        guard let chapterModel = self.readModel?.bookModek?.chapters[index] else { return }
        
        loadChapter(chapterModel: chapterModel, bookModule: "")
    }
    
    ///加载某一章的内容模型
    func loadChapter(chapterModel: ChapterModel, bookModule: String) {

        NetWorkRequest(ReadNetworkManager.checkChapterNeedPay(chapterId: chapterModel.chapter_id, bookId: bookId, bookModule: "", bookModuleId: "", bookPosition: 0, source: "")) { result in
        
            guard let data = result as? [String: Any] else { return }
            let model = data.kj.model(CheckChapterPayModel.self)
            
            if (model.need_pay == false) {

                //下载章节内容
                guard !model.download_url.isEmpty else {
                    print("章节下载失败：download_url 为空")
                    return
                }

                ReadNetworkManager.downloadChapter(
                    url: model.download_url,
                    bookId: self.bookId,
                    chapterIndex: 1
                ) { progress in
                    print("下载进度: \(Int(progress * 100))%")
                } completion: { result in
                    switch result {
                    case .success(let localURL):
                        // 解密章节内容
                        self.decryptChapterContent(localURL: localURL, chapterModel: chapterModel)

                    case .failure(let error):
                        print("章节下载失败: \(error.localizedDescription)")
                        // TODO: 显示错误提示
                    }
                }

            } else {
                //TODO付费分支
            }
            
        }
    }

    /// 解密章节内容（使用 ChapterDecryptor + ios_decrypt_buffer）
    private func decryptChapterContent(localURL: URL, chapterModel: ChapterModel) {
        do {
            // 读取下载的加密文件
            let encryptedData = try Data(contentsOf: localURL)

            // 使用 ChapterDecryptor 解密（ios_decrypt_buffer + gunzip）
            guard let content = ChapterDecryptor.decrypt(encryptedData) else {
                print("章节内容解密失败")
                return
            }

            let chapterContentModel = ChapterContentModel()
            chapterContentModel.chapterModel = chapterModel
            chapterContentModel.title = chapterModel.title ?? ""
            chapterContentModel.chapterIndex = 0

            // 构建带标题的完整内容
            let fullContent = (chapterModel.title ?? "") + "\n\n" + content
            chapterContentModel.content = fullContent

            // CoreText 精确排版
            let config = ReadPageLayoutEngine.Config(
                fontSize: self.currentFontConfig.fontSize,
                lineSpacing: self.currentFontConfig.lineSpacing,
                font: self.currentFontConfig.font()
            )
            let layoutResult = ReadPageLayoutEngine.paginate(
                content: fullContent,
                title: chapterModel.title ?? "",
                config: config
            )
            chapterContentModel.layoutResult = layoutResult
            chapterContentModel.pageCount = layoutResult.totalPages

            // 存到 ReadModel
            self.readModel?.currentChapterContent = chapterContentModel

            // 刷新 UIPageViewController,显示第一页
            self.reloadPageViewController(startIndex: 0)


        } catch {
            print("读取章节文件失败: \(error.localizedDescription)")
        }
    }


    private func reloadChapterData() {
        //TODO预加载上一章和下一章
        
        
    }
    

    /// 对外跳转接口：目录跳章、翻到指定页时调用（对应 OC 的 jumpChapterWithIndex:）。
    func jumpToPage(_ index: Int) {
        guard let target = contentVC(at: index), index != currentIndex else { return }
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([target], direction: direction, animated: true) { [weak self] _ in
            self?.currentIndex = index
        }
    }

    // MARK: - 手势交互
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        // 添加滑动手势，用于在菜单显示时隐藏菜单
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        // 如果菜单已显示，任何滑动都隐藏菜单
        if isMenuVisible && gesture.state == .began {
            toggleMenuBars()
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // 如果菜单已显示，任何点击都隐藏菜单
        if isMenuVisible {
            toggleMenuBars()
            return
        }

        // 菜单隐藏时才处理翻页
        let location = gesture.location(in: view)
        let screenWidth = view.bounds.width

        if location.x < screenWidth * 0.3 {
            // 左侧：前翻页
            gotoPreviousPage()
        } else if location.x > screenWidth * 0.7 {
            // 右侧：后翻页
            gotoNextPage()
        } else {
            // 中间：显示/隐藏菜单
            toggleMenuBars()
        }
    }

    private func gotoPreviousPage() {
        guard currentIndex > 0 else { return }
        jumpToPage(currentIndex - 1)
    }

    private func gotoNextPage() {
        guard currentIndex < totalPages - 1 else { return }
        jumpToPage(currentIndex + 1)
    }

    private func toggleMenuBars() {
        isMenuVisible.toggle()

        // 控制翻页交互：菜单显示时禁用翻页手势和数据源
        pageViewController.dataSource = isMenuVisible ? nil : self
        for gesture in pageViewController.gestureRecognizers {
            gesture.isEnabled = !isMenuVisible
        }

        // 顶部和底部工具栏显隐
        UIView.animate(withDuration: 0.25) {
            self.topMenuBar.alpha = self.isMenuVisible ? 1.0 : 0.0
            self.bottomMenuBar.alpha = self.isMenuVisible ? 1.0 : 0.0
        }
    }

    private func setupMenuBar() {
        // 顶部导航栏
        view.addSubview(topMenuBar)
        topMenuBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(44 + safeAreaTopSpace)
        }
        topMenuBar.alpha = 0.0 // 初始隐藏

        // 底部工具栏
        view.addSubview(bottomMenuBar)
        bottomMenuBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(60 + safeAreaBottomSpace)
        }
        bottomMenuBar.alpha = 0.0 // 初始隐藏
    }

    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func detailAction() {
        print("打开书籍详情")
        // TODO: 跳转到书籍详情页
    }

    @objc private func catalogAction() {
        print("打开目录")
        // TODO: 显示章节目录
    }

    @objc private func fontAction() {
        let fontSettingView = ReadFontSettingView(config: currentFontConfig)
        fontSettingView.onConfigChanged = { [weak self] newConfig in
            // 字体配置已更改，立即应用
            self?.currentFontConfig = newConfig
            self?.applyFontConfig(newConfig)
        }
        fontSettingView.show(in: view)
    }

    /// 应用阅读设置配置（亮度+主题色+翻页方式）
    private func applySettingConfig(_ config: ReadSettingConfig) {
        // 1. 应用亮度
        UIScreen.main.brightness = config.brightness

        // 2. 应用主题色
        let colors = config.themeColors()
        view.backgroundColor = colors.bg

        // 刷新当前页的主题色
        if let currentVC = pageViewController.viewControllers?.first as? PageContentViewController {
            currentVC.applyThemeColors(bg: colors.bg, text: colors.text)
        }

        // 3. 应用翻页方式（需要重建 UIPageViewController）
        if pageViewController.transitionStyle != config.transitionStyle() {
            rebuildPageViewController(config: config)
        }
    }

    /// 重建 UIPageViewController（翻页方式变更时调用）
    private func rebuildPageViewController(config: ReadSettingConfig) {
        // 记录当前页码
        let targetIndex = currentIndex

        // 移除旧的 pageViewController
        pageViewController.willMove(toParent: nil)
        pageViewController.view.removeFromSuperview()
        pageViewController.removeFromParent()

        // 创建新的 pageViewController
        let newPageVC = UIPageViewController(
            transitionStyle: config.transitionStyle(),
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 0]
        )
        newPageVC.delegate = self
        newPageVC.dataSource = isMenuVisible ? nil : self

        // 替换实例
        pageViewController = newPageVC

        // 添加到视图层级
        addChild(pageViewController)
        view.insertSubview(pageViewController.view, at: 0)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)

        // 恢复当前页
        if let vc = contentVC(at: targetIndex) {
            pageViewController.setViewControllers([vc], direction: .forward, animated: false)
        }

        // 禁用翻页手势（菜单显示时）
        if isMenuVisible {
            for gesture in pageViewController.gestureRecognizers {
                gesture.isEnabled = false
            }
        }
    }

    /// 应用字体配置（重新排版当前章节）
    private func applyFontConfig(_ config: ReadFontConfig) {
        guard let chapterContent = readModel?.currentChapterContent else { return }
        let content = chapterContent.content
        let title = chapterContent.title

        // 生成配置缓存键
        let cacheKey = "\(Int(config.fontSize))_\(config.lineSpacingLevel)_\(config.fontFamilyLevel)"

        // 检查缓存
        let newLayoutResult: ReadPageLayoutEngine.LayoutResult
        if let cached = layoutCache[cacheKey] {
            newLayoutResult = cached
        } else {
            let layoutConfig = ReadPageLayoutEngine.Config(
                fontSize: config.fontSize,
                lineSpacing: config.lineSpacing,
                font: config.font()
            )
            newLayoutResult = ReadPageLayoutEngine.paginate(
                content: content,
                title: title,
                config: layoutConfig
            )
            layoutCache[cacheKey] = newLayoutResult
        }

        // 更新排版结果
        chapterContent.layoutResult = newLayoutResult
        chapterContent.pageCount = newLayoutResult.totalPages

        // 老项目策略：保持页码，如果超出范围则退到最后一页
        var targetPage = currentIndex
        if targetPage >= newLayoutResult.totalPages && newLayoutResult.totalPages > 0 {
            targetPage = newLayoutResult.totalPages - 1
        }

        // 刷新 UIPageViewController
        reloadPageViewController(startIndex: targetPage)
    }

    /// 根据字符偏移量查找对应的页码
    private func findPageIndex(for characterOffset: Int, in layoutResult: ReadPageLayoutEngine.LayoutResult) -> Int {
        let offsets = layoutResult.pageOffsets

        // 二分查找：找到 <= characterOffset 的最大页码
        var left = 0
        var right = offsets.count - 1
        var result = 0

        while left <= right {
            let mid = (left + right) / 2
            if offsets[mid] <= characterOffset {
                result = mid
                left = mid + 1
            } else {
                right = mid - 1
            }
        }

        return result
    }

    @objc private func settingAction() {
        let settingView = ReadSettingView(config: currentSettingConfig)
        settingView.onConfigChanged = { [weak self] newConfig in
            self?.currentSettingConfig = newConfig
            self?.applySettingConfig(newConfig)
        }
        settingView.show(in: view)
    }
    
    private lazy var topMenuBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = .white

        // 返回按钮
        let backButton = UIButton(type: .custom)
        if let image = UIImage(systemName: "chevron.left") {
            backButton.setImage(image, for: .normal)
            backButton.tintColor = .textPrimaryColor
        }
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)

        // 标题
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .textPrimaryColor
        titleLabel.textAlignment = .center
        self.titleLabel = titleLabel
        
        // 详情按钮
        let detailButton = UIButton(type: .custom)
        if let image = UIImage(systemName: "ellipsis.circle") {
            detailButton.setImage(image, for: .normal)
            detailButton.tintColor = .textPrimaryColor
        }
        detailButton.addTarget(self, action: #selector(detailAction), for: .touchUpInside)

        bar.addSubview(backButton)
        bar.addSubview(titleLabel)
        bar.addSubview(detailButton)

        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
            make.left.greaterThanOrEqualTo(backButton.snp.right).offset(8)
            make.right.lessThanOrEqualTo(detailButton.snp.left).offset(-8)
        }

        detailButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(44)
        }

        return bar
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        return titleLabel
    }()
    
    private lazy var bottomMenuBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = .white

        // 目录按钮
        let catalogButton = createMenuButton(title: "目录", imageName: "list.bullet")
        catalogButton.addTarget(self, action: #selector(catalogAction), for: .touchUpInside)

        // 字体按钮
        let fontButton = createMenuButton(title: "字体", imageName: "textformat.size")
        fontButton.addTarget(self, action: #selector(fontAction), for: .touchUpInside)

        // 设置按钮
        let settingButton = createMenuButton(title: "设置", imageName: "gearshape")
        settingButton.addTarget(self, action: #selector(settingAction), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [catalogButton, fontButton, settingButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center

        bar.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: safeAreaBottomSpace, right: 20))
        }

        return bar
    }()

    private func createMenuButton(title: String, imageName: String) -> UIButton {
        let button = UIButton(type: .custom)

        // 先设置图标
        if let image = UIImage(systemName: imageName) {
            button.setImage(image, for: .normal)
            button.tintColor = .textSecondaryColor
        }

        // 用 NSAttributedString 设置标题，确保字体正确
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.textSecondaryColor
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)

        button.adjustImageTitlePosition(.top, spacing: 4)
        return button
    }

    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [.interPageSpacing: 0])
        pageVC.delegate = self
        pageVC.dataSource = self
        return pageVC
    }()

    // MARK: - 滚动模式容器
    
    // MARK: - 工厂：按全局页码造一个单页 VC
    private func contentVC(at index: Int) -> PageContentViewController? {
        guard let layoutResult = layoutResult, index < totalPages else { return nil }

        let range = layoutResult.range(of: index, contentLength: currentContent.count)
        guard range.location != NSNotFound else { return nil }

        let pageContent = (currentContent as NSString).substring(with: range)

        let vc = PageContentViewController()
        vc.pageIndex = index
        vc.content = pageContent
        vc.isFirstPage = (index == 0)
        vc.chapterTitle = readModel?.currentChapterContent?.title ?? ""
        vc.updateProgress(currentPage: index, totalPages: totalPages)
        vc.updateBookName(bookModel?.title ?? "")

        // 应用当前字体配置
        vc.applyFontConfig(currentFontConfig)

        // 应用当前主题配置
        let colors = currentSettingConfig.themeColors()
        vc.applyThemeColors(bg: colors.bg, text: colors.text)

        return vc
    }

}


extension ReadPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PageContentViewController else { return nil }
        return contentVC(at: vc.pageIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PageContentViewController else { return nil }
        return contentVC(at: vc.pageIndex + 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let visibleVC = pageViewController.viewControllers?.first as? PageContentViewController else {
            return
        }
        currentIndex = visibleVC.pageIndex
        print("🔍 [翻页完成] 更新 currentIndex = \(currentIndex)")
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ReadPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 允许 pan 手势和 pageViewController 的手势同时识别
        return true
    }
}

// MARK: - 刷新 UI
extension ReadPageViewController {

    /// 刷新 UIPageViewController,显示指定页(章节加载完毕后调用)
    private func reloadPageViewController(startIndex: Int) {
        guard let firstVC = contentVC(at: startIndex) else {
            print("⚠️ 无法创建起始页 VC,章节内容可能为空")
            return
        }

        currentIndex = startIndex
        pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
    }
}
