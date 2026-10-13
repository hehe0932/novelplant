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

private let RESULT_CODE = "code"       //错误码（0 成功，10003 token 过期，见接口文档 3.4）
private let RESULT_MESSAGE = "message"     //错误消息提示
private let RESULT_DATA = "body"           //数据（success 回调收到的是 body 字段内容）

/// 网络请求的基本设置,这里可以拿到是具体的哪个网络请求，可以在这里做一些设置
private let endpointClosure = { (target: TargetType) -> Endpoint in
    // 这里把endpoint重新构造一遍主要为了解决网络请求地址里面含有? 时无法解析的bug https://github.com/Moya/Moya/issues/1198
    let url = target.baseURL.absoluteString + target.path
    var task = target.task

    // 公共参数自动合并进每个请求，同名字段以业务参数优先（接口文档 3.3）
    let commonParams = HttpCommonParam.commonParameters()
    switch task {
    case .requestPlain:
        task = .requestParameters(parameters: commonParams, encoding: URLEncoding.default)
    case .requestParameters(var parameters, let encoding):
        parameters.merge(commonParams) { current, _ in current }
        task = .requestParameters(parameters: parameters, encoding: encoding)
    default:
        break
    }

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

}

// https://github.com/Moya/Moya/blob/master/docs/Providers.md  参数使用说明
/// 网络请求发送的核心初始化方法，创建网络请求对象
private let Provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, requestClosure: requestClosure, plugins: [networkPlugin])

// MARK: - 响应解密（对接文档 8.2）
/// 加密暂不启用：encrypt-resp: 1 的接口（For You/详情/购买等 9 个 🔒 接口）不接解密库，检测到就打日志放行原文（会解析失败并打印）。
/// TODO 恢复时：拷回 ThirdParty/libencrypt（老项目 CommonKit/libencrypt）+ pbxproj 配 Bridging Header/搜索路径，本方法改回调 ios_decrypt_bytes
enum ResponseDecryptor {
    static func decryptIfNeeded(_ response: Response) -> Data {
        guard response.response?.value(forHTTPHeaderField: "encrypt-resp") == "1",
              !response.data.isEmpty else {
            return response.data
        }
        print("响应已加密但暂未接解密（🔒接口才会触发）：\(response.request?.url?.absoluteString ?? "")")
        return response.data
    }
}

// MARK: - token 过期自愈（对接文档 8.3）
/// 刷新 token 接口。URL 双 app/api 前缀是老项目宏定义的历史问题，服务端已兼容此路径，照抄
private struct RefreshTokenAPI: TargetType {
    let oldToken: String

    var path: String { "app/api/app/api/refresh_token" }
    var method: Moya.Method { .post }
    var task: Moya.Task { .requestParameters(parameters: ["old_token": oldToken], encoding: URLEncoding.default) }
}

/// 单飞刷新：并发多个 10003 只发一次 refresh_token，完成后统一回调
private final class TokenRefresher {
    static let shared = TokenRefresher()
    private var isRefreshing = false
    private var pending: [(Bool) -> Void] = []
    private let lock = NSLock()

    func refresh(completion: @escaping (Bool) -> Void) {
        lock.lock()
        if isRefreshing {
            pending.append(completion)
            lock.unlock()
            return
        }
        isRefreshing = true
        lock.unlock()

        Provider.request(MultiTarget(RefreshTokenAPI(oldToken: User.currentUser().token))) { result in
            var newToken: String?
            if case let .success(response) = result {
                let data = ResponseDecryptor.decryptIfNeeded(response)
                // token 字段名按 LoginModel.token 推断，联调若对不上以此处为调整点
                if let jsonDic = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   (jsonDic[RESULT_CODE] as? Int) == 0,
                   let body = jsonDic[RESULT_DATA] as? [String: Any],
                   let token = body["token"] as? String, !token.isEmpty {
                    newToken = token
                }
            }
            if let newToken {
                User.updateUser(value: newToken, key: User.Keys.token)
            }

            self.lock.lock()
            self.isRefreshing = false
            let waiters = self.pending
            self.pending = []
            self.lock.unlock()

            completion(newToken != nil)
            waiters.forEach { $0(newToken != nil) }
        }
    }
}

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
///   - completion: 成功（回调收到的是信封 body 内容）
///   - failed: 失败
///   - error: 错误
@discardableResult // 当我们需要主动取消网络请求的时候可以用返回值Cancellable, 一般不用的话做忽略处理
func NetWorkRequest(_ target: TargetType, completion: @escaping successCallback, failed: failedCallback?, errorResult: errorCallback?) -> Cancellable? {
    performNetWorkRequest(target, allowTokenRetry: true, completion: completion, failed: failed, errorResult: errorResult)
}

///  需要知道成功回调的网络请求   只要接口调用成功就返回信息，不再校验接口返回code是否为成功值才返回，用于当code为50000时依然需要在模块内做单独处理的情况
///
/// - Parameters:
///   - target: 网络请求
///   - completion: 成功
@discardableResult // 当我们需要主动取消网络请求的时候可以用返回值Cancellable, 一般不用的话做忽略处理
func NetWorkRequestWithAnyCode(_ target: TargetType, completion: @escaping successCallback, failed: failedCallback?) -> Cancellable? {
    performNetWorkRequest(target, allowTokenRetry: true, completion: completion, failed: failed, errorResult: nil)
}

///  只要请求成功就返回数据
///
/// - Parameters:
///   - target: 网络请求
///   - completion: 成功
@discardableResult // 当我们需要主动取消网络请求的时候可以用返回值Cancellable, 一般不用的话做忽略处理
func NetWorkRequestWithAllData(_ target: TargetType, completion: @escaping successCallback) -> Cancellable? {
    performNetWorkRequest(target, allowTokenRetry: true, completion: completion, failed: nil, errorResult: nil)
}

// MARK: - 请求核心（信封分发 + token 自愈重放 + 响应解密，对接文档 8）
@discardableResult
private func performNetWorkRequest(_ target: TargetType,
                                   allowTokenRetry: Bool,
                                   completion: @escaping successCallback,
                                   failed: failedCallback?,
                                   errorResult: errorCallback?) -> Cancellable? {
    // 先判断网络是否有链接 没有的话直接返回
    if !isNetworkConnect {

        errorResult?()
        failed?(NSLocalizedString("Network error", comment: ""), 88888)
        return nil
    }

    return Provider.request(MultiTarget(target)) { result in
        switch result {
        case let .success(response):
            // 响应体可能加密：encrypt-resp: 1 时先解密再解析（对接文档 8.2）
            let data = ResponseDecryptor.decryptIfNeeded(response)

            // 信封分发（请求日志 + 成功 / 10003 自愈 / 业务失败）——信封直解与目录密文兜底两条路共用
            func dispatchEnvelope(_ jsonDic: [String: Any]) {
                let jsonStr = toJSONString(dict: jsonDic as NSDictionary)

                print("请求header: \(response.request?.headers ?? [:])")
                print("请求方式: \(response.request?.httpMethod ?? "")")
                print("请求地址: \(response.request!.url!)")
                // 打印请求参数
                if let requestData = response.request?.httpBody {

                    print("请求参数: \(String(data: requestData, encoding: String.Encoding.utf8) ?? "")")
                }

                print("请求结果:\n\(jsonStr)")

                if let code = jsonDic[RESULT_CODE] as? Int, code == 0 {
                    //成功回调收到的是 body 字段内容（对接文档 8.1）
                    completion(jsonDic[RESULT_DATA])
                } else if let code = jsonDic[RESULT_CODE] as? Int, code == 10003 {
                    // token 过期：刷新成功后原参重放，最多自愈 1 次，防循环（对接文档 8.3）
                    guard allowTokenRetry else {
                        let message = (jsonDic[RESULT_MESSAGE] as? String) ?? NSLocalizedString("Network error", comment: "")
                        XHToastManager.makeToast(message)
                        failed?(message, 10003)
                        return
                    }
                    TokenRefresher.shared.refresh { tokenRefreshed in
                        if tokenRefreshed {
                            _ = performNetWorkRequest(target, allowTokenRetry: false, completion: completion, failed: failed, errorResult: errorResult)
                        } else {
                            let message = (jsonDic[RESULT_MESSAGE] as? String) ?? NSLocalizedString("Network error", comment: "")
                            XHToastManager.makeToast(message)
                            failed?(message, 10003)
                        }
                    }
                } else {
                    let message = (jsonDic[RESULT_MESSAGE] as? String) ?? NSLocalizedString("Network error", comment: "")
                    XHToastManager.makeToast(message)
                    failed?(message, jsonDic[RESULT_CODE] as? Int ?? 0)
                }
            }

            do {
                guard let jsonDic = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("响应非字典结构，无法解析")
                    return
                }
                dispatchEnvelope(jsonDic)
            } catch {
                // 目录密文兜底（老项目 FRYNetworkManager.m:395-435 第二跳）：
                // dir_all / dir_page / dir_all_file 的成功响应是 XOR 0x78 + gzip 密文且不带 encrypt-resp 头
                if let jsonDic = CatalogDecryptor.decryptToDictionary(data) {
                    // 目录明文无信封（顶层即 chapters/dir_ver，对齐老项目解密后直接回调业务层），
                    // 不走 dispatchEnvelope，整个字典回调给调用方
                    completion(jsonDic)
                } else {
                    print("响应解析失败: \(error)")
                }
            }

        case let .failure(error):

            if let afError = error.errorUserInfo[NSUnderlyingErrorKey] as? Error {
                if let cancel = afError.asAFError?.isExplicitlyCancelledError, cancel == true {
                    print("主动取消")
                    errorResult?()
                    failed?(NSLocalizedString("Network error", comment: ""), 88888)

                    return
                }
            }

            //提示用户网络似乎出现了问题
            XHToastManager.makeToast(NSLocalizedString("Network error", comment: ""))
            errorResult?()
            failed?(NSLocalizedString("Network error", comment: ""), 88888)
            print(error)
        }
    }
}
