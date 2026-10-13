//
//  CatalogDecryptor.swift
//  novelplant
//
//  Created by hehe on 2026/10/12.
//

import Foundation
import zlib

/// 目录密文解码（移植老项目 FRYFileUtilities.decodeCatalogWithData + FRYNetworkManager.m:407 的第二跳）
/// dir_all / dir_page / dir_all_file 的成功响应不是 {code, message, body} 信封，
/// 而是「每字节 XOR 120(0x78) + gzip」的密文，且不带 encrypt-resp 头——
/// 只能在信封解析失败后按此格式兜底解码（调用点在 NetworkManager.performNetWorkRequest）
enum CatalogDecryptor {

    /// 密文 → 明文 JSON 字典；不是目录密文格式（XOR/gunzip/JSON 任一步失败）返回 nil
    static func decryptToDictionary(_ data: Data) -> [String: Any]? {
        guard !data.isEmpty, let plain = decrypt(data),
              let jsonDic = try? JSONSerialization.jsonObject(with: plain) as? [String: Any] else {
            return nil
        }
        // 联调验证日志：打出明文前 100 字节，确认服务端目录算法与此实现一致
        let preview = String(data: plain.prefix(100), encoding: .utf8) ?? ""
        print("目录密文解码成功（XOR+gunzip）: \(preview)...")
        return jsonDic
    }

    /// 每字节 XOR 0x78 → gunzip（对齐老项目 FRYFileUtilities.m:344 decodeCatalogWithData）
    static func decrypt(_ data: Data) -> Data? {
        guard !data.isEmpty else { return nil }
        let xored = Data(data.map { $0 ^ 0x78 })
        return gunzip(xored)
    }

    /// 系统 zlib 解 gzip，零三方依赖。
    /// windowBits = 15 + 32：自动识别 gzip/zlib 流头；version 只校验主版本，系统 zlib 为 1.2.x
    private static func gunzip(_ data: Data) -> Data? {
        var stream = z_stream()
        guard inflateInit2_(&stream, 15 + 32, "1.2.12", Int32(MemoryLayout<z_stream>.size)) == Z_OK else {
            return nil
        }
        defer { inflateEnd(&stream) }

        let chunkSize = 64 * 1024
        var buffer = [UInt8](repeating: 0, count: chunkSize)
        var output = [UInt8]()
        output.reserveCapacity(data.count * 4)
        var status: Int32 = Z_OK

        data.withUnsafeBytes { (raw: UnsafeRawBufferPointer) in
            stream.next_in = UnsafeMutablePointer(mutating: raw.bindMemory(to: UInt8.self).baseAddress)
            stream.avail_in = uInt(data.count)
            repeat {
                buffer.withUnsafeMutableBytes { (raw: UnsafeMutableRawBufferPointer) in
                    stream.next_out = raw.bindMemory(to: UInt8.self).baseAddress
                    stream.avail_out = uInt(chunkSize)
                    status = inflate(&stream, Z_NO_FLUSH)
                }
                output.append(contentsOf: buffer[0..<(chunkSize - Int(stream.avail_out))])
            } while status == Z_OK
        }

        guard status == Z_STREAM_END else { return nil }
        return Data(output)
    }
}
