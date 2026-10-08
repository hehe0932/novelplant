//
//  BaseNavigationViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/8.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.设置导航栏标题属性：设置标题颜色
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        // 2.设置导航栏前景色：设置item指示色
        navigationBar.tintColor = UIColor.white
        // 3.设置导航栏半透明
        navigationBar.isTranslucent = true
        // 4.设置导航栏背景图片
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        // 5.设置导航栏阴影图片
        navigationBar.shadowImage = UIImage()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBtnDidClick))
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    @objc func leftBtnDidClick() {
        popViewController(animated: true)
    }
    
    ///重写状态栏样式
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override var modalPresentationStyle: UIModalPresentationStyle {
        set {
            super.modalPresentationStyle = newValue
        }
        get {
            return .overFullScreen
        }
    }

}
