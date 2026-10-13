//
//  HomeViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import UIKit

class HomeViewController: BaseViewController {

    private var categoryArray = [HomeCategory]()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.titleView = titleView
        titleView.addSubview(searchButton)
        titleView.addSubview(giftButton)
        
        searchButton.snp.makeConstraints { make in
            make.left.equalTo(12)
            // 不用 screenW 绝对宽度：titleView 实际宽度由导航栏的标题区域决定，
            // 右边直接锚到礼物按钮左侧，随 titleView 宽度自适应
            make.right.equalTo(giftButton.snp.left).offset(-8)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        giftButton.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.size.equalTo(44)
            make.centerY.equalToSuperview()
        }
        
        titleView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(screenW)
        }
        
        NetWorkRequest(HomeManager.category) { result in

            guard let data = result as? [[String: Any]] else { return }
            self.categoryArray = data.kj.modelArray(HomeCategory.self)
            var nameArray = [String]()
            self.categoryArray.forEach { model in
                if model.name == "Genres" {
                    model.name = NSLocalizedString("Genres", comment: "")
                } else if model.name == "Rankings" {
                    model.name = NSLocalizedString("Rankings", comment: "")
                }
                
                nameArray.append(model.name)
            }
            self.segmentedDataSource.titles = nameArray
            self.view.addSubview(self.segmentView)
            self.view.addSubview(self.listContainerView)
        }
    }

    // MARK: - Actions
    @objc func searchButtonDidClick() {
        print("asdasdasd");
        // TODO: 跳转搜索页
        XHToastManager.makeToast(NSLocalizedString("Coming soon", comment: ""))
    }

    @objc func giftButtonDidClick() {
        // TODO: 跳转礼包/兑换页
        XHToastManager.makeToast(NSLocalizedString("Coming soon", comment: ""))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("aaaa")
    }
    
    private lazy var titleView: UIView = {
        let titleView = UIView(frame: CGRectMake(0, 0, screenW, 44))
        titleView.backgroundColor = .white
        return titleView
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton(type: .custom)
        // 仿搜索框样式：胶囊底 + 放大镜 + 占位文案，点击后跳搜索页
        btn.backgroundColor = .bgColor
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        btn.tintColor = .textTertiaryColor
        btn.setTitle(NSLocalizedString("Search novels or authors", comment: ""), for: .normal)
        btn.setTitleColor(.textTertiaryColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(searchButtonDidClick), for: .touchUpInside)
        return btn
    }()

    private lazy var giftButton: UIButton = {
        let btn = UIButton(type: .custom)
        // 礼包/兑换入口，主题橙染色的礼物盒图标
        btn.setImage(UIImage(systemName: "gift.fill"), for: .normal)
        btn.tintColor = .themeColor
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(giftButtonDidClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var segmentView: JXSegmentedView = {
        let segmentView = JXSegmentedView(frame: CGRect(x: 0, y: navHeight, width: screenW, height: 64))
        segmentView.dataSource = segmentedDataSource
        segmentView.delegate = self
        segmentView.listContainer = listContainerView
        return segmentView
    }()

    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let segmentedDataSource = JXSegmentedTitleDataSource()
        segmentedDataSource.titleNormalColor = .textPrimaryColor
        segmentedDataSource.titleSelectedColor = .themeColor
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titleNormalFont = UIFont.boldSystemFont(ofSize: 16)
        segmentedDataSource.titleSelectedFont = UIFont.boldSystemFont(ofSize: 18)
        
        segmentedDataSource.isItemSpacingAverageEnabled = false
        segmentedDataSource.itemSpacing = 30
        return segmentedDataSource
    }()
    
    private lazy var listContainerView: JXSegmentedListContainerView = {
        let containerView = JXSegmentedListContainerView(dataSource: self)
        containerView.frame = CGRect(x: 0, y: statusBarHeight + 108, width: screenW, height: screenH - statusBarHeight - 108)
        return containerView
    }()
}


extension HomeViewController: JXSegmentedListContainerViewDataSource, JXSegmentedViewDelegate {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        categoryArray.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> any JXSegmentedListContainerViewListDelegate {
        let model = categoryArray[index]
        if model.type == 1 {
            //model.code==2是排行页面  model.code==3是分类页面
            if model.code == "2" {
                return RankingsViewController()
            } else if model.code == "3" {
                return GentresViewController()
            } else {
                let vc = HomeSubViewController()
                vc.code = model.code
                vc.name = model.name
                return vc
                
            }
            
        } else {
            
            let vc = HomeSubViewController()
            vc.code = model.code
            vc.name = model.name
            if index == 0 {
                vc.isFirst = true
            }
            return vc
        }
    }
}
