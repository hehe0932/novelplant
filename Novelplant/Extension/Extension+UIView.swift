//
//  Extension+UIView.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
import UIKit

extension UIView {
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    var width: CGFloat {
        get {
            
            return frame.width
        }
        set {
            frame.size.width = newValue
        }
    }
    var height: CGFloat {
        get {
            return frame.height
        }
        set {
            frame.size.height = newValue
        }
    }
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center.x = newValue
        }
    }
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center.y = newValue
        }
        
    }
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }
    
}
// MARK: 方法
extension UIView {
    
    class func viewFromNib() -> UIView {
        
        var clsStr = NSStringFromClass(self.classForCoder())
        
        clsStr = clsStr.components(separatedBy: ".").last!
        
        return Bundle.main.loadNibNamed(clsStr, owner: nil, options: nil)?.first as! UIView
    }
    
    class func viewFromNib(nibname: String?) -> UIView {
        
        var clsStr = NSStringFromClass(self.classForCoder())
        
        clsStr = clsStr.components(separatedBy: ".").last!
        
        let loadName = nibname == nil ? clsStr : nibname
        
        return Bundle.main.loadNibNamed(loadName ?? "", owner: nil, options: nil)?.first as! UIView
    }
    
    func removeAllSubView() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
}


//MARK: 圆角
extension UIView {
    //部分圆角
    func addCorner(corners: UIRectCorner , radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}

//MARK: 四周阴影
extension UIView {
    enum ShadowType: Int {
        case all = 0 ///四周
        case top  = 1 ///上方
        case left = 2///左边
        case right = 3///右边
        case bottom = 4///下方
    }
    ///默认设置：黑色阴影
    func shadow(_ type: ShadowType) {
        shadow(type: type, color: .hex("111111"), opactiy: 0.4, shadowSize: 4)
    }
    ///常规设置
    func shadow(type: ShadowType, color: UIColor,  opactiy: Float, shadowSize: CGFloat) -> Void {
        layer.masksToBounds = false;//必须要等于NO否则会把阴影切割隐藏掉
        layer.shadowColor = color.cgColor;// 阴影颜色
        layer.shadowOpacity = opactiy;// 阴影透明度，默认0
        layer.shadowOffset = .zero;//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
        layer.shadowRadius = 3 //阴影半径，默认3
//        layer.cornerRadius = 5
        var shadowRect: CGRect?
        switch type {
        case .all:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: bounds.size.width + 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        case .top:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: bounds.size.width + 2 * shadowSize, height: 2 * shadowSize)
        case .bottom:
            shadowRect = CGRect.init(x: -shadowSize, y: bounds.size.height - shadowSize, width: bounds.size.width + 2 * shadowSize, height: 2 * shadowSize)
        case .left:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        case .right:
            shadowRect = CGRect.init(x: bounds.size.width - shadowSize, y: -shadowSize, width: 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        }
        layer.shadowPath = UIBezierPath.init(rect: shadowRect!).cgPath
    }
    
    /// 添加圆角和阴影 radius:圆角半径 shadowOpacity: 阴影透明度 (0-1) shadowColor: 阴影颜色
    func addRoundedOrShadow(radius: CGFloat, shadowOpacity: CGFloat, shadowColor: UIColor)  {
        self.layer.cornerRadius = radius
//        self.layer.masksToBounds = true
        let subLayer = CALayer()
        let fixframe = self.frame
        let newFrame = CGRect(x: fixframe.minX - (375 - UIScreen.main.bounds.size.width)/2, y: fixframe.minY, width: fixframe.width, height: fixframe.height)
        subLayer.frame = newFrame
        subLayer.cornerRadius = radius
//        subLayer.backgroundColor = UIColor.white.cgColor
        subLayer.masksToBounds = false
        subLayer.shadowColor = shadowColor.cgColor // 阴影颜色
        subLayer.shadowOffset = CGSize(width: 0, height: 2) // 阴影偏移,width:向右偏移3，height:向下偏移2，默认(0, -3),这个跟shadowRadius配合使用
        subLayer.shadowOpacity = Float(shadowOpacity) //阴影透明度
        subLayer.shadowRadius = 5;//阴影半径，默认3
        self.superview?.layer.insertSublayer(subLayer, below: self.layer)
    }
}
///下划线
extension UIView {
    
    func addBottomLine(inset: UIEdgeInsets, viewSize: CGSize, color: UIColor? = .hex("#F5F5F5")) {
        let subLayer = CALayer()
        subLayer.frame = CGRect(x: inset.left, y: viewSize.height , width: viewSize.width - abs(inset.left) - abs(inset.right), height: 0.5)
        subLayer.backgroundColor = color?.cgColor
        layer.addSublayer(subLayer)
    }
    
    func addTopLine(inset: UIEdgeInsets, viewSize: CGSize, color: UIColor? = .hex("#F5F5F5")) {
        let subLayer = CALayer()
        subLayer.frame = CGRect(x: inset.left, y: 0, width: viewSize.width - abs(inset.left) - abs(inset.right), height: 0.5)
        subLayer.backgroundColor = color?.cgColor
        layer.addSublayer(subLayer)
    }
    
    func addLeftLine(inset: UIEdgeInsets, viewSize: CGSize, color: UIColor? = .hex("#F5F5F5")) {
        let subLayer = CALayer()
        subLayer.frame = CGRect(x: 0, y: abs(inset.top), width: 0.5, height: viewSize.height - abs(inset.top) - abs(inset.bottom))
        subLayer.backgroundColor = color?.cgColor
        layer.addSublayer(subLayer)
    }
    
    func addRightLine(inset: UIEdgeInsets, viewSize: CGSize, color: UIColor? = .hex("#F5F5F5")) {
        let subLayer = CALayer()
        subLayer.frame = CGRect(x: viewSize.width, y: abs(inset.top), width: 0.5, height: viewSize.height - abs(inset.top) - abs(inset.bottom))
        subLayer.backgroundColor = color?.cgColor
        layer.addSublayer(subLayer)
    }
}


extension CALayer {
    func pauseLayer() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        timeOffset = pausedTime
        speed = 0.0
    }

    func resumeLayer() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0

        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause

    }
}


