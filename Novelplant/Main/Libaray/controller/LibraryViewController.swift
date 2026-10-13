//
//  LibraryViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import UIKit

class LibraryViewController: BaseViewController {

    private var libraryArray = [BookModel]()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        initData()
    }

    func initData() {
        //先加载收藏的（selected 是 DTO 内存态，每次新构造默认 false，无需重置）
        libraryArray = BookStore.shelfBooks()
        if !libraryArray.isEmpty {
            collectionView.reloadData()
        }

        loadBuiltinBook()
    }
    func loadBuiltinBook() {
        //再加载内置的,内置的只请求一次,内置的存数据库,再请求书架的,见老项目LibraryViewController
        
        let isLoaded = UserDefaults.standard.bool(forKey: Const.isLoadedInitBook)
        if !isLoaded {
            NetWorkRequest(LibraryManager.buildBook) { result in
                guard let data = result as? [[String: Any]] else { return }
                let array = data.kj.modelArray(BookModel.self)

                BookStore.upsert(array)
                self.libraryArray = BookStore.shelfBooks()
                
                self.collectionView.reloadData()
                UserDefaults.standard.set(true, forKey: Const.isLoadedInitBook)
                self.loadInSelfBooks()
            } failed: { _, _ in
                self.loadInSelfBooks()
            }
        } else {
            loadInSelfBooks()
        }
        
    }
    
    func loadInSelfBooks() {
        let userId = User.currentUser().id
        if userId.isEmpty {

            //TODO -- 游客登录流程
            return;
        }
        
        let params: [String: Any] = [
            "account_id": userId,
            "offset": 0,
            "limit": 1000
        ]
        NetWorkRequest(LibraryManager.inshelfBook(params: params)) { result in
            //TODO-- 完成后请求黑名单书-登录后再做
        }
        
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = CollectionViewLeftAlignedLayout()
        layout.itemSize = CGSize(width: (screenW - 4*16)/3.0, height: 200)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: navHeight, width: screenW, height: screenH - navHeight), collectionViewLayout: layout)
        collectionView.backgroundColor = .bgColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.register(LibraryCollectionCell.self, forCellWithReuseIdentifier: "LibraryCollectionCellID")
       
        return collectionView
    }()
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        libraryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryCollectionCellID", for: indexPath) as! LibraryCollectionCell
        let model = libraryArray[indexPath.row]
        cell.configure(coverURL: model.cover, name: model.title)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = libraryArray[indexPath.row]
        model.hasUpdate = false
        //这些是埋点数据
        let readParams: [String: Any] = [
            "bid": model.com_book_id ?? "",
            "top_up_source": "reader",
            "book_module": "",
            "book_module_id": "",
            "book_position": "\(indexPath.row + 1)",
            "source": "library",
            "name": model.title ?? "",
            "page_name": "library",
        ]
        
        ReaderManager.readWithParams(params: readParams, book: model)
    }
}
