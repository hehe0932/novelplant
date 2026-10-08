//
//  BaseTargetType.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
import Moya

extension TargetType {
    //请求header
    var headers: [String: String]? {

        let token = User.currentUser().token
        if !token.isEmpty {
            print(token)
            return ["Authorization": "Bearer \(token)", "appId": "123456", "appVersion": appVersion, "os": "ios"]
        }
        
        return ["appId": "123456", "appVersion": appVersion, "os": "ios"]
    }
    
    //base请求路径
    var baseURL: URL {
        return URL(string: URLConst.baseURL)!
    }
    
    //这个就是做单元测试模拟的数据，只会在单元测试文件中有作用
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    //获取请求时间
    func requestTime() -> Double {
        return 30
    }

}

//参数为数组的处理
struct JSONArrayEncoding: ParameterEncoding {
    static let `default` = JSONArrayEncoding()

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()

        guard let json = parameters?["jsonArray"] else {
            return request
        }

        let data = try JSONSerialization.data(withJSONObject: json, options: [])

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
 
        request.httpBody = data

        return request
    }
}
