//
//  Const.swift
//  novelplant
//
//  Created by hehe on 2026/10/8.
//

import Foundation

let screenW = UIScreen.main.bounds.size.width
let screenH = UIScreen.main.bounds.size.height
let navHeight = statusBarHeight + 44
let tabbarHeight = (49 + safeAreaBottomSpace)
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let keyWindow = UIApplication.shared.connectedScenes
    .filter({$0.activationState == .foregroundActive})
    .map({$0 as? UIWindowScene})
    .compactMap({$0})
    .first?.windows
    .filter({$0.isKeyWindow}).first

struct Const {

    static let appStoreUrl = "itms-apps://itunes.apple.com/app/id6446924173" //https://apps.apple.com/app/id6446924173
    ///新版本的版本号
    static let levelupVersionCodeKey = "levelupVersionCodeKey"
    
    static let imAppID = Int32(123456)
    
#if DEBUG
    static let serviceID = "1626491127777947650"

#else
    static let serviceID = "1610170703663542273"
#endif
}
