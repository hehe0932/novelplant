//
//  HomeSubViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/10.
//

import UIKit

class HomeSubViewController: BaseViewController {

    var code = ""
    var name = ""
    var isFirst = false

    private var datas = [ForYou]()
    private var moreModel: ForYou?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        initData()

    }

    /// - Parameter isRefresh: 下拉刷新时打乱书单，保持新鲜感；首次进入不乱序
    func initData(isRefresh: Bool = false) {
        let user = User.currentUser()
        let params: [String: Any] = [
            "account_id" : user.id,
            "page_code" : code,
            "need_banner" : false
        ]
        NetWorkRequest(HomeManager.forYou(params: params), completion: { result in
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()

            guard let data = result as? [[String: Any]] else { return }
            self.datas = data.kj.modelArray(ForYou.self)

            for index in self.datas.indices {
                let templateId = Int(self.datas[index].module?.module_type_code ?? "") ?? 0
                // 模板 4 / 24 不参与乱序和运营位插入
                if templateId != 4 && templateId != 24 {
                    let moduleData = self.datas[index].module_data
                    var list = (isRefresh && moduleData.count > 1) ? moduleData.shuffled() : moduleData
                    // 运营位按 force_index 插回（从 1 开始），越界追加到末尾
                    for forceModel in self.datas[index].module_force_data {
                        let dataModel = ForYouModule_data(forceModel)
                        if forceModel.force_index > 0 && list.count > forceModel.force_index {
                            list.insert(dataModel, at: forceModel.force_index - 1)
                        } else {
                            list.append(dataModel)
                        }
                    }
                    self.datas[index].module_data = list
                }
                // 模板 6 是"加载更多"模块，记录后沉底
                if templateId == 6 {
                    self.moreModel = self.datas[index]
                }
            }

            if let moreModel = self.moreModel {
                if let index = self.datas.firstIndex(where: { $0.module?.module_id == moreModel.module?.module_id }) {
                    self.datas.remove(at: index)
                }
                self.datas.append(moreModel)
                // TODO: 加载更多 footer 待接入：老项目在此挂 mj_footer，用 moreModel 的 module_id 翻页请求
            } else {
                self.collectionView.mj_footer = nil
            }

            self.collectionView.reloadData()
            // TODO: 埋点未接入：fb_module_expose 模块曝光 + 首屏(isFirst)神策曝光
        }, failed: { _, _ in
            self.requestFailed()
        }, errorResult: {
            self.requestFailed()
        })
    }

    /// 请求失败：已有数据时保持列表不动，空列表时清空展示错误占位
    private func requestFailed() {
        collectionView.mj_header?.endRefreshing()
        collectionView.mj_footer?.endRefreshing()
        guard datas.isEmpty else { return }

        datas.removeAll()
        collectionView.reloadData()
        // TODO: 网络错误占位视图待接入
    }

    private lazy var collectionView: UICollectionView = {
        // 整页竖滑 + 每个 section 内部横滑（正交滚动），对应老项目 tableView + 嵌套横向 collectionView 的结构
        // [weak self]：layout 闭包强持 self 会与 lazy collectionView 成引用环，VC 永不释放
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            // 模板差异化入口：判断条件按真实 module_type_code 替换（这里以 2 为示意）
            let typeCode: Int
            if let self, self.datas.indices.contains(sectionIndex) {
                typeCode = Int(self.datas[sectionIndex].module?.module_type_code ?? "") ?? 0
            } else {
                typeCode = 0
            }
            return typeCode == 2 ? Self.makeTwoLineSection() : Self.makeSingleLineSection()
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(BookCollectionCell.self, forCellWithReuseIdentifier: "BookCollectionCellID")
        collectionView.register(HomeSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HomeSectionHeaderViewID")
        return collectionView
    }()

    /// 单行横滑：continuous 自由滑
    private static func makeSingleLineSection() -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: Self.horizontalRowGroup())
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = Self.sectionInsets
        section.boundarySupplementaryItems = [Self.makeHeader()]
        return section
    }

    /// 两行横滑：一"页"竖装两行，groupPaging 整页翻（continuous 会停在半张卡的位置）
    private static func makeTwoLineSection() -> NSCollectionLayoutSection {
        let pageSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(266 * 2))
        let page = NSCollectionLayoutGroup.vertical(layoutSize: pageSize,
                                                    subitems: [Self.horizontalRowGroup(), Self.horizontalRowGroup()])
        let section = NSCollectionLayoutSection(group: page)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = Self.sectionInsets
        section.boundarySupplementaryItems = [Self.makeHeader()]
        return section
    }

    /// 一行 item 的横向 group：宽度 estimated 才会随 item 数量撑开超出屏宽，横滑才滚得起来
    private static func horizontalRowGroup() -> NSCollectionLayoutGroup {
        // 卡片可见 120x250；间距 16 均摊到 item 四边（不用 interItemSpacing，
        // 它与 estimated 组宽组合在 iOS 15 上不生效），单侧 8 → item 占位 136x266
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(250))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(screenW), heightDimension: .absolute(266))
        return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    }

    private static var sectionInsets: NSDirectionalEdgeInsets {
        // 屏缘 16 = section 8 + item 8
        NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 0, trailing: 8)
    }

    private static func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                           elementKind: UICollectionView.elementKindSectionHeader,
                                                           alignment: .top)
    }

}

extension HomeSubViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datas.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas[section].module_data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionCellID", for: indexPath) as! BookCollectionCell

        let model = datas[indexPath.section].module_data[indexPath.item]
        cell.configure(coverURL: model.cover, name: model.title, viewCount: model.views_count)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "HomeSectionHeaderViewID",
            for: indexPath
        ) as! HomeSectionHeaderView
        header.configure(title: datas[indexPath.section].module?.name)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

extension HomeSubViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        view
    }
}
