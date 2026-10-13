//
//  LoginManager.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import Foundation

enum LoginManager {
    case guestLogin
    /// 苹果登录（app/api/third_login_new，参数对齐老项目 LoginViewController.m / FRYNetworkTask.m）
    case appleLogin(userId: String, displayName: String, givenName: String, familyName: String, email: String, userToken: String)
}

extension LoginManager: TargetType {
    var path: String {
        switch self {
        case .guestLogin:
            return "app/api/guest_login_new"
        case .appleLogin:
            return "app/api/third_login_new"
        }
    }

    var method: Moya.Method {
        return .post
    }

    var task: Moya.Task {
        switch self {
        case .guestLogin:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        case .appleLogin(let userId, let displayName, let givenName, let familyName, let email, let userToken):
            return .requestParameters(parameters: [
                // 游客 uid，服务端据此合并账号；启动链路接入静默游客登录后会自动带上（老项目行为）
                "cur_account_id": User.currentUser().id,
                // 0:默认 1:执行合并 2:取消合并
                "merge_flag": "0",
                "oauth_type": "apple",
                "phone_num": "",
                "user_id": userId,
                // 老项目拼「姓+名」
                "display_name": displayName,
                "given_name": givenName,
                "family_name": familyName,
                "email": email,
                "photo_url": "",
                // 老项目此处传空串；现升级传 identityToken 供服务端校验，联调若被拒改回 ""
                "user_token": userToken,
                "login_email": "",
                "login_code": "",
            ], encoding: URLEncoding.default)
        }
    }
}

// MARK: - 登录返回模型（信封 body 字段，对齐老项目 LoginModel/UserModel 的在用字段）
class LoginModel: Convertible {
    var token: String = ""
    var user: LoginUserInfo?
    required init() {}
}

class LoginUserInfo: Convertible {
    var uid: Int = 0
    var nickname: String = ""
    var avatar: String = ""
    required init() {}
}
