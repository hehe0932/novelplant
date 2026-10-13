//
//  HomeManager.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//



enum HomeManager {
    case category
    case forYou(params: [String: Any])
}

extension HomeManager: TargetType {
    var path: String {
        switch self {
        case .category:
            return "app/api/bookstore/solution"
        case .forYou:
            return "app/api/bookstore/pages/app_partition/page_module_dynamic"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        switch self {
        case .category:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        case .forYou(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    
}
