//
//  URLConst.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
struct URLConst {
#if DEBUG
    static let baseURL = "https://nftcs.magicchair.net/nftcsjk"

//    static let baseWebUrl = "http://10.10.0.233:81"
    static let baseWebUrl = "https://nftcsh5.magicchair.net"
//    static let baseWebUrl = "http://192.168.8.47:8082"
//    static let baseWebUrl = "http://192.168.8.40:8080"
//    static let baseWebUrl = "http://192.168.8.16:8080"
    static let timeCapsuleUrl = "http://10.10.0.232:10001/timeCapsule/pages/timeCapsule/index"
    static let aliguaguaUrl = "https://nftcsh5.magicchair.net/activityAll/#/pages/guawang/index"
    static let guashenUrl = "https://nftcsh5.magicchair.net/aichat/#/pages/index/index"

    static let ruiliUrl = "https://nftcsh5.magicchair.net/ruili/#/?activityId="
#else
    static let baseURL = "https://hnft.magicchair.cn/yysjk"
    
    static let baseWebUrl = "https://mnft.magicchair.cn"
    
    static let timeCapsuleUrl = "https://mall.magicchair.cn/timeCapsule/pages/timeCapsule2/index"
    static let aliguaguaUrl = "https://mnft.magicchair.cn/activityAll/#/pages/guawang/index"
    static let guashenUrl = "https://mnft.magicchair.cn/aichat/#/pages/index/index"
    
    static let ruiliUrl = "https://mnft.magicchair.cn/ruili/#/?activityId="

#endif
    
}
