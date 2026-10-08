//
//  Global.swift
//  novelplant
//
//  Created by hehe on 2026/10/8.
//

import Foundation
// Mark: - 全局属性
var statusBarHeight: CGFloat {
    return safeAreaTopSpace
}

var appVersion: String {
    let infoDictionary = Bundle.main.infoDictionary
    let appversion = infoDictionary!["CFBundleShortVersionString"] as! String
    return appversion
}

var appName: String {
    let infoDictionary = Bundle.main.infoDictionary
    let name = infoDictionary!["CFBundleDisplayName"] as! String
    return name
}

var currentViewController: UIViewController {
    
    var result: UIViewController?
    var window = keyWindow
    
    if window?.windowLevel != UIWindow.Level.normal  {
        let windows = UIApplication.shared.windows
        for tmpWin in windows {
            if tmpWin.windowLevel == UIWindow.Level.normal {
                window = tmpWin
                break
            }
        }
    }
    
    result = window?.rootViewController
    
    while true {
        if (result?.presentedViewController != nil) {
            result = result?.presentedViewController!
        } else if result!.isKind(of: UITabBarController.classForCoder()) {
            let tabBar: UITabBarController = result as! UITabBarController
            result = tabBar.selectedViewController!
        } else if result!.isKind(of: UINavigationController.classForCoder()) {
            let nav: UINavigationController = result as! UINavigationController
            result = nav.visibleViewController!
        } else {
            break
        }
    }
    return result!
}

var currentNavigationController: UINavigationController? {
    
   
    guard let vc = keyWindow?.rootViewController else { return nil }
    if vc.isKind(of: UINavigationController.self) {
        return vc as! BaseNavigationController
    } else if vc.isKind(of: UITabBarController.self) {
        let tabVC = vc as! UITabBarController
        guard let vc1 = tabVC.selectedViewController else { return nil }
        if vc1.isKind(of: UINavigationController.self) {
            return vc1 as! BaseNavigationController
        }
    }
    return nil
}

//获取底部安全区域的高度间隙
var safeAreaBottomSpace: CGFloat {
        
    let scene = UIApplication.shared.connectedScenes.first
    guard let windowScene = scene as? UIWindowScene else { return 0 }
    guard let window = windowScene.windows.first else { return 0 }
    
    return window.safeAreaInsets.bottom
}

//获取顶部安全区域的高度间隙
var safeAreaTopSpace: CGFloat {
    
    let scene = UIApplication.shared.connectedScenes.first
    guard let windowScene = scene as? UIWindowScene else { return 0 }
    guard let window = windowScene.windows.first else { return 0 }
    
    return window.safeAreaInsets.top
}

//var isiPhoneX: Bool {
//
//    guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
//        return false
//    }
//    
//    if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
//        return true
//    }
//    return false
//}

///监听网络
var isNetworkConnect: Bool {
    let network = NetworkReachabilityManager()
    return network?.isReachable ?? true // 无返回就默认网络已连接
}

///是否已登录
var isLogin: Bool {
    let token = User.currentUser().token
    
    if token.isEmpty {
        return false
    } else {
        return true
    }
}

var isSimulator: Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
}
// MARK: 全局方法

///json转字符串
func toJSONString(dict: NSDictionary?) -> String {

    let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.prettyPrinted)
    
    let strJson = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
    
    return strJson! as String

}

///字典转json
func dictionary(toJson dic: AnyObject?) -> String? {
    var jsonData: Data? = nil
    do {
        if let dic = dic {
            jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        }
    } catch _ {
        print("(parseError.localizedDescription)")
    }
    if let jsonData = jsonData {
        return String(data: jsonData, encoding: .utf8)
    }
    
    return nil
}



func gotoLogin() {
//    let loginVC = BaseNavigationController(rootViewController: LoginViewController())
//    currentViewController.present(loginVC, animated: true)

}

func logoutUser() {
    //清除数据
    User.deleteUser()
    
    currentNavigationController?.popToRootViewController(animated: false)
    
//    NotificationCenter.default.post(name: .loginOutSuccess, object: nil)
}

enum UploadFileType: Int {
    case image = 1
    case video
    case file
}
