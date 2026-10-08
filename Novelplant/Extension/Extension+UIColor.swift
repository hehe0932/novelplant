//
//  Extension+UIColor.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
import UIKit

extension UIColor {
    static let bgColor: UIColor = .hex("#111111")
    
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
