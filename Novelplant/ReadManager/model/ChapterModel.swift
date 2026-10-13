//
//  ChapterModel.swift
//
//
//  Created by JSONConverter on 2026/10/12.
//  Copyright © 2026年 JSONConverter. All rights reserved.
//

import Foundation
import KakaJSON

struct ChapterModel: Convertible {
	var book_id: String = ""
	var chapter_id: String = ""
	var cid: String?
	var com_book_id: String?
	var create_time: String?
	var free: Bool = false
	var index: Int = 0
	var is_show: Bool = false
	var need_pay: Int = 0
	var price: Int = 0
	var title: String?
	var update_time: String?
	var url: String?
	var words: Int = 0
}
