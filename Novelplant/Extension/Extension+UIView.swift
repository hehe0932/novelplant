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
///渐变色
extension UIView {
    
    @discardableResult
    func addGradient(colors: [UIColor],
                     point: (CGPoint, CGPoint) = (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1)),
                     locations: [NSNumber] = [0, 1],
                     frame: CGRect = CGRect.zero,
                     radius: CGFloat = 0,
                     at: UInt32 = 0) -> CAGradientLayer {
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = colors.map { $0.cgColor }
        bgLayer1.locations = locations
        if frame == .zero {
            bgLayer1.frame = self.bounds
        } else {
            bgLayer1.frame = frame
        }
        bgLayer1.startPoint = point.0
        bgLayer1.endPoint = point.1
        bgLayer1.cornerRadius = radius
        self.layer.insertSublayer(bgLayer1, at: at)
        return bgLayer1
    }
    
    func addGradient(start: CGPoint = CGPoint(x: 0.5, y: 0),
                     end: CGPoint = CGPoint(x: 0.5, y: 1),
                     colors: [UIColor],
                     locations: [NSNumber] = [0, 1],
                     frame: CGRect = CGRect.zero,
                     radius: CGFloat = 0,
                     at: UInt32 = 0) {
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = colors.map { $0.cgColor }
        bgLayer1.locations = locations
        bgLayer1.frame = frame
        bgLayer1.startPoint = start
        bgLayer1.endPoint = end
        bgLayer1.cornerRadius = radius
        self.layer.insertSublayer(bgLayer1, at: at)
    }
    
    func addGradient(start_color:String,end_color : String,frame : CGRect?=nil,cornerRadius : CGFloat?=0, at: UInt32 = 0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(hex: start_color).cgColor, UIColor(hex: end_color).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0.21, y: 0.14)
        bgLayer1.endPoint = CGPoint(x: 0.9, y: 0.9)
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.insertSublayer(bgLayer1, at: at)
    }
    
    func replaceGradient(start_color:String,end_color : String,frame : CGRect?=nil,cornerRadius : CGFloat?=0, at: UInt32 = 0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(hex: start_color).cgColor, UIColor(hex: end_color).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0, y: 0.61)
        bgLayer1.endPoint = CGPoint(x: 0.61, y: 0.61)
        bgLayer1.cornerRadius = cornerRadius ?? 0
        guard let oldLayer = self.layer.sublayers?.first else { return }
        
        self.layer.replaceSublayer(oldLayer, with: bgLayer1)
    }
    
    func addGradient(start_color:String,
                     end_color : String,
                     frame : CGRect?=nil,
                     borader: CGFloat = 0,
                     boraderColor: UIColor = .clear,
                     at: UInt32 = 0,
                     corners: UIRectCorner?,
                     radius: CGFloat = 0) {
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(hex: start_color).cgColor, UIColor(hex: end_color).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0, y: 0.61)
        bgLayer1.endPoint = CGPoint(x: 0.61, y: 0.61)
        bgLayer1.borderColor = boraderColor.cgColor
        bgLayer1.borderWidth = borader
        if corners != nil {
            let cornerPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners!, cornerRadii: CGSize(width: radius, height: radius))
            let radiusLayer = CAShapeLayer()
            radiusLayer.frame = bounds
            radiusLayer.path = cornerPath.cgPath
            bgLayer1.mask = radiusLayer
        }
        self.layer.insertSublayer(bgLayer1, at: at)
    }
    
    func addGradient(startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
                     start_color:String,
                     endPoint: CGPoint = CGPoint(x: 1, y: 0.5),
                     end_color : String,
                     frame : CGRect? = nil,
                     cornerRadius : CGFloat?=0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.frame = bounds
        bgLayer1.startPoint = startPoint
        bgLayer1.endPoint = endPoint
        bgLayer1.colors = [UIColor(hex: start_color).cgColor, UIColor(hex: end_color).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.addSublayer(bgLayer1)
    }
    
    func addVerticalGradient(start_color:String,end_color : String,frame : CGRect?=nil,cornerRadius : CGFloat?=0){
        var bounds : CGRect = self.bounds
        if let frame = frame {
            bounds = frame
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(hex: start_color).cgColor, UIColor(hex: end_color).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = bounds
        bgLayer1.startPoint = CGPoint(x: 0, y: 0)
        bgLayer1.endPoint = CGPoint(x: 0, y: 1)
        bgLayer1.cornerRadius = cornerRadius ?? 0
        self.layer.insertSublayer(bgLayer1, at: 0)
    }
    
    //将当前视图转为UIImage
    func asImage(finished : (()-> ())? = nil) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
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


