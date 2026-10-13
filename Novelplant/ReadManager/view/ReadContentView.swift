//
//  ReadContentView.swift
//  novelplant
//
//  Created by hehe on 2026/10/13.
//

import UIKit
import CoreText

/// CoreText 自绘阅读内容视图
class ReadContentView: UIView {

    // MARK: - 属性
    private var ctFrame: CTFrame?

    /// 页面内容(设置后自动重绘)
    var pageContent: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 是否是标题页(第一页需要显示标题)
    var isFirstPage: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 章节标题
    var chapterTitle: String = ""

    /// 排版配置
    var config: ReadPageLayoutEngine.Config = .default

    /// 文字颜色
    var textColor: UIColor = .textPrimaryColor {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .readingBgColor
        isOpaque = true
    }

    // MARK: - CoreText 绘制
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // CoreText 坐标系是左下角为原点,需要翻转
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // 构建富文本
        let attrString = buildAttributedString()

        // 将 UIKit 坐标系的 pageSize 转换为 CoreText 坐标系
        // UIKit: 原点左上角, y向下 → CoreText: 原点左下角, y向上
        let coreTextRect = CGRect(
            x: config.pageSize.origin.x,
            y: bounds.height - config.pageSize.origin.y - config.pageSize.height,
            width: config.pageSize.width,
            height: config.pageSize.height
        )

        // 创建 CTFrame
        let frameSetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        let path = CGPath(rect: coreTextRect, transform: nil)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)

        // 绘制文本
        CTFrameDraw(frame, context)

        // 保存 frame 供后续交互使用(如文字选择)
        self.ctFrame = frame
    }

    // MARK: - 构建富文本
    private func buildAttributedString() -> NSAttributedString {
        guard !pageContent.isEmpty else {
            return NSAttributedString(string: "")
        }

        let attrString = NSMutableAttributedString(string: pageContent)

        // 段落样式(行间距)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = config.lineSpacing

        // 如果是第一页且有标题,应用标题样式
        if isFirstPage && !chapterTitle.isEmpty && pageContent.hasPrefix(chapterTitle) {
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.alignment = .center
            titleStyle.lineSpacing = config.lineSpacing

            // 标题使用加粗版本的当前字体，字号+2
            let titleFont: UIFont
            if let fontName = config.font.fontName as String?, fontName.lowercased().contains("system") {
                titleFont = UIFont.boldSystemFont(ofSize: config.font.pointSize + 2)
            } else if let boldFont = UIFont(name: config.font.fontName + "-Bold", size: config.font.pointSize + 2) {
                titleFont = boldFont
            } else {
                // 如果没有粗体版本，使用原字体但加大字号
                titleFont = UIFont(name: config.font.fontName, size: config.font.pointSize + 2) ?? config.font
            }

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: textColor,
                .paragraphStyle: titleStyle
            ]
            attrString.setAttributes(titleAttributes, range: NSRange(location: 0, length: chapterTitle.count))

            // 正文样式
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: config.font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            if attrString.length > chapterTitle.count {
                attrString.setAttributes(contentAttributes, range: NSRange(location: chapterTitle.count, length: attrString.length - chapterTitle.count))
            }
        } else {
            // 纯正文样式
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: config.font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            attrString.setAttributes(contentAttributes, range: NSRange(location: 0, length: attrString.length))
        }

        return attrString
    }

    // MARK: - 公共方法
    /// 设置页面内容并刷新显示
    func setContent(_ content: String, isFirstPage: Bool, chapterTitle: String) {
        self.pageContent = content
        self.isFirstPage = isFirstPage
        self.chapterTitle = chapterTitle
    }
}
