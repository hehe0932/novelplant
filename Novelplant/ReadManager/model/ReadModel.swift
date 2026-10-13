//
//  ReadModel.swift
//  novelplant
//
//  Created by hehe on 2026/10/12.
//

import Foundation
class ReadModel {
    var bookModek: BookModel?
    var page: Int = 0
    var chapterIndex: Int = 0

    /// 当前章节的内容模型(包含分页后的 pages 数组)
    var currentChapterContent: ChapterContentModel?
}
