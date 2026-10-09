//
//  User.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import Foundation

class User: Convertible {
    var id: String = ""
    var token: String = ""
    
    required init() {}
    func kj_didConvertToModel(from json: [String : Any]) {
//        id = memberInfoVo?.id ?? ""
//        avatar = memberInfoVo?.avatar ?? ""
//        beforeGrowth = memberInfoVo?.beforeGrowth ?? 0
    }
    

    struct Keys {
        static let id = "id"
        static let token = "token"
    }
    
    
    static func saveUserInfo(model: User) {
        UserDefaults.standard.set(model.id, forKey: User.Keys.id)
        UserDefaults.standard.set(model.token, forKey: User.Keys.token)
    }
    
    static func updateUser(value: Any, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func deleteUser() {
        UserDefaults.standard.set("", forKey: User.Keys.id)
        UserDefaults.standard.set("", forKey: User.Keys.token)
        
    }
    
    static func currentUser() -> User {
        let user = User()
        if let id = UserDefaults.standard.value(forKey: User.Keys.id) {
            user.id = id as! String
        }
        if let token = UserDefaults.standard.value(forKey: User.Keys.token) {
            user.token = token as! String
        }
        
        return user
    }
}
