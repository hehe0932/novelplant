//
//  BookStore.swift
//  novelplant
//
//  Created by hehe on 2026/10/10.
//

import RealmSwift
import Realm

/// 书架本地存储入口：业务层只通过这里读写 Realm，模型不感知存储细节
enum BookStore {
    private static var realm: Realm? { try? Realm() }

    /// 全量落库（主键已存在则更新，不存在则新增）
    /// - Parameters:
    ///   - setTime: true 时按数组顺序刷新 lastOpenDate（首次导入/书架重排用）；
    ///     false 时不动该字段，库里已有的最近阅读时间会被 .modified 保留
    ///   - async: true 时事务切到后台线程执行
    static func upsert(_ models: [BookModel], setTime: Bool = false, async: Bool = false) {
        let objects = models.enumerated().map { index, model in
            let object = BookObject(model)
            if setTime {
                // 同批入库时间相同，用微小偏移保住数组顺序
                object.lastOpenDate = Date().addingTimeInterval(Double(index) * 0.001)
            }
            return object
        }
        guard let realm = realm else { return }
        let block = { realm.add(objects, update: .modified) }
        if async {
            realm.writeAsync(block)
        } else {
            try? realm.write(block)
        }
    }

    /// 书架数据，按最近打开时间倒序
    static func shelfBooks() -> [BookModel] {
        guard let results = realm?.objects(BookObject.self)
            .sorted(byKeyPath: "lastOpenDate", ascending: false) else { return [] }
        return results.map { $0.toModel() }
    }

    /// 打开书时刷新最近阅读时间
    static func updateLastOpen(bookId: Int) {
        guard let realm,
              let object = realm.object(ofType: BookObject.self, forPrimaryKey: bookId) else { return }
        try? realm.write { object.lastOpenDate = Date() }
    }

    static func delete(bookId: Int) {
        delete(bookIds: [bookId])
    }

    /// 先按主键查出托管对象再删，避免传入未托管对象导致崩溃
    static func delete(bookIds: [Int]) {
        guard let realm else { return }
        let objects = bookIds.compactMap {
            realm.object(ofType: BookObject.self, forPrimaryKey: $0)
        }
        guard !objects.isEmpty else { return }
        try? realm.write { realm.delete(objects) }
    }

    static func deleteAll() {
        guard let realm else { return }
        try? realm.write { realm.delete(realm.objects(BookObject.self)) }
    }
}
