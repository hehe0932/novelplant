//
//  ChapterContentModel.swift
//  novelplant
//
//  Created by hehe on 2026/10/13.
//

import Foundation
class ChapterContentModel {
    var content: String = ""
    var title: String = ""
    var pageCount: Int = 0
    var chapterModel: ChapterModel = ChapterModel()
    var chapterIndex: Int = 0

    /// CoreText 排版结果(存储页偏移量数组,不存字符串副本以节省内存)
    var layoutResult: ReadPageLayoutEngine.LayoutResult?
}
