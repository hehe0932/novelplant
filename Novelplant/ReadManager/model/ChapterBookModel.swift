//
//  ChapterBookModel.swift
//  novelplant
//
//  Created by hehe on 2026/10/12.
//

import Foundation
struct ChapterBookModel: Convertible {
    var chapterCount: Int = 0
    var chapterIndex: Int = 0
    var chapterPage: Int = 0
    var readFinished: Int = 0
    var dir_ver: Int = 0
    var chapters: [ChapterModel] = []
}
