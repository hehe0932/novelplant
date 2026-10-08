//
//  Extension+String.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
import UIKit

extension String {
    
    //获取 宽度
    func stringWidth(_ font:UIFont) -> CGFloat{
        
        let nsStr = self as NSString
        
        return nsStr.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: screenH), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).width
    }
    
    //获取 高度
    func stringHeight(_ maxWidth:CGFloat ,_ font:UIFont) -> CGFloat{
        
        let nsStr = self as NSString
        
        return nsStr.boundingRect(with: CGSize(width:maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).height
    }
    
    func stringHeight(_ maxWidth:CGFloat , attributes: [NSAttributedString.Key : Any]? = nil) -> CGFloat {
        let nsStr = self as NSString
        
        return nsStr.boundingRect(with: CGSize(width:maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).height
    }
    
    var isValidPhoneCode: Bool {
        let expression = try? NSRegularExpression(pattern: String.phoneRegular, options: [])
        if let results = expression?.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)), results.count != 0 {
            return true
        }
        return false
    }
    
    // 判断手机号正则，首位数字1的11位数字
    static public let phoneRegular = "^1[0-9]{10}$"
    // 判断身份证正则
    static public let idCardRegular = "^[1-9]{5}(18|19|([23])){2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31){3}[0-9Xx]$"
    // 判断密码6位重复数字
    static public let repeatNumRegular = "^1{5}$"

    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    /// 查找所有的子字符串所在位置
    func findAllIndex(_ string: String) -> [NSRange] {
        var ranges: [NSRange] = []
        if string.elementsEqual("") {
            return ranges
        }
        let zero = self.startIndex
        let target = Array(string)
        let total = Array(self)
        
        let lenght = string.count
        var startPoint = 0
        
        while total.count >= startPoint + string.count {
            if total[startPoint] == target[0] {
                let startIndex = self.index(zero, offsetBy: startPoint)
                let endIndex = self.index(startIndex, offsetBy: lenght)
                let child = self[startIndex..<endIndex]
                if child.elementsEqual(string) {
                    ranges.append(NSRange.init(location: startPoint, length: lenght))
                    startPoint += lenght
                }else{
                    startPoint += 1
                }
            }else{
                startPoint += 1
            }
        }
        
        return ranges
    }
}
//字符串截取
extension String {
    subscript(_ indexs: ClosedRange<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[beginIndex...endIndex])
    }
    
    subscript(_ indexs: Range<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[beginIndex..<endIndex])
    }
    
    subscript(_ indexs: PartialRangeThrough<Int>) -> String {
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[startIndex...endIndex])
    }
    
    subscript(_ indexs: PartialRangeFrom<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        return String(self[beginIndex..<endIndex])
    }
    
    subscript(_ indexs: PartialRangeUpTo<Int>) -> String {
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

extension NSAttributedString {
    convenience init(string: String, font: UIFont, color: UIColor) {
        self.init(string: string, attributes: [.font: font, .foregroundColor: color])
    }
}

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard data(using: .utf8) != nil else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: Data(utf8),
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error:", error)
            return NSAttributedString()
        }
    }
}
