//
//  Extension+UIColor.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
import UIKit

//全局color（浅色/深色自适应，跟随系统深色模式）
extension UIColor {

    /// 页面主背景色
    static let bgColor = UIColor(hex: "#F6F7FB", darkHex: "#111111")

    /// 导航栏背景色
    static let navBgColor = UIColor(hex: "#FFFFFF", darkHex: "#1C1C1E")

    /// 卡片/Cell 背景色（比页面背景高一级层次）
    static let cellBgColor = UIColor(hex: "#FFFFFF", darkHex: "#1E1E1E")

    /// 主题色（品牌橙：按钮高亮、价格、选中态、书架强调）
    static let themeColor = UIColor(hex: "#FF7A2E", darkHex: "#FF8A3D")

    /// 阅读页护眼底色（米黄护眼 / 深灰夜间）
    static let readingBgColor = UIColor(hex: "#F5EDD8", darkHex: "#1C1C1E")

    /// 主文字色（标题、正文）
    static let textPrimaryColor = UIColor(hex: "#1A1A1A", darkHex: "#EAEAEA")

    /// 次要文字色（副标题、说明、摘要）
    static let textSecondaryColor = UIColor(hex: "#666666", darkHex: "#999999")

    /// 三级文字色（占位符、时间戳、辅助信息）
    static let textTertiaryColor = UIColor(hex: "#999999", darkHex: "#666666")

    /// 分割线颜色
    static let separatorColor = UIColor(hex: "#E5E6EB", darkHex: "#333333")

    /// 弹窗/菜单遮罩色
    static let maskColor = UIColor(hex: "#000000", darkHex: "#000000", alpha: 0.4, darkAlpha: 0.6)

    /// 图片占位底色（封面/头像等加载前的灰底）
    static let placeholderColor = UIColor(hex: "#E9EBF0", darkHex: "#2A2A2A")

    /// Apple 登录按钮底色（对齐 Apple 官方按钮：浅色黑底 / 深色白底）
    static let appleBtnBgColor = UIColor(hex: "#000000", darkHex: "#FFFFFF")

    /// Apple 登录按钮图文色（对齐 Apple 官方按钮：浅色白字 / 深色黑字）
    static let appleBtnTitleColor = UIColor(hex: "#FFFFFF", darkHex: "#000000")

    /// 主题色底上的前景色（主按钮白字、选中态勾选图标，两种模式恒为白）
    static let onThemeColor = UIColor(hex: "#FFFFFF", darkHex: "#FFFFFF")
}
extension UIColor {
    
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    
    static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a:CGFloat) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    static func hex(_ hex: String) -> UIColor {
        ///  支持格式包括： #ff21af64   #21af64   0x21af64
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(scanner.string.startIndex, offsetBy: 1)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x0000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        return self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let r, g, b, a: CGFloat
        var hexColor = hex
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            hexColor = String(hex[start...])
        }
        
        if hex.hasPrefix("0x") {
            let start = hex.index(hex.startIndex, offsetBy: 2)
            hexColor = String(hex[start...])
        }
        
        if hex.hasPrefix("0X") {
            let start = hex.index(hex.startIndex, offsetBy: 2)
            hexColor = String(hex[start...])
        }

        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255

                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        } else if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255

                self.init(red: r, green: g, blue: b, alpha: alpha)
                return
            }
        }

        self.init(red: 0, green: 0, blue: 0, alpha: alpha)
    }
    
    convenience init(hex: String, darkHex: String, alpha: CGFloat = 1.0, darkAlpha: CGFloat = 1.0) {
        if #available(iOS 13.0, *) {
            
            self.init { (trait) -> UIColor in
                if (trait.userInterfaceStyle == .dark) {
                    return UIColor.init(hex: darkHex, alpha: darkAlpha)
                }else{
                    return UIColor.init(hex: hex, alpha: alpha)
                }
            }
        } else {
            self.init(hex: hex, alpha: alpha)
        }
    }
    
    static func colorWithHexString(_ colorStr: String) -> UIColor {
        return UIColor(hex: colorStr)
    }
    
    
}
