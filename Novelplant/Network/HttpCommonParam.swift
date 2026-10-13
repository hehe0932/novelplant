//
//  HttpCommonParam.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import Foundation
import UIKit
import CryptoKit
import CoreTelephony
import AdSupport
import Security

/// 公共请求参数与 sign 签名（对齐老项目 FRYHttpCommonParam.m）
enum HttpCommonParam {

    /// 签名密钥
    static let SIGN_KEY = "iboKwvO#xSCaev9G"

    /// 固定业务标识
    private static let channelID = 10102
    private static let productID = 2
    private static let groupID = 10001
    private static let platform = 0
    private static let appType = 0

    /// 每个请求自动合并的公共 body 参数；同名字段业务参数优先覆盖
    static func commonParameters() -> [String: Any] {
        [
//            "version": appVersion,
//            "package": Bundle.main.bundleIdentifier ?? "",
//            "group_id": groupID,
//            "product_id": productID,
//            "channel_id": channelID,
//            "platform": platform,
//            "device_id": deviceID,
//            "new_device_id": deviceID,
//            "serial_no": 0,
//            "phone_type": "apple",
//            "sys_model": sysModel,
//            "sys_version": UIDevice.current.systemVersion,
//            "language": Bundle.main.preferredLocalizations.first ?? "",
//            "device_language": deviceLanguage,
//            "country": Locale.current.regionCode ?? "",
//            "currency": Locale.current.currencyCode ?? "",
//            "simOperator": carrier?.carrierName ?? "",
//            "netCountry": UserDefaults.standard.string(forKey: "netCountry") ?? "China",
//            "dns": UserDefaults.standard.string(forKey: "dns") ?? "",
//            "local_timezone": TimeZone.current.identifier,
//            "app_type": appType,
//            "sign": sign(),

            "version": "1.2.0",
            "package": "com.xcyh.novelclub",
            "group_id": groupID,
            "product_id": productID,
            "channel_id": channelID,
            "platform": platform,
            "device_id": "2A52759C-8842-48CC-B230-54082178D576",
            "new_device_id": "2A52759C-8842-48CC-B230-54082178D576",
            "serial_no": 0,
            "phone_type": "apple",
            "sys_model": "iPhone 12 Pro Max",
            "sys_version": "26.7",
            "language": "en",
            "device_language": "en",
            "country": "US",
            "currency": "USD",
            "simOperator": "6553565535",
            "netCountry": "China",
            "dns": "219.141.136.10,219.141.140.10",
            "local_timezone": "Asia/Shanghai",
            "app_type": 0,
            "sign": sign(),
        ]
    }

    /// sign = upper(HMAC-SHA256(SIGN_KEY, "channel_id=..&device_id=..&package=..&platform=..&product_id=..&version=.." + SIGN_KEY))
    /// 五键固定顺序、末尾拼 key、hex 小写再整体大写（对接文档 §5）
    static func sign() -> String {
        // 原始动态计算逻辑（已注释）
//        let message = "channel_id=\(channelID)"
//            + "&device_id=\(deviceID)"
//            + "&package=\(Bundle.main.bundleIdentifier ?? "")"
//            + "&platform=\(platform)"
//            + "&product_id=\(productID)"
//            + "&version=\(appVersion)"
//            + SIGN_KEY

        // 当前使用固定值（对齐模拟器参数）
        let message = "channel_id=\(channelID)"
            + "&device_id=2A52759C-8842-48CC-B230-54082178D576"
            + "&package=com.xcyh.novelclub"
            + "&platform=\(platform)"
            + "&product_id=\(productID)"
            + "&version=1.2.0"
            + SIGN_KEY

        let key = SymmetricKey(data: Data(SIGN_KEY.utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)
        return mac.map { String(format: "%02x", $0) }.joined().uppercased()
    }

    /// User-Agent：api-client/1 <bundleId>/<version>(<build>) <系统名>/<系统版本> apple/<机型> network/<网络类型>
    static func userAgent() -> String {
        "api-client/1 \(Bundle.main.bundleIdentifier ?? "")/\(appVersion)(\(buildVersion))"
            + " \(UIDevice.current.systemName)/\(UIDevice.current.systemVersion)"
            + " apple/\(sysModel)"
            + " network/\(networkType)"
    }
}

// MARK: - 取值
extension HttpCommonParam {

    /// device_id：Keychain 持久化（service=bundleId, account=com.Novelclub.uuid），
    /// 卸载重装身份不变——后端设备指纹/游客账号体系依赖此语义（对接文档 §6，老项目 FRYNetworkConfig.m:48）；首值取 IDFV
    static var deviceID: String {
        struct Cache { static var cached: String? }
        if let cached = Cache.cached { return cached }

        let service = Bundle.main.bundleIdentifier ?? ""
        let account = "com.Novelclub.uuid"
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
        ]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
           let data = item as? Data,
           let saved = String(data: data, encoding: .utf8), !saved.isEmpty {
            Cache.cached = saved
            return saved
        }

        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        query.removeValue(forKey: kSecReturnData as String)
        query[kSecValueData as String] = Data(uuid.utf8)
        SecItemAdd(query as CFDictionary, nil)
        Cache.cached = uuid
        return uuid
    }

    /// new_device_id（对接文档 §7）：ATT 未请求过传空串；请求过则 IDFA（授权时）否则 IDFV。
    /// TODO：ATT 弹窗时序（requestTrackingAuthorization + requested_advertiser_tracking 落位 + iOS 17.4.1 Denied 误报兼容）
    /// 属启动链路，接登录流程时在 AppDelegate 里做，此处只按状态取值
    private static var newDeviceID: String {
        guard UserDefaults.standard.bool(forKey: "requested_advertiser_tracking") else { return "" }
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    /// device_language：DEBUG 固定 "en"；RELEASE 取系统语言，兜底 "en"（对接文档 §4）
    private static var deviceLanguage: String {
        #if DEBUG
        return "en"
        #else
        return Locale.preferredLanguages.first ?? "en"
        #endif
    }

    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    private static var buildVersion: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    /// 设备机型，如 iPhone14,2
    private static var sysModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return Mirror(reflecting: systemInfo.machine).children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(String(UnicodeScalar(UInt8(value))))
        }
    }

    private static var carrier: CTCarrier? {
        CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.values.first
    }

    /// 网络类型：wifi / cellular / none
    private static var networkType: String {
        let manager = NetworkReachabilityManager()
        switch manager?.status {
        case .reachable(.ethernetOrWiFi): return "wifi"
        case .reachable(.cellular): return "cellular"
        default: return "none"
        }
    }
}
