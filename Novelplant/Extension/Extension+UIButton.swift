//
//  Extension+UIButton.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
import UIKit
enum ImageTitleAlignment {
  case top, left, bottom, right
}

extension UIButton {
    convenience init(title: String, titleColor: UIColor, titleFont: CGFloat) {
        self.init()
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = .systemFont(ofSize: titleFont)
    }
    
    convenience init(title: String, titleColor: UIColor, font: UIFont) {
        self.init()
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = font
    }
    
    // 自动调整按钮中的图文位置
    func adjustImageTitlePosition(_ alignment: ImageTitleAlignment, spacing: CGFloat) {
        
        let imageWidth = self.imageView?.image?.size.width
        let imageHeight = self.imageView?.image?.size.height
        
        let labelWidth = self.titleLabel?.intrinsicContentSize.width
        let labelHeight = self.titleLabel?.intrinsicContentSize.height
        
        switch alignment {
        case .top:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight!-spacing/2, left: 0, bottom: 0, right: -labelWidth!)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!, bottom: -imageHeight!-spacing/2, right: 0)
            
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
            
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight!-spacing/2, right: -labelWidth!)
            titleEdgeInsets = UIEdgeInsets(top: -imageHeight!-spacing/2, left: -imageWidth!, bottom: 0, right: 0)
            
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth!+spacing/2, bottom: 0, right: -labelWidth!-spacing/2)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!-spacing/2, bottom: 0, right: imageWidth!+spacing/2)
            
        }
    }
}

//button角标
extension UIButton {
    
    private struct ButtonBadgeKey {
        static var badgeKey = "badgeKey"
        static var badgeBGColorKey = "badgeBGColorKey"
        static var badgeTextColorKey = "badgeTextColorKey"
        static var badgeFontKey = "badgeFontKey"
        static var badgePaddingKey = "badgePaddingKey"
        static var badgeMinHeightKey = "badgeMinHeightKey"
        static var badgeMaxWidthKey = "badgeMaxWidthKey"
        static var badgeCenterXKey = "badgeCenterXKey"
        static var badgeCenterYKey = "badgeCenterYKey"
        static var shouldAnimateBadgeKey = "shouldAnimateBadgeKey"
        static var shouldHideBadgeKey = "shouldHideBadgeKey"
        static var badgeValueKey = "badgeValueKey"
    }
    
    ///角标label
    var badge: UILabel? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeKey) as? UILabel
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    ///角标显示的信息,可以为数字或文字
    var badgeValue: String {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeValueKey) as! String
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeValueKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
            
            if let _ = badge {
                if newValue.isEmpty || (badgeValue == "0" && shouldHideBadge == true){
                    removeBadge()
                } else {
                    updateBadgeValue(animated: true)
                }
            } else {
                badge = UILabel(frame: CGRect(x: badgeCenterX ?? 0, y: badgeCenterY ?? 0, width: 20, height: 20))
                badge?.center = CGPoint(x: badgeCenterX ?? 0, y: badgeCenterY ?? 0)
                badge?.textColor = badgeTextColor
                badge?.backgroundColor = badgeBGColor
                badge?.font = badgeFont
                badge?.textAlignment = .center
                badgeInit()
                addSubview(badge!)
                updateBadgeValue(animated: false)
            }
        }
    }
    ///角标背景颜色,默认红色
    var badgeBGColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeBGColorKey) as? UIColor
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeBGColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badge {
                refreshBadge()
            }
        }
    }
    ///角标文字颜色
    var badgeTextColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeTextColorKey) as? UIColor
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeTextColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badge {
                refreshBadge()
            }
        }
    }
    ///角标字号
    var badgeFont: UIFont? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeFontKey) as? UIFont
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeFontKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badge {
                refreshBadge()
            }
        }
    }
    ///角标边界
    var badgePadding: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgePaddingKey) as? CGFloat
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgePaddingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badge {
                updateBadgeFrame()
            }
        }
    }
    ///角标最小高度
    var badgeMinHeight: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeMinHeightKey) as? CGFloat
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeMinHeightKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badge {
                updateBadgeFrame()
            }
        }
    }
    ///角标最大宽度
    var badgeMaxWidth: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeMaxWidthKey) as? CGFloat
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeMaxWidthKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badge {
                updateBadgeFrame()
            }
        }
    }
    ///角标的中心x
    var badgeCenterX: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeCenterXKey) as? CGFloat
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeCenterXKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badge {
                updateBadgeFrame()
            }
        }
    }
    ///角标的中心y
    var badgeCenterY: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.badgeCenterYKey) as? CGFloat
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.badgeCenterYKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badge {
                updateBadgeFrame()
            }
        }
    }
    ///当角标为0时,自动去除
    var shouldHideBadge: Bool? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.shouldHideBadgeKey) as? Bool
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.shouldHideBadgeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    ///当角标的值发生变化,角标的动画是否显示
    var shouldAnimateBadge: Bool? {
        get {
            return objc_getAssociatedObject(self, &ButtonBadgeKey.shouldAnimateBadgeKey) as? Bool
        }
        
        set {
            objc_setAssociatedObject(self, &ButtonBadgeKey.shouldAnimateBadgeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
 
    private func badgeInit() {
        badgeBGColor = .red
        badgeTextColor = .white
        badgeFont = .systemFont(ofSize: 10)
        badgePadding = 2
        badgeMinHeight = 8
        badgeMaxWidth = 100
        badgeCenterX = frame.size.width
        badgeCenterY = 0
        shouldHideBadge = false
        shouldAnimateBadge = true
        
        clipsToBounds = false
        
    }
    
    private func refreshBadge() {
        badge?.textColor = badgeTextColor
        badge?.backgroundColor = badgeBGColor
        badge?.font = badgeFont
    }
    
    ///更新frame
    private func updateBadgeFrame() {
        badge?.sizeToFit()
        let expextedLabelSize = badge?.size ?? .zero
        var minHeight = expextedLabelSize.height
        //判断如果小于最小size,则为最小size
        minHeight = (minHeight < badgeMinHeight ?? 0) ? badgeMinHeight ?? 0 : expextedLabelSize.height
        
        var maxWidth = expextedLabelSize.width
        //判断如果大于最大width,则为最大width
        maxWidth = (maxWidth > badgeMaxWidth ?? 0) ? badgeMaxWidth ?? 0 : expextedLabelSize.width
        
        let padding: CGFloat = badgePadding ?? 0
        //填充边界
        maxWidth = (maxWidth < minHeight) ? minHeight : maxWidth
        badge?.frame = CGRect(x: badgeCenterX ?? 0, y: badgeCenterY ?? 0, width: maxWidth + padding, height: minHeight + padding)
        badge?.center = CGPoint(x: badgeCenterX ?? 0, y: badgeCenterY ?? 0)
        badge?.layer.cornerRadius = (minHeight + padding) * 0.5
        badge?.layer.masksToBounds = true
    }
    
    ///角标值变化
    private func updateBadgeValue(animated: Bool) {
        if animated && shouldAnimateBadge == true && badge?.text != badgeValue {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.5
            animation.toValue = 1
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1, 1)
            badge?.layer.add(animation, forKey: "addLayerAnimationBounds")
        }
        badge?.text = badgeValue
        
        let duration = animated ? 0.2 : 0
        UIView.animate(withDuration: duration) {
            self.updateBadgeFrame()
        }
    }
    
    private func removeBadge() {
        
        UIView.animate(withDuration: 0.25) {

            self.badge?.transform = CGAffineTransform(scaleX: 0, y: 0)
        } completion: { _ in
            self.badge?.removeFromSuperview()
        }

    }
}
