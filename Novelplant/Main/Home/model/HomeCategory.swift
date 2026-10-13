//
//  Category.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

class HomeCategory: Convertible {
    required init() {
    }
    
    var is_vip: Int = 0
    var sort: Int = 0
    var id: Int = 0
    var code: String = ""
    var intro: String = ""
    var solution_id: Int = 0//方案的ID
    var description: String = ""
    var name: String = ""
    var type: Int = 0 //这一屏页的类型；0可配置(默认)，1普通界面
}
