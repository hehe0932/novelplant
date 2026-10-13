//
//  BookObject.swift
//  novelplant
//
//  Created by hehe on 2026/10/10.
//

import RealmSwift
import Realm

/// 书架本地存储模型（Realm），字段与 BookModel 一一映射，读写只经 BookStore
final class BookObject: Object {
    @Persisted(primaryKey: true) var book_id: Int = 0
    @Persisted var author_id: String?
    @Persisted var author_name: String?
    @Persisted var book_category: String?
    @Persisted var book_category_id: Int = 0
    @Persisted var com_book_id: String?
    @Persisted var cover: String?
    @Persisted var create_time: String?
    @Persisted var discount: Int = 0
    @Persisted var external_cp_book_id: String?
    @Persisted var finished: Int = 0
    @Persisted var intro: String?
    @Persisted var is_vip: Int = 0
    @Persisted var language: String?
    @Persisted var latest_book_updated: String?
    @Persisted var marketing_type: Int = 0
    @Persisted var pre_book_updated: String?
    @Persisted var sale_type: Int = 0
    @Persisted var score: String?
    @Persisted var shelves_status: Int = 0
    @Persisted var show_author_name: Int = 0
    @Persisted var title: String?
    @Persisted var update_time: String?
    @Persisted var chapter_count: Int = 0
    @Persisted var first_chapter_id: Int = 0
    @Persisted var words: Int = 0
    @Persisted var adds_count: Int = 0
    @Persisted var views_count: Int = 0
    @Persisted var tags = List<String>()
    // MARK: - 购买/充值链路透传（与 BookModel 一一映射；书架离线打开阅读器购买时要用）
    @Persisted var uid: Int = 0
    @Persisted var book_module: String?
    @Persisted var book_module_id: String?
    @Persisted var book_position: Int = 0
    @Persisted var source: String?
    @Persisted var top_up_source: String?
    @Persisted var active_id: String?
    @Persisted var active_name: String?
    @Persisted var touch_way: String?
    @Persisted var latest_chapter_bid: String?
    @Persisted var latest_chapter_cid: String?
    // 本地自定义：最近打开时间；nil 表示未记录（update: .modified 不会覆盖库里已有值）
    @Persisted var lastOpenDate: Date?
    // MARK: - 本地阅读进度/状态（对应 OC 端 FRYBookModel 本地字段，不来自服务端 JSON）
    @Persisted var collectDate: Date? // 收藏日期（老字段 date）
    @Persisted var hasDownloadChapter: Bool = false // 是否下载过章节
    @Persisted var recordBid: String? // 阅读记录-书 id（老字段 record_bid）
    @Persisted var recordCid: String? // 阅读记录-章节 id（老字段 record_cid）
    @Persisted var recordDate: Date? // 阅读记录时间（老字段 record_date）
    @Persisted var chapterIndex: Int = 0 // 当前读到索引，从 0 开始
    @Persisted var page: Int = 0 // 当前阅读章节页码
    @Persisted var wordOffset: Int = 0 // 当前阅读章节文字偏移
    @Persisted var viewOffset: Float = 0 // 视图偏移（上下滑动翻页阅读历史用）

    convenience init(_ model: BookModel) {
        self.init()
        book_id = model.book_id
        author_id = model.author_id
        author_name = model.author_name
        book_category = model.book_category
        book_category_id = model.book_category_id
        com_book_id = model.com_book_id
        cover = model.cover
        create_time = model.create_time
        discount = model.discount
        external_cp_book_id = model.external_cp_book_id
        finished = model.finished
        intro = model.intro
        is_vip = model.is_vip
        language = model.language
        latest_book_updated = model.latest_book_updated
        marketing_type = model.marketing_type
        pre_book_updated = model.pre_book_updated
        sale_type = model.sale_type
        score = model.score
        shelves_status = model.shelves_status
        show_author_name = model.show_author_name
        title = model.title
        update_time = model.update_time
        chapter_count = model.chapter_count
        first_chapter_id = model.first_chapter_id
        words = model.words
        adds_count = model.adds_count
        views_count = model.views_count
        tags.append(objectsIn: model.tags)
        uid = model.uid
        book_module = model.book_module
        book_module_id = model.book_module_id
        book_position = model.book_position
        source = model.source
        top_up_source = model.top_up_source
        active_id = model.active_id
        active_name = model.active_name
        touch_way = model.touch_way
        latest_chapter_bid = model.latest_chapter_bid
        latest_chapter_cid = model.latest_chapter_cid
    }

    func toModel() -> BookModel {
        let model = BookModel()
        model.book_id = book_id
        model.author_id = author_id
        model.author_name = author_name
        model.book_category = book_category
        model.book_category_id = book_category_id
        model.com_book_id = com_book_id
        model.cover = cover
        model.create_time = create_time
        model.discount = discount
        model.external_cp_book_id = external_cp_book_id
        model.finished = finished
        model.intro = intro
        model.is_vip = is_vip
        model.language = language
        model.latest_book_updated = latest_book_updated
        model.marketing_type = marketing_type
        model.pre_book_updated = pre_book_updated
        model.sale_type = sale_type
        model.score = score
        model.shelves_status = shelves_status
        model.show_author_name = show_author_name
        model.title = title
        model.update_time = update_time
        model.chapter_count = chapter_count
        model.first_chapter_id = first_chapter_id
        model.words = words
        model.adds_count = adds_count
        model.views_count = views_count
        model.tags = Array(tags)
        model.uid = uid
        model.book_module = book_module
        model.book_module_id = book_module_id
        model.book_position = book_position
        model.source = source
        model.top_up_source = top_up_source
        model.active_id = active_id
        model.active_name = active_name
        model.touch_way = touch_way
        model.latest_chapter_bid = latest_chapter_bid
        model.latest_chapter_cid = latest_chapter_cid
        return model
    }
}
