//
//  ReadFontConfig.swift
//  novelplant
//
//  Created by hehe on 2026/10/13.
//

import UIKit

/// 字体配置模型
class ReadFontConfig {

    /// 字体大小（12-28）
    var fontSize: CGFloat = 18

    /// 行间距挡位（0:紧凑 1:标准 2:宽松）
    var lineSpacingLevel: Int = 1

    /// 字体挡位（0:系统 1:Merriweather 2:Georgia）
    var fontFamilyLevel: Int = 0

    /// 行间距值
    var lineSpacing: CGFloat {
        switch lineSpacingLevel {
        case 0: return 4
        case 1: return 8
        case 2: return 12
        default: return 8
        }
    }

    /// 字体名称
    var fontName: String {
        switch fontFamilyLevel {
        case 0: return "System"
        case 1: return "Merriweather-Regular"
        case 2: return "Georgia"
        default: return "System"
        }
    }

    /// 获取 UIFont 对象
    func font() -> UIFont {
        if fontFamilyLevel == 0 {
            return .systemFont(ofSize: fontSize)
        } else if let customFont = UIFont(name: fontName, size: fontSize) {
            return customFont
        }
        return .systemFont(ofSize: fontSize)
    }

    // MARK: - 持久化
    private static let userDefaultsKey = "ReadFontConfig"

    /// 保存配置
    func save() {
        let dic: [String: Any] = [
            "fontSize": fontSize,
            "lineSpacingLevel": lineSpacingLevel,
            "fontFamilyLevel": fontFamilyLevel
        ]
        UserDefaults.standard.set(dic, forKey: Self.userDefaultsKey)
        UserDefaults.standard.synchronize()
    }

    /// 加载配置
    static func load() -> ReadFontConfig {
        let config = ReadFontConfig()
        guard let dic = UserDefaults.standard.dictionary(forKey: userDefaultsKey) else {
            return config
        }
        if let fontSize = dic["fontSize"] as? CGFloat {
            config.fontSize = fontSize
        }
        if let lineSpacingLevel = dic["lineSpacingLevel"] as? Int {
            config.lineSpacingLevel = lineSpacingLevel
        }
        if let fontFamilyLevel = dic["fontFamilyLevel"] as? Int {
            config.fontFamilyLevel = fontFamilyLevel
        }
        return config
    }
}
