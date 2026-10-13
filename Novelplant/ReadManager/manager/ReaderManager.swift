//
//  ReaderManager.swift
//  novelplant
//
//  Created by hehe on 2026/10/12.
//

import Foundation

class ReaderManager {
    static func readWithParams(params: [String: Any], book: BookModel) {
        
        let pageVC = ReadPageViewController()
        pageVC.bookId = book.com_book_id ?? ""

        currentNavigationController?.pushViewController(pageVC, animated: true)
    }
}
