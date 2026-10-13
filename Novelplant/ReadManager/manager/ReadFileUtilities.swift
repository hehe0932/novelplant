//
//  ReadFileUtilities.swift
//  novelplant
//
//  Created by hehe on 2026/10/12.
//

/// 阅读器沙盒文件工具（移植自老项目 FRYFileUtilities.h/.m，仅保留目录/章节列表的存取，
/// 不含加密解密、内容解析、数据埋点、网络下载部分）
///
/// 目录结构：
///   Documents/xiaoshuo/books/{bookId}/chapters.txt       正式目录（plist 格式）
///   Documents/xiaoshuo/books/{bookId}/chapters_back.txt  后台增量目录（plist 格式）
///   Documents/xiaoshuo/SQL/{sqlName}                    数据库文件
///
/// 注意：重入锁 static var 与老项目一样非线程安全，调用侧保持在同一串行队列/主线程使用
enum ReadFileUtilities {

    /// 沙盒相对路径常量
    private static let booksPath = "xiaoshuo/books"
    private static let sqlPath = "xiaoshuo/SQL"

    // MARK: - 重入锁（对齐老项目 static BOOL）

    private static var isNewSaving = false
    private static var isSaving = false

    // MARK: - 沙盒操作

    /// 路径拼接统一走 NSString 桥接：
    /// String.appendingPathComponent(_:) 在 iOS 18 SDK 已标 deprecated（它没有 conformingTo 重载，
    /// 那是 URL 的 API，别被补全带偏），NSString 版行为不变也不报废弃
    private static func appendPathComponent(_ component: String, to directory: String) -> String {
        (directory as NSString).appendingPathComponent(component)
    }

    /// Documents 根路径
    private static var documentsPath: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    }

    /// Documents/xiaoshuo/books/（不存在则创建，失败返回 nil）
    private static func fileSavePath() -> String? {
        let path = appendPathComponent(booksPath, to: documentsPath)
        return createDirectoryIfNotExists(at: path) ? path : nil
    }

    /// Documents/xiaoshuo/SQL/{sqlName}（老项目数据库文件路径，目录不存在会创建）
    static func readerSQLSavePath(sqlName: String) -> String? {
        let path = appendPathComponent(sqlPath, to: documentsPath)
        guard createDirectoryIfNotExists(at: path) else { return nil }
        return appendPathComponent(sqlName, to: path)
    }

    /// 建目录：已存在（且是目录）视为成功，否则递归创建
    @discardableResult
    private static func createDirectoryIfNotExists(at dictionaryPath: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        let existed = fileManager.fileExists(atPath: dictionaryPath, isDirectory: &isDir)
        if !(isDir.boolValue && existed) {
            do {
                try fileManager.createDirectory(atPath: dictionaryPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("dictionaryPath文件夹 创建失败: \(error)")
                return false
            }
        }
        return true
    }

    /// Documents/xiaoshuo/books/{bookId}/（不存在则创建，老代码里主要用它拿链接）
    static func createCacheDictionaryIfNotExits(bookId: String) -> String? {
        guard let savePath = fileSavePath() else { return nil }
        let bookSavePath = appendPathComponent(bookId, to: savePath)
        return createDirectoryIfNotExists(at: bookSavePath) ? bookSavePath : nil
    }

    /// 存在 && 是文件（不是目录）
    static func fileExistsAtPath(_ filePath: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        let existed = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        return existed && !isDir.boolValue
    }

    // MARK: - 章节列表（正式目录）

    /// 从磁盘读取章节列表（chapters.txt，plist 格式）
    static func getChapterListWithBookId(bookId: String) -> [String: Any]? {
        guard let bookDictionary = createCacheDictionaryIfNotExits(bookId: bookId) else { return nil }
        let chapterPath = appendPathComponent("chapters.txt", to: bookDictionary)
        guard fileExistsAtPath(chapterPath) else { return nil }
        return NSDictionary(contentsOfFile: chapterPath) as? [String: Any]
    }

    /// 书籍本地目录文件地址（.../books/{bookId}/chapters.txt）
    static func bookCatalogDirBookId(bookId: String) -> String? {
        guard let bookDictionary = createCacheDictionaryIfNotExits(bookId: bookId) else { return nil }
        return appendPathComponent("chapters.txt", to: bookDictionary)
    }

    /// 目录写盘·全量：首次进入整包覆盖写。
    /// chapters 与 directory 字段都为空视为无需增加，直接返回成功（老项目字段不一致的双重保险）
    static func saveNewChapterList(_ dict: [String: Any], bookId: String) -> Bool {
        if isNewSaving { return false }
        isNewSaving = true
        // 对齐老项目每个出口复位标志；老代码有一条路径漏了复位会永久锁死，这里用 defer 兜住
        defer { isNewSaving = false }

        guard let bookDictionary = createCacheDictionaryIfNotExits(bookId: bookId) else { return false }

        let newChapters = dict["chapters"] as? [Any] ?? []
        let newDirectory = dict["directory"] as? [Any] ?? []
        if newChapters.isEmpty && newDirectory.isEmpty { return true }

        let chapterPath = appendPathComponent("chapters.txt", to: bookDictionary)
        return (dict as NSDictionary).write(toFile: chapterPath, atomically: true)
    }

    /// 目录写盘·isall 增量：
    /// 本地有旧目录时按 chapter_id 对齐——旧首章 == 新首章则覆盖，旧末章 < 新首章则追加
    static func saveChapterList(_ dict: [String: Any], bookId: String) -> Bool {
        if isSaving { return false }
        isSaving = true
        defer { isSaving = false }

        guard let bookDictionary = createCacheDictionaryIfNotExits(bookId: bookId) else { return false }
        let chapterPath = appendPathComponent("chapters.txt", to: bookDictionary)

        guard let obj = getChapterListWithBookId(bookId: bookId),
              let oldArr = obj["chapters"] as? [[String: Any]], !oldArr.isEmpty else {
            // 本地无旧目录：直接整包写入
            return (dict as NSDictionary).write(toFile: chapterPath, atomically: true)
        }

        var tempDic = dict
        guard let newChapters = dict["chapters"] as? [[String: Any]], !newChapters.isEmpty else {
            // 如果返回的是 0，说明已经不需要增加
            return true
        }

        // 不相等说明新的比旧的多，有两种情况：1.之前的没下载完 2.有新章节需要追加
        let oldFirstId = chapterId(of: oldArr.first)
        let oldLastId = chapterId(of: oldArr.last)
        let newFirstId = chapterId(of: newChapters.first)

        if oldFirstId == newFirstId {
            /// 直接覆盖替换
            return (dict as NSDictionary).write(toFile: chapterPath, atomically: true)
        } else if oldLastId < newFirstId {
            /// 追加
            tempDic["chapters"] = oldArr + newChapters
            return (tempDic as NSDictionary).write(toFile: chapterPath, atomically: true)
        } else {
            NSLog("目录写入有异常情况")
            return true
        }
    }

    // MARK: - 章节列表（后台增量）

    /// 目录写盘·后台增量：后台分批拉取先累积到 chapters_back.txt，
    /// 拉完后（新 chapters 为空）且后台与正式目录差值 < 5 时结算进正式 chapters.txt 并清空后台文件
    static func saveChapterSecondList(_ dict: [String: Any], bookId: String) -> Bool {
        guard let bookDictionary = createCacheDictionaryIfNotExits(bookId: bookId) else { return false }
        let chapterBackPath = appendPathComponent("chapters_back.txt", to: bookDictionary)
        let chapterPath = appendPathComponent("chapters.txt", to: bookDictionary)

        guard let obj = getBackgroundChapterList(bookId: bookId),
              let oldArr = obj["chapters"] as? [[String: Any]], !oldArr.isEmpty else {
            // 无后台累积：直接写入后台文件
            return (dict as NSDictionary).write(toFile: chapterBackPath, atomically: true)
        }

        var tempDic = dict
        let newChapters = dict["chapters"] as? [[String: Any]] ?? []

        // 如果返回的是 0，说明已经请求干净了：清算后台数据进正式目录
        if newChapters.isEmpty {
            let finishBackgorundChapters = getBackgroundChapterList(bookId: bookId)?["chapters"] as? [[String: Any]] ?? []
            let finishFirstChapters = getChapterListWithBookId(bookId: bookId)?["chapters"] as? [[String: Any]] ?? []

            if !finishFirstChapters.isEmpty,
               !finishBackgorundChapters.isEmpty,
               finishBackgorundChapters.count >= finishFirstChapters.count,
               (finishBackgorundChapters.count - finishFirstChapters.count) < 5 {
                tempDic["chapters"] = finishBackgorundChapters
                if (tempDic as NSDictionary).write(toFile: chapterPath, atomically: true) {
                    NSLog("后台最终写入成功")
                    // 后台数据清理：chapters 置空后回写
                    tempDic["chapters"] = [[String: Any]]()
                    if (tempDic as NSDictionary).write(toFile: chapterBackPath, atomically: true) {
                        NSLog("后台数据清理完毕")
                    } else {
                        NSLog("后台数据清理失败")
                    }
                } else {
                    NSLog("后台最终写入失败")
                }
            }
            return true
        }

        // 不相等说明新的比旧的多：1.之前的没下载完 2.有新的章节了，追加进后台文件
        let oldLastId = chapterId(of: oldArr.last)
        let newFirstId = chapterId(of: newChapters.first)
        if oldLastId < newFirstId {
            tempDic["chapters"] = oldArr + newChapters
            return (tempDic as NSDictionary).write(toFile: chapterBackPath, atomically: true)
        } else {
            NSLog("有异常情况")
            return false
        }
    }

    /// 从磁盘读取后台章节列表（chapters_back.txt）
    private static func getBackgroundChapterList(bookId: String) -> [String: Any]? {
        guard let bookDictionary = createCacheDictionaryIfNotExits(bookId: bookId) else { return nil }
        let chapterPath = appendPathComponent("chapters_back.txt", to: bookDictionary)
        guard fileExistsAtPath(chapterPath) else { return nil }
        return NSDictionary(contentsOfFile: chapterPath) as? [String: Any]
    }

    // MARK: - 章节内容路径

    /// 本地章节内容路径，文件名规则（与老项目一致，含 CDN 缓存刷新版本号）：
    ///   {chapterId}_cdn[_{version}]_{updateTime 去空格、":"换"-"}.txt
    /// refresh_version_remote > local 时视为要更新：用新版本号并回写本地版本
    static func findSaveContentPathWithBookId(bookId: String, chapterId: String, updateTime: String) -> String? {
        guard let bookDictionary = createCacheDictionaryIfNotExits(bookId: bookId) else { return nil }

        let defaults = UserDefaults.standard
        let localCount = defaults.integer(forKey: "refresh_version_local")
        var fileName = localCount == 0 ? "\(chapterId)_cdn" : "\(chapterId)_cdn\(localCount)"

        let remoteCount = defaults.integer(forKey: "refresh_version_remote")
        if remoteCount > localCount {
            // 说明要更新，就用新的链接
            fileName = "\(chapterId)_cdn\(remoteCount)"
            defaults.set(remoteCount, forKey: "refresh_version_local")
            defaults.synchronize()
        }

        if !updateTime.isEmpty {
            let time = updateTime
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ":", with: "-")
            return appendPathComponent("\(fileName)_\(time).txt", to: bookDictionary)
        } else {
            return appendPathComponent("\(fileName)_.txt", to: bookDictionary)
        }
    }

    // MARK: - Private

    /// chapter_id 在 JSON 里可能是 Int 也可能是 String，对齐老项目 integerValue 的兼容取值
    private static func chapterId(of chapter: [String: Any]?) -> Int {
        guard let value = chapter?["chapter_id"] else { return 0 }
        if let int = value as? Int { return int }
        if let string = value as? String { return Int(string) ?? 0 }
        if let double = value as? Double { return Int(double) }
        return 0
    }
}
