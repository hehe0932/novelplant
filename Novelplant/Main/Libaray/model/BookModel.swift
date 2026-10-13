//
//  BookModel.swift
//
//
//  Created by JSONConverter on 2026/10/10.
//  Copyright © 2026年 JSONConverter. All rights reserved.
//

import Foundation

/// 书籍网络模型（纯 DTO）：只负责 JSON ↔ 模型转换，本地持久化见 BookObject / BookStore
class BookModel: Convertible {
    var book_id: Int = 0 // 数字书籍ID（服务端下发的数字书籍ID）
    var author_id: String? // 作者ID
    var author_name: String? // 作者名称
    var book_category: String? // 书籍分类名称
    var book_category_id: Int = 0 // 书籍分类ID
    /// 书籍ID（字符串，用于外部/通用场景，对应 OC 端 FRYBookModel.bid）
    var com_book_id: String? //书籍id
    var cover: String? // 书籍封面地址
    var create_time: String? // 创建时间
    var discount: Int = 0 // 折扣（0 表示无折扣，具体取值按服务端约定）
    var external_cp_book_id: String? // 外部 CP 书籍ID（版权方书籍ID）
    var finished: Int = 0 // 0表示连载，1表示完结
    var intro: String? // 书籍介绍
    var is_vip: Int = 0 // 是否 VIP 书籍（0 否，1 是）
    var language: String? // 语言
    var latest_book_updated: String? // 最近一次书籍更新时间
    var marketing_type: Int = 0 // 营销类型
    var pre_book_updated: String? // 上一次书籍更新时间
    var sale_type: Int = 0 // 售卖类型（如免费/付费等，按服务端约定）
    var score: String? // 评分
    var shelves_status: Int = 0 // 强制下架状态（非 0 表示被下架）
    var show_author_name: Int = 0 // 是否显示作者名（1 显示）
    var title: String? // 书名
    var update_time: String? // 更新时间
    var tags: [String] = [] // 标签列表
    var chapter_count: Int = 0 // 总章节数
    var first_chapter_id: Int = 0 // 第一章章节ID
    /// 书籍总字数（对应 OC 端 FRYChapterModel.words 的书籍级概念）
    var words: Int = 0
    /// 收藏/加入书架数量（后端原字段 adds_count；老项目 mj 映射候选 addCount/adds_count）
    var adds_count: Int = 0
    /// 浏览/阅读量（后端原字段 views_count；老项目 mj 映射候选 viewCount/views_count，ForYou 接口同名佐证）
    var views_count: Int = 0
    // MARK: - 购买/充值链路透传（接口下发或页面间赋值挂在 book 实例上；
    // check_chapter_v4 / purchase chapter_v4 必填参数、充值页归因字段都从这里取）
    var uid: Int = 0 // 用户 id
    var book_module: String? // 书模块
    var book_module_id: String? // 书模块 id
    var book_position: Int = 0 // 书位置
    var source: String? // 来源
    var top_up_source: String? // 充值归因来源
    var active_id: String? // 活动 id
    var active_name: String? // 活动名称
    var touch_way: String? // 触达方式（充值归因）
    // MARK: - 最新章节（订阅接口下发，书架"更新到X章"展示）
    var latest_chapter_bid: String? // 最新章节书籍 id
    var latest_chapter_cid: String? // 最新章节 id
    // 本地 UI 态：书架编辑模式勾选用，不落库（服务端不下发该字段）
    var selected: Bool = false
    var hasUpdate: Bool = false // 是否有更新（书架显示更新提示）
    var chapters: [ChapterModel] = []
    
    required init() {}
}
