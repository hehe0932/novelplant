//
//  NetworkManager.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
import Moya
/// 超时时长
private var requestTimeOut: Double = 30
/// 成功数据的回调
typealias successCallback = ((Any?) -> Void)
/// 失败的回调
typealias failedCallback = ((String,Int) -> Void)
/// 网络错误的回调
typealias errorCallback = (() -> Void)

private let RESULT_CODE = "code"       //错误码
private let RESULT_MESSAGE = "msg"     //错误消息提示
private let RESULT_DATA = "data"           //数据
/// 网络请求的基本设置,这里可以拿到是具体的哪个网络请求，可以在这里做一些设置
private let endpointClosure = { (target: TargetType) -> Endpoint in
    // 这里把endpoint重新构造一遍主要为了解决网络请求地址里面含有? 时无法解析的bug https://github.com/Moya/Moya/issues/1198
    let url = target.baseURL.absoluteString + target.path
    var task = target.task

    /*
     如果需要在每个请求中都添加类似token参数的参数请取消注释下面代码
     👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇
     */
//    if let token = UserDefaults.standard.value(forKey: tokenKey) {
//
//        let additionalParameters = ["Token": token]
//        let defaultEncoding = URLEncoding.default
//        switch target.task {
//        ///在你需要添加的请求方式中做修改就行，不用的case 可以删掉。。
//        case .requestPlain:
//            task = .requestParameters(parameters: additionalParameters, encoding: defaultEncoding)
//        case .requestParameters(var parameters, let encoding):
//            additionalParameters.forEach { parameters[$0.key] = $0.value }
//            task = .requestParameters(parameters: parameters, encoding: encoding)
//        default:
//            break
//        }
//    }
    /*
     👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆
     如果需要在每个请求中都添加类似token参数的参数请取消注释上面代码
     */

    var endpoint = Endpoint(
        url: url,
        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
        method: target.method,
        task: task,
        httpHeaderFields: target.headers
    )
    
    requestTimeOut = target.requestTime() // 每次请求都会调用endpointClosure 到这里设置超时时长 也可单独每个接口设置
    
    return endpoint
}

/// 网络请求的设置
private let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {

        var request = try endpoint.urlRequest()
        // 设置请求时长
        request.timeoutInterval = requestTimeOut
        
//        print("请求方式: \(request.httpMethod ?? "")")
//        print("请求地址: \(request.url!)")
//        // 打印请求参数
//        if let requestData = request.httpBody {
//
//            print("请求参数: \(String(data: requestData, encoding: String.Encoding.utf8) ?? "")")
//        }
        
        
        done(.success(request))
    } catch {
        
        done(.failure(MoyaError.underlying(error, nil)))
    }
}

/**
 默认4个插件:这些插件会在请求被发送前及响应收到后被执行
 AccessTokenPlugin 管理AccessToken的插件
 CredentialsPlugin 管理认证的插件
 NetworkActivityPlugin 管理网络状态的插件
 NetworkLoggerPlugin 管理网络log的插件
 */
private let networkPlugin = NetworkActivityPlugin.init { changeType, _ in
    
//    switch changeType {
//    case .began:
//        print("开始请求网络")
//
//    case .ended:
//        print("结束请求")
//    }
}

// https://github.com/Moya/Moya/blob/master/docs/Providers.md  参数使用说明
/// 网络请求发送的核心初始化方法，创建网络请求对象
private let Provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, requestClosure: requestClosure, plugins: [networkPlugin])

// MARK: 网络请求的方法
/// 最常用的网络请求，只需知道正确的结果无需其他操作时候用这个 (可以给调用的NetWorkReques方法的写参数默认值达到一样的效果,这里为解释方便做抽出来二次封装)
///
/// - Parameters:
///   - target: 网络请求
///   - completion: 请求成功的回调
func NetWorkRequest(_ target: TargetType, completion: @escaping successCallback) {
    
    NetWorkRequest(target, completion: completion, failed: nil, errorResult: nil)
}

///   网络请求, 成功和失败的回调
///
/// - Parameters:
///   - target: 网络请求
///   - completion: 成功的回调
///   - failed: 请求失败的回调
func NetWorkRequest(_ target: TargetType, completion: @escaping successCallback, failed: failedCallback?) {
    
    NetWorkRequest(target, completion: completion, failed: failed, errorResult: nil)
}

///  需要知道成功、失败、错误情况回调的网络请求   像结束下拉刷新各种情况都要判断
///
/// - Parameters:
///   - target: 网络请求
///   - completion: 成功
///   - failed: 失败
///   - error: 错误
@discardableResult // 当我们需要主动取消网络请求的时候可以用返回值Cancellable, 一般不用的话做忽略处理
func NetWorkRequest(_ target: TargetType, completion: @escaping successCallback, failed: failedCallback?, errorResult: errorCallback?) -> Cancellable? {
    // 先判断网络是否有链接 没有的话直接返回
    if !isNetworkConnect {
        
        //提示用户网络似乎出现了问题
//        MCToastManager.makeToast("网络错误")
        errorResult?()
        failed?(NSLocalizedString("network_error", comment: ""), 88888)
        return nil
    }

    return Provider.request(MultiTarget(target)) { result in
        switch result {
        case let .success(response):
            do {

                if let jsonDic = try response.mapJSON() as? [String: Any] {
                    
                    let jsonStr = toJSONString(dict: jsonDic as NSDictionary)

                    print("请求header: \(response.request?.headers ?? [:])")
                    print("请求方式: \(response.request?.httpMethod ?? "")")
                    print("请求地址: \(response.request!.url!)")
                    // 打印请求参数
                    if let requestData = response.request?.httpBody {

                        print("请求参数: \(String(data: requestData, encoding: String.Encoding.utf8) ?? "")")
                    }
  
                    print("请求结果:\n\(jsonStr)")
                    
                    if let code = jsonDic[RESULT_CODE] as? Int, code == 200 {
                        
                        if let data = jsonDic[RESULT_DATA] {
                            completion(data)
                        } else {
                        
                            let data = ["total": jsonDic["total"] ?? "", "rows": jsonDic["rows"] ?? "", "statistical": jsonDic["statistical"] ?? "", "msg": jsonDic["msg"] ?? ""]
                            completion(data)
                        }
                        
                    } else if let code = jsonDic[RESULT_CODE] as? Int, code == 401 {
                        //登录过期
                        XHToastManager.makeToast(NSLocalizedString("login_failed_retry", comment: ""))
                        User.deleteUser()
                        
                        if !isLogin {
                            gotoLogin()
                        }
                    }
                    else {
                        XHToastManager.makeToast((jsonDic[RESULT_MESSAGE] as? String) ?? NSLocalizedString("network_error", comment: ""))
                        if let failed = failed {
                            failed((jsonDic[RESULT_MESSAGE] as? String) ?? NSLocalizedString("network_error", comment: ""), jsonDic[RESULT_CODE] as? Int ?? 0)
                        }
                    }
                }
            } catch {
                
            }
            
        case let .failure(error):

            if let afError = error.errorUserInfo[NSUnderlyingErrorKey] as? Error {
                if let cancel = afError.asAFError?.isExplicitlyCancelledError, cancel == true {
                    print("主动取消")
                    errorResult?()
                    failed?(NSLocalizedString("network_error", comment: ""), 88888)
                    
                    return
                }
            }
            
            //提示用户网络似乎出现了问题
            XHToastManager.makeToast(NSLocalizedString("network_error", comment: ""))
            errorResult?()
            failed?(NSLocalizedString("network_error", comment: ""), 88888)
            print(error)
        }
    }
}


///  需要知道成功回调的网络请求   只要接口调用成功就返回信息，不再校验接口返回code是否为成功值才返回，用于当code为50000时依然需要在模块内做单独处理的情况
///
/// - Parameters:
///   - target: 网络请求
///   - completion: 成功
@discardableResult // 当我们需要主动取消网络请求的时候可以用返回值Cancellable, 一般不用的话做忽略处理
func NetWorkRequestWithAnyCode(_ target: TargetType, completion: @escaping successCallback, failed: failedCallback?) -> Cancellable? {
    // 先判断网络是否有链接 没有的话直接返回
    if !isNetworkConnect {
        //提示用户网络似乎出现了问题
//        MCToastManager.makeToast("网络错误")
        failed?(NSLocalizedString("network_error", comment: ""), 88888)
        return nil
    }
    return Provider.request(MultiTarget(target)) { result in
        switch result {
        case let .success(response):
            
            do {
                if let jsonDic = try response.mapJSON() as? [String: Any] {
                    
                    let jsonStr = toJSONString(dict: jsonDic as NSDictionary)
                    
                    print("请求方式: \(response.request?.httpMethod ?? "")")
                    print("请求地址: \(response.request!.url!)")
                    // 打印请求参数
                    if let requestData = response.request?.httpBody {

                        print("请求参数: \(String(data: requestData, encoding: String.Encoding.utf8) ?? "")")
                    }
  
                    print("请求结果:\n\(jsonStr)")
                    
                    
                    if let code = jsonDic[RESULT_CODE] as? Int, code == 200 {
                        
                        if let data = jsonDic[RESULT_DATA] {
                            completion(data)
                        } else {
                        
                            let data = ["total": jsonDic["total"], "rows": jsonDic["rows"], "statistical": jsonDic["statistical"]]
                            completion(data)
                        }
                        
                    } else if let code = jsonDic[RESULT_CODE] as? Int, code == 401 {
                        //登录过期
                        XHToastManager.makeToast("登录失效，请重新登录")
                        User.deleteUser()
                        
                        if !isLogin {
                            gotoLogin()
                        }
                    }  else {
                        XHToastManager.makeToast((jsonDic[RESULT_MESSAGE] as? String) ?? NSLocalizedString("network_error", comment: ""))
                        if let failed = failed {
                            failed((jsonDic[RESULT_MESSAGE] as? String) ?? NSLocalizedString("network_error", comment: ""), jsonDic[RESULT_CODE] as? Int ?? 0)
                        }
                    }

                }
            } catch {
                
            }

        case let .failure(error):
            print(error)
            //提示用户网络似乎出现了问题
            XHToastManager.makeToast(NSLocalizedString("network_error", comment: ""))
            failed?(NSLocalizedString("network_error", comment: ""), 88888)
        }
    }
}

///  只要请求成功就返回数据
///
/// - Parameters:
///   - target: 网络请求
///   - completion: 成功
@discardableResult // 当我们需要主动取消网络请求的时候可以用返回值Cancellable, 一般不用的话做忽略处理
func NetWorkRequestWithAllData(_ target: TargetType, completion: @escaping successCallback) -> Cancellable? {
    
    if !isNetworkConnect {
        //提示用户网络似乎出现了问题
        XHToastManager.makeToast("网络似乎出现了问题")
        return nil
    }
        
    return Provider.request(MultiTarget(target)) { result in
        switch result {
        case let .success(response):
            do {
                if let jsonDic = try response.mapJSON() as? [String: Any] {
                    
                    let jsonStr = toJSONString(dict: jsonDic as NSDictionary)
                    
                    print("请求方式: \(response.request?.httpMethod ?? "")")
                    print("请求地址: \(response.request!.url!)")
                    // 打印请求参数
                    if let requestData = response.request?.httpBody {

                        print("请求参数: \(String(data: requestData, encoding: String.Encoding.utf8) ?? "")")
                    }
  
                    print("请求结果:\n\(jsonStr)")

                    if let code = jsonDic[RESULT_CODE] as? Int, code == 200 {
                        
                        if let data = jsonDic[RESULT_DATA] {
                            completion(data)
                        } else {
                        
                            let data = ["total": jsonDic["total"], "rows": jsonDic["rows"], "statistical": jsonDic["statistical"]]
                            completion(data)
                        }
                        
                    } else if let code = jsonDic[RESULT_CODE] as? Int, code == 401 {
                        //登录过期
                        XHToastManager.makeToast("登录失效，请重新登录")
                        User.deleteUser()
                        
                        if !isLogin {
                            gotoLogin()
                        }
                    }  else {
                        XHToastManager.makeToast((jsonDic[RESULT_MESSAGE] as? String) ?? NSLocalizedString("network_error", comment: ""))
                        print("网络请求失败\(response.request!.url!)")
                    }

                }
            } catch {
                
            }
        case let .failure(error):
            print(error)
            //提示用户网络似乎出现了问题
            XHToastManager.makeToast(NSLocalizedString("network_error", comment: ""))
            print("网络请求失败\(target.path)")
        }
    }
}



