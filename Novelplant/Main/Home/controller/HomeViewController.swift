//
//  HomeViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import UIKit

class HomeViewController: BaseViewController {

    private lazy var titleView: UIView = {
        let titleView = UIView()
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
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        titleView.addSubview(searchButton)
        titleView.addSubview(giftButton)
        
        searchButton.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.width.equalTo(screenW - 100)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        giftButton.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.size.equalTo(44)
            make.centerY.equalToSuperview()
        }
        
        // titleView 是裸 UIView 没有内在尺寸；子控件用的是 centerY（不产生高度），
        // 必须显式给高度，否则高度塌成 0：按钮画得出来（不裁剪）但 hitTest 进不了 bounds，点不响应。
        // 顺序很重要：高度约束必须装在赋值 navigationItem.titleView 之前——赋值那一刻
        // UIKit 会用当时测得的默认标题高度（≈22）把 _UINavigationBarTitleControl 用
        // required 级 autoresizing 约束焊死，事后再补 height==44 必然与之冲突（breaking constraint 警告）
        titleView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        navigationItem.titleView = titleView
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
}
