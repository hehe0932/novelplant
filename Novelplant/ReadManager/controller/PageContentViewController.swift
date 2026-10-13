import UIKit
///TODO 这里差付费页展示和登录页展示
/// 单页内容容器：UIPageViewController 的每一”页”都是它的一个实例。
/// 使用 CoreText 自绘视图来渲染文本内容
class PageContentViewController: BaseViewController {

    /// 全局页码（从 0 开始）。UIPageViewController 的 DataSource 正是靠这个字段
    /// 来判断”上一页是谁、下一页是谁”，以及”是否到头/到尾”。
    var pageIndex: Int = 0

    /// 本页正文
    var content: String = "" {
        didSet {
            readView.pageContent = content
        }
    }

    /// 是否是第一页(需要显示标题)
    var isFirstPage: Bool = false {
        didSet {
            readView.isFirstPage = isFirstPage
        }
    }

    /// 章节标题
    var chapterTitle: String = "" {
        didSet {
            readView.chapterTitle = chapterTitle
            chapterLabel.text = chapterTitle
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenNavigationBar = true
        view.backgroundColor = .readingBgColor

        setupViews()
        updateBottomInfo()
        startTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(readView)
        view.addSubview(bottomInfoContainer)

        bottomInfoContainer.addSubview(progressLabel)
//        bottomInfoContainer.addSubview(nameLabel)
        view.addSubview(chapterLabel)
        bottomInfoContainer.addSubview(timeLabel)
        bottomInfoContainer.addSubview(batteryView)

        readView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bottomInfoContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(24)
        }

        // 左侧：章节名
        chapterLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(statusBarHeight)
            make.width.lessThanOrEqualTo(screenW - 40)
        }

        // 中间：进度
        progressLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // 右侧（从右到左）：电量 - 时间 - 书名
        batteryView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(10)
        }

        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(batteryView.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }

//        nameLabel.snp.makeConstraints { make in
//            make.right.equalTo(timeLabel.snp.left).offset(-12)
//            make.centerY.equalToSuperview()
//            make.width.lessThanOrEqualTo(100)
//        }
    }

    // MARK: - Update
    private func updateBottomInfo() {
        updateTime()
    }

    private func updateTime() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: Date())
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    /// 更新进度显示（由外部调用，传入当前页码和总页数）
    func updateProgress(currentPage: Int, totalPages: Int) {
        progressLabel.text = "\(currentPage + 1)/\(totalPages)"
    }

    /// 更新书名显示
    func updateBookName(_ name: String) {
        nameLabel.text = name
    }

    /// 应用字体配置
    func applyFontConfig(_ config: ReadFontConfig) {
        let layoutConfig = ReadPageLayoutEngine.Config(
            fontSize: config.fontSize,
            lineSpacing: config.lineSpacing,
            font: config.font()
        )
        readView.config = layoutConfig
        readView.setNeedsDisplay()
    }

    /// 应用主题配置（背景色+文字色）
    func applyThemeColors(bg: UIColor, text: UIColor) {
        view.backgroundColor = bg
        readView.backgroundColor = bg
        progressLabel.textColor = text
        chapterLabel.textColor = text
        timeLabel.textColor = text
        readView.textColor = text
        readView.setNeedsDisplay()
    }

    // MARK: - Views
    private lazy var readView: ReadContentView = {
        let readView = ReadContentView()
        return readView
    }()

    private lazy var bottomInfoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .textTertiaryColor
        label.textAlignment = .center
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .textTertiaryColor
        label.textAlignment = .right
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var chapterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .textTertiaryColor
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .textTertiaryColor
        label.textAlignment = .right
        return label
    }()

    private var timer: Timer = Timer()

    private lazy var batteryView: BatteryView = {
        let batteryView = BatteryView()
        return batteryView
    }()
}
