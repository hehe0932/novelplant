//
//  ReadSettingConfig.swift
//  novelplant
//
//  Created by hehe on 2026/10/13.
//

import UIKit

/// 阅读设置配置模型
class ReadSettingConfig {

    /// 亮度 (0.0-1.0)
    var brightness: CGFloat = UIScreen.main.brightness

    /// 主题色索引 (0:米黄 1:灰白 2:青绿 3:护眼黄 4:夜间黑)
    var themeIndex: Int = 0

    /// 翻页方式 (0:仿真翻页 1:平滑滑动)
    var pageTransitionMode: Int = 0

    /// 主题色映射
    func themeColors() -> (bg: UIColor, text: UIColor) {
        switch themeIndex {
        case 0: return (UIColor(hex: "#F5EDD8"), UIColor(hex: "#333333"))  // 米黄
        case 1: return (UIColor(hex: "#FFFFFF"), UIColor(hex: "#1A1A1A"))  // 灰白
        case 2: return (UIColor(hex: "#E3F2E1"), UIColor(hex: "#2C5F2D"))  // 青绿
        case 3: return (UIColor(hex: "#FFE4E9"), UIColor(hex: "#8B4C5C"))  // 浅粉
        case 4: return (UIColor(hex: "#1C1C1E"), UIColor(hex: "#CCCCCC"))  // 夜间黑
        default: return (UIColor(hex: "#F5EDD8"), UIColor(hex: "#333333"))
        }
    }

    /// 翻页动画样式
    func transitionStyle() -> UIPageViewController.TransitionStyle {
        return pageTransitionMode == 0 ? .pageCurl : .scroll
    }

    // MARK: - 持久化
    private static let userDefaultsKey = "ReadSettingConfig"

    /// 保存配置
    func save() {
        let dic: [String: Any] = [
            "brightness": brightness,
            "themeIndex": themeIndex,
            "pageTransitionMode": pageTransitionMode
        ]
        UserDefaults.standard.set(dic, forKey: Self.userDefaultsKey)
        UserDefaults.standard.synchronize()
    }

    /// 加载配置
    static func load() -> ReadSettingConfig {
        let config = ReadSettingConfig()
        guard let dic = UserDefaults.standard.dictionary(forKey: userDefaultsKey) else {
            return config
        }
        if let brightness = dic["brightness"] as? CGFloat {
            config.brightness = brightness
        }
        if let themeIndex = dic["themeIndex"] as? Int {
            config.themeIndex = themeIndex
        }
        if let pageTransitionMode = dic["pageTransitionMode"] as? Int {
            config.pageTransitionMode = pageTransitionMode
        }
        return config
    }
}
