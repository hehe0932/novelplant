//
//  LibraryManager.swift
//  novelplant
//
//  Created by hehe on 2026/10/10.
//

enum LibraryManager {
    case buildBook //内置书
    case inshelfBook(params: [String: Any]) //书架上的书
    case requestBlack //书籍黑名单
    case addBook //添加到远端
    case deleteBook //删除1本
    case deleteBooks //批量删除
}

extension LibraryManager: TargetType {
    var path: String {
        switch self {
        case .buildBook:
            return "app/api/subscribe/init_books"
        case .inshelfBook:
            return "app/api/subscribe/books"
        case .requestBlack:
            return "app/api/bookstore/book_black_list"
        case .addBook:
            return "app/api/subscribe/add_book"
        case .deleteBook:
            return "app/api/subscribe/del_book"
        case .deleteBooks:
            return "app/api/subscribe/del_books"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        let userID = User.currentUser().id
        
        switch self {
        case .buildBook:
            return .requestParameters(parameters: ["account_id": "1076723"], encoding: URLEncoding.default)
        case .inshelfBook(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .requestBlack:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        case .addBook:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        case .deleteBook:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        case .deleteBooks:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        }
    }
    
    
}

