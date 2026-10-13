//
//  ReadNetworkManager.swift
//  novelplant
//
//  Created by hehe on 2026/10/12.
//

/// 阅读链路接口（#34-#49，参数对齐老项目 FRYNetworkTask.m / UrlMacros.h）
/// 🔒 = 老项目走 ENCRYPT_POST 的加密接口（当前加密未启用，ResponseDecryptor 检测到 encrypt-resp 放行原文）
/// account_id 统一取 User.currentUser().id；recharge_platform 对齐老项目宏 Recharge_platform = "5"
enum ReadNetworkManager {

    /// 老项目 StringMacros.h 的 Recharge_platform，渠道相关，后端分渠道时需调整
    private static let rechargePlatform = "5"

    /// #34 🔒 书籍详情（titlePage 老项目固定传 1：传 1 不返回免费的两张图，传 0 仍返回）
    case bookDetail(bookId: String, titlePage: Int)
    /// #35 是否读过
    case bookIsRead(bookId: String)
    /// #36 设置已读
    case setBookIsRead(bookId: String)
    /// #37 退出阅读器推荐（isPkg 老项目固定 1）
    case readContentRecommend(bookId: String, isPkg: Int)
    /// #38 🔒 阅读尾页热门书（老项目固定 offset 0 / limit 6 / isPkg 1）
    case hotRecommendBooks(bookId: String, offset: Int, limit: Int, isPkg: Int)
    /// #39 🔒 免费/VIP 章节
    case bookChaptersNew(bookId: String)
    /// #40 🔒 章节是否需购买
    case checkChapterNeedPay(chapterId: String, bookId: String, bookModule: String, bookModuleId: String, bookPosition: Int, source: String)
    /// #41 章节列表（老项目固定 offset 0 / limit 10000 / sortDesc "0" 正序；148 版起暂用本地文件替代，含后台变体）
    case bookChapters(bookId: String, offset: Int, limit: Int, sortDesc: String)
    /// #42 章节内容/付费信息/用户资产
    case chapterContent(chapterId: String, bookId: String)
    /// #43 🔒 章节购买（DNS 直连返回章节 URL）
    case purchaseChapter(ruleId: String, bookId: String, chapterId: String, bookModule: String, bookModuleId: String, bookPosition: Int, source: String)
    /// #44 CDN 403 兜底：代理拉章节内容（GET，path 拼 CDN 章节 URL 的 path 部分；
    /// 返回章节内容 NSData，不走 {code} 信封，需用不解析信封的请求入口接）
    case chapterContentProxy(bookId: String, chapterIndex: Int, cdnURL: String)
    /// #45 批量购买页数据
    case chapterRuleShow(chapterId: String, bookId: String)
    /// #46 全量目录（dirVer 老项目固定 "-1" 全量拉取）
    case chapterDirAll(bookId: String, dirVer: String)
    /// #47 全量目录(文件)
    case chapterDirAllFile(bookId: String)
    /// #48 分页目录（老项目 start_index = 已有章节数，end_index = 已有章节数 + 100）
    case chapterDirPage(bookId: String, dirVer: String, startIndex: Int, endIndex: Int)
    /// #49 多书阅读时长上报（st 域；readings = [{book_id, duration, start_time, end_time}]，
    /// task 内序列化为 report JSON 数组字符串，字段值均为字符串）
    case readTimeReport(readings: [[String: Any]])
}

extension ReadNetworkManager: TargetType {

    /// #49 走 st 域（老项目 type:@"st" / URL_HOST_ST），其余走主域。
    /// 这里显式实现会覆盖 BaseTargetType 协议扩展的默认 baseURL
    var baseURL: URL {
        switch self {
        case .readTimeReport:
            return URL(string: URLConst.baseURL_st)!
        default:
            return URL(string: URLConst.baseURL)!
        }
    }

    var path: String {
        switch self {
        case .bookDetail:
            return "app/api/bookstore/book_detail_v3"
        case .bookIsRead:
            return "app/api/bookstore/get_user_read_book_flag"
        case .setBookIsRead:
            return "app/api/bookstore/set_user_read_book_flag"
        case .readContentRecommend:
            return "app/api/bookstore/read_content_recommend"
        case .hotRecommendBooks:
            return "app/api/bookstore/book_tail_recomment_v3"
        case .bookChaptersNew:
            return "app/api/bookstore/vip/book_chapters_new_v3"
        case .checkChapterNeedPay:
            return "app/api/purchase/vip/check_chapter_v4"
        case .bookChapters:
            return "app/api/bookstore/book_chapters"
        case .chapterContent:
            return "app/api/bookstore/book_chapter_content_v7"
        case .purchaseChapter:
            return "app/api/purchase/vip/chapter_v4"
        case .chapterContentProxy(_, _, let cdnURL):
            // 老项目逻辑：把 CDN 章节 URL 的 path 拼到代理接口后（空则 "/"，保证前导 "/"）
            var s3Path = URL(string: cdnURL)?.path ?? ""
            if s3Path.isEmpty {
                s3Path = "/"
            } else if !s3Path.hasPrefix("/") {
                s3Path = "/" + s3Path
            }
            return "app/s3_chapter_content_proxy" + s3Path
        case .chapterRuleShow:
            return "app/api/purchase/rule_show"
        case .chapterDirAll:
            return "app/api/chapter/dir_all"
        case .chapterDirAllFile:
            return "app/api/chapter/dir_all_file"
        case .chapterDirPage:
            return "app/api/chapter/dir_page"
        case .readTimeReport:
            return "app/api/bookstore/send_mult_read_time"
        }
    }

    /// 老项目仅 #44 为 GET（403GET），其余（含 ENCRYPT_POST）均为 POST
    var method: Moya.Method {
        switch self {
        case .chapterContentProxy:
            return .get
        default:
            return .post
        }
    }

    var task: Moya.Task {
        let accountID = User.currentUser().id
        switch self {
        case .bookDetail(let bookId, let titlePage):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
                "title_page": titlePage,
            ], encoding: URLEncoding.default)
        case .bookIsRead(let bookId):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
            ], encoding: URLEncoding.default)
        case .setBookIsRead(let bookId):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
            ], encoding: URLEncoding.default)
        case .readContentRecommend(let bookId, let isPkg):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "is_pkg": isPkg,
                "book_id": bookId,
            ], encoding: URLEncoding.default)
        case .hotRecommendBooks(let bookId, let offset, let limit, let isPkg):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "offset": offset,
                "limit": limit,
                "is_pkg": isPkg,
                "book_id": bookId,
            ], encoding: URLEncoding.default)
        case .bookChaptersNew(let bookId):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
            ], encoding: URLEncoding.default)
        case .checkChapterNeedPay(let chapterId, let bookId, let bookModule, let bookModuleId, let bookPosition, let source):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "chapter_id": chapterId,
                "book_id": bookId,
                "book_module": bookModule,
                "book_module_id": bookModuleId,
                "book_position": bookPosition,
                "source": source,
            ], encoding: URLEncoding.default)
        case .bookChapters(let bookId, let offset, let limit, let sortDesc):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
                "offset": offset,
                "limit": limit,
                "sort_desc": sortDesc,
            ], encoding: URLEncoding.default)
        case .chapterContent(let chapterId, let bookId):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "recharge_platform": Self.rechargePlatform,
                "chapter_id": chapterId,
                "book_id": bookId,
            ], encoding: URLEncoding.default)
        case .purchaseChapter(let ruleId, let bookId, let chapterId, let bookModule, let bookModuleId, let bookPosition, let source):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
                "chapter_id": chapterId,
                "purchase_rule_id": ruleId,
                "book_module": bookModule,
                "book_module_id": bookModuleId,
                "book_position": bookPosition,
                "source": source,
            ], encoding: URLEncoding.default)
        case .chapterContentProxy(let bookId, let chapterIndex, _):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
                // 老项目传章节序号（0-based index + 1）的字符串
                "chapter_index": "\(chapterIndex + 1)",
            ], encoding: URLEncoding.default)
        case .chapterRuleShow(let chapterId, let bookId):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "chapter_id": chapterId,
                "book_id": bookId,
                "recharge_platform": Self.rechargePlatform,
            ], encoding: URLEncoding.default)
        case .chapterDirAll(let bookId, let dirVer):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
                "dir_ver": dirVer,
            ], encoding: URLEncoding.default)
        case .chapterDirAllFile(let bookId):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
            ], encoding: URLEncoding.default)
        case .chapterDirPage(let bookId, let dirVer, let startIndex, let endIndex):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "book_id": bookId,
                "dir_ver": dirVer,
                "start_index": startIndex,
                "end_index": endIndex,
            ], encoding: URLEncoding.default)
        case .readTimeReport(let readings):
            return .requestParameters(parameters: [
                "account_id": accountID,
                "report": Self.reportJSONString(from: readings),
            ], encoding: URLEncoding.default)
        }
    }

    /// report 参数 = JSON 数组字符串：[{"book_id":"","duration":"","start_time":"","end_time":""}]
    private static func reportJSONString(from readings: [[String: Any]]) -> String {
        guard JSONSerialization.isValidJSONObject(readings),
              let data = try? JSONSerialization.data(withJSONObject: readings),
              let json = String(data: data, encoding: .utf8) else {
            return ""
        }
        return json
    }
}

// MARK: - 章节文件下载（S3/CDN 直连，非 Moya 接口）

extension ReadNetworkManager {

    /// 下载章节 txt 文件（返回本地缓存路径）
    /// - Parameters:
    ///   - url: S3/CDN 完整 URL（如 https://.../_encrypt.txt?v=timestamp）
    ///   - bookId: 书 ID（用于构建本地缓存路径）
    ///   - chapterIndex: 章节序号（用于构建本地缓存路径）
    ///   - progress: 下载进度回调（0.0 ~ 1.0）
    ///   - completion: 完成回调（成功返回本地文件 URL，失败返回 Error）
    static func downloadChapter(
        url: String,
        bookId: String,
        chapterIndex: Int,
        progress: ((Double) -> Void)? = nil,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        // 1. 构建本地缓存路径：Caches/Chapters/<bookId>/<chapterIndex>.txt
        guard let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(.failure(NSError(domain: "ReadNetworkManager", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "无法获取缓存目录"])))
            return
        }

        let bookDir = cachesDir.appendingPathComponent("Chapters/\(bookId)", isDirectory: true)
        try? FileManager.default.createDirectory(at: bookDir, withIntermediateDirectories: true)
        let localURL = bookDir.appendingPathComponent("\(chapterIndex).txt")

        // 2. 检查缓存：已存在则直接返回
        if FileManager.default.fileExists(atPath: localURL.path) {
            completion(.success(localURL))
            return
        }

        // 3. Alamofire 下载到临时位置
        let destination: DownloadRequest.Destination = { _, _ in
            return (localURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        AF.download(url, to: destination)
            .downloadProgress { p in
                progress?(p.fractionCompleted)
            }
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success(let fileURL):
                    guard let fileURL = fileURL else {
                        completion(.failure(NSError(domain: "ReadNetworkManager", code: -2,
                                                    userInfo: [NSLocalizedDescriptionKey: "下载完成但未返回文件路径"])))
                        return
                    }
                    completion(.success(fileURL))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    /// 清除指定书的章节缓存
    static func clearChapterCache(bookId: String) {
        guard let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        let bookDir = cachesDir.appendingPathComponent("Chapters/\(bookId)", isDirectory: true)
        try? FileManager.default.removeItem(at: bookDir)
    }

    /// 清除所有章节缓存
    static func clearAllChapterCache() {
        guard let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        let chaptersDir = cachesDir.appendingPathComponent("Chapters", isDirectory: true)
        try? FileManager.default.removeItem(at: chaptersDir)
    }
}
