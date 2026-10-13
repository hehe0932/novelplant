//
//  ForYou.swift
//
//
//  Created by JSONConverter on 2026/10/10.
//  Copyright © 2026年 JSONConverter. All rights reserved.
//

struct ForYou: Convertible {
	var module: ForYouModule?
	var module_data = [ForYouModule_data]()
	var module_force_data = [ForYouModule_force_data]()
}

struct ForYouModule: Convertible {
	var description: String?
	var dynamic_books_num: Int = 0
	var dynamic_data_source: String?
	var icon: String?
	var is_dynamic_data: Int = 0
	var module_id: Int = 0
	var module_min_show_number: String?
	var module_type_code: String?
	var name: String?
}

struct ForYouModule_force_data: Convertible {
	var adds_count: Int = 0
	var author_name: String?
	var book_category: String?
	var book_category_id: Int = 0
	var book_id: Int = 0
	var com_book_id: String?
	var cover: String?
	var discount: Int = 0
	var external_cp_book_id: String?
	var finished: Int = 0
	var intro: String?
	var is_short_story: Int = 0
	var is_vip: Int = 0
	var latest_book_updated: String?
	var marketing_type: Int = 0
	var pre_book_updated: String?
	var sale_type: Int = 0
	var score: Int = 0
	var show_author_name: Int = 0
	var title: String?
	var views_count: Int = 0
	var force_index: Int = 0 // 运营位插入位置，从 1 开始
}

struct ForYouModule_data: Convertible {
	var adds_count: Int = 0
	var author_name: String?
	var book_category: String?
	var book_category_id: Int = 0
	var book_id: Int = 0
	var com_book_id: String?
	var cover: String?
	var discount: Int = 0
	var external_cp_book_id: String?
	var finished: Int = 0
	var intro: String?
	var is_short_story: Int = 0
	var is_vip: Int = 0
	var latest_book_updated: String?
	var marketing_type: Int = 0
	var pre_book_updated: String?
	var sale_type: Int = 0
	var score: Float = 0.0
	var show_author_name: Int = 0
	var title: String?
	var views_count: Int = 0
}

extension ForYouModule_data {
    /// 运营位数据插进 module_data 用（老项目 data / forceData 为同一结构）
    init(_ force: ForYouModule_force_data) {
        self.init()
        adds_count = force.adds_count
        author_name = force.author_name
        book_category = force.book_category
        book_category_id = force.book_category_id
        book_id = force.book_id
        com_book_id = force.com_book_id
        cover = force.cover
        discount = force.discount
        external_cp_book_id = force.external_cp_book_id
        finished = force.finished
        intro = force.intro
        is_short_story = force.is_short_story
        is_vip = force.is_vip
        latest_book_updated = force.latest_book_updated
        marketing_type = force.marketing_type
        pre_book_updated = force.pre_book_updated
        sale_type = force.sale_type
        score = Float(force.score)
        show_author_name = force.show_author_name
        title = force.title
        views_count = force.views_count
    }
}
