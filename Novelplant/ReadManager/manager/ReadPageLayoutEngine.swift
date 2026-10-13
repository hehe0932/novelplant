//
//  ReadPageLayoutEngine.swift
//  novelplant
//
//  Created by Claude on 2026/10/13.
//

import UIKit
import CoreText

/// 阅读器排版引擎(CoreText 分页)
class ReadPageLayoutEngine {

    // MARK: - 配置
    struct Config {
        let font: UIFont
        let lineSpacing: CGFloat
        let pageSize: CGRect

        static var `default`: Config {
            let safeTop = safeAreaTopSpace
            let safeBottom = safeAreaBottomSpace

            return Config(
                font: .systemFont(ofSize: 18),
                lineSpacing: 8,
                pageSize: CGRect(
                    x: 20,
                    y: safeTop + 40,
                    width: screenW - 40,
                    height: screenH - safeTop - safeBottom - 60
                )
            )
        }

        /// 使用自定义字体配置创建
        init(fontSize: CGFloat, lineSpacing: CGFloat, font: UIFont) {
            let safeTop = safeAreaTopSpace
            let safeBottom = safeAreaBottomSpace

            self.font = font
            self.lineSpacing = lineSpacing
            self.pageSize = CGRect(
                x: 20,
                y: safeTop + 40,
                width: screenW - 40,
                height: screenH - safeTop - safeBottom - 60
            )
        }

        /// 标准初始化
        init(font: UIFont, lineSpacing: CGFloat, pageSize: CGRect) {
            self.font = font
            self.lineSpacing = lineSpacing
            self.pageSize = pageSize
        }
    }

    // MARK: - 排版结果
    struct LayoutResult {
        let pageOffsets: [Int]  // 每页的起始字符偏移量
        let totalPages: Int

        /// 根据页码获取该页在原文中的范围
        func range(of page: Int, contentLength: Int) -> NSRange {
            guard page >= 0, page < pageOffsets.count else {
                return NSRange(location: NSNotFound, length: 0)
            }

            let location = pageOffsets[page]
            let length: Int
            if page < pageOffsets.count - 1 {
                length = pageOffsets[page + 1] - location
            } else {
                length = contentLength - location
            }
            return NSRange(location: location, length: length)
        }
    }

    // MARK: - 排版入口
    /// 对章节内容进行分页排版
    /// - Parameters:
    ///   - content: 章节原文(应包含标题)
    ///   - title: 章节标题(用于应用不同样式)
    ///   - config: 排版配置
    /// - Returns: 分页结果
    static func paginate(content: String, title: String, config: Config = .default) -> LayoutResult {
        guard !content.isEmpty else {
            return LayoutResult(pageOffsets: [], totalPages: 0)
        }

        // 构建富文本(标题 + 正文)
        let attrString = buildAttributedString(content: content, title: title, config: config)

        // CoreText 分页
        let pageOffsets = paginateWithCoreText(attrString: attrString, bounds: config.pageSize)

        return LayoutResult(pageOffsets: pageOffsets, totalPages: pageOffsets.count)
    }

    // MARK: - 私有方法
    private static func buildAttributedString(content: String, title: String, config: Config) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: content)

        // 段落样式(行间距)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = config.lineSpacing

        // 标题样式(粗体 + 居中)
        if title.count > 0 {
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
                .foregroundColor: UIColor.textPrimaryColor,
                .paragraphStyle: titleStyle
            ]
            attrString.setAttributes(titleAttributes, range: NSRange(location: 0, length: title.count))
        }

        // 正文样式
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: config.font,
            .foregroundColor: UIColor.textPrimaryColor,
            .paragraphStyle: paragraphStyle
        ]
        attrString.setAttributes(contentAttributes, range: NSRange(location: title.count, length: attrString.length - title.count))

        return attrString
    }

    private static func paginateWithCoreText(attrString: NSAttributedString, bounds: CGRect) -> [Int] {
        var pageOffsets: [Int] = []

        let frameSetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        let path = CGPath(rect: bounds, transform: nil)

        var currentOffset = 0
        var currentInnerOffset = 0
        var hasMorePages = true

        // 防死循环(同一位置重复超过 2 次则退出)
        var preventDeadLoopSign = currentOffset
        var samePlaceRepeatCount = 0

        while hasMorePages {
            if preventDeadLoopSign == currentOffset {
                samePlaceRepeatCount += 1
            } else {
                samePlaceRepeatCount = 0
            }

            if samePlaceRepeatCount > 1 {
                // 退出前检查最后一页是否已加入
                if pageOffsets.isEmpty {
                    pageOffsets.append(currentOffset)
                } else if pageOffsets.last != currentOffset {
                    pageOffsets.append(currentOffset)
                }
                break
            }

            pageOffsets.append(currentOffset)
            preventDeadLoopSign = currentOffset

            let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, nil)
            let range = CTFrameGetVisibleStringRange(frame)

            if (range.location + range.length) != attrString.length {
                currentOffset += range.length
                currentInnerOffset += range.length
            } else {
                hasMorePages = false
            }
        }

        return pageOffsets
    }
}
