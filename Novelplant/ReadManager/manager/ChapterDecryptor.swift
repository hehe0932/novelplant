//
//  ChapterDecryptor.swift
//  novelplant
//
//  Created by hehe on 2026/10/13.
//

import Foundation
import zlib

/// 章节内容解密器（对齐老项目 FRYFileUtilities.m 的 getChapterContentWithchapterModel）
enum ChapterDecryptor {

    /// 解密章节内容
    /// - Parameter encryptedData: 加密的章节数据
    /// - Returns: 解密后的文本内容，失败返回 nil
    static func decrypt(_ encryptedData: Data) -> String? {
        // 1. 检查数据有效性（至少16字节）
        guard encryptedData.count > 16 else {
            print("章节数据无效：长度不足")
            return nil
        }

        // 2. 模拟器检测：如果在模拟器上运行，使用降级方案
        #if targetEnvironment(simulator)
        print("⚠️ 模拟器环境：解密库不可用，返回模拟数据")
        return """
        【模拟器模式 - 解密库不可用】

          这是模拟的章节内容。真机运行时会显示真实解密后的内容。

          在模拟器上，静态库 libencrypt_for_ios_debug.a 不支持 arm64 架构，因此无法调用解密函数。

          请在真机上测试完整的下载+解密流程。
        """
        #else
        // 3. 调用 C 解密函数（仅真机）
        var outputLen: Int32 = 0
        guard let output = encryptedData.withUnsafeBytes({ (rawBuffer: UnsafeRawBufferPointer) -> UnsafeMutablePointer<UInt8>? in
            guard let baseAddress = rawBuffer.baseAddress else { return nil }
            return ios_decrypt_buffer(baseAddress.assumingMemoryBound(to: UInt8.self), Int32(encryptedData.count), &outputLen)
        }), outputLen > 0 else {
            print("章节解密失败：ios_decrypt_buffer 返回 nil")
            return nil
        }

        // 4. 构建解密后的数据
        let decryptedData = Data(bytes: output, count: Int(outputLen))

        // 5. gunzip 解压
        guard let decompressedData = gunzip(decryptedData) else {
            print("章节解压失败：gunzip 返回 nil")
            return nil
        }

        // 6. 转换为 UTF-8 字符串
        guard let content = String(data: decompressedData, encoding: .utf8) else {
            print("章节转码失败：无法转换为 UTF-8")
            return nil
        }

        // 7. 格式化内容：分段、去空行、添加段落首缩进
        return formatContent(content)
        #endif
    }

    /// 格式化章节内容（对齐老项目）
    private static func formatContent(_ rawContent: String) -> String {
        let paragraphs = rawContent.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // 添加段落首缩进（两个全角空格）
        let formatted = paragraphs.map { "  \($0)" }.joined(separator: "\n")
        return "  " + formatted  // 开头也加缩进
    }

    /// gunzip 解压（复用 CatalogDecryptor 的实现）
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
