//
//  HomeSectionHeaderView.swift
//  novelplant
//
//  Created by hehe on 2026/10/10.
//

import UIKit

/// 首页模块 section 头：模块名 + 更多箭头（纯装饰，「更多」跳转后续接）
class HomeSectionHeaderView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        initView()
        initConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initView() {
        addSubview(titleLabel)
        addSubview(arrowImageView)
    }

    func initConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(arrowImageView.snp.left).offset(-8)
        }

        arrowImageView.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }
    }

    /// 模块名（module.name）
    func configure(title: String?) {
        titleLabel.text = title
    }

    // MARK: - 子视图

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .textPrimaryColor
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var arrowImageView: UIImageView = {
        let img = UIImageView()
        // Assets 同名切图优先，miss 后回落 SF Symbol
        img.image = UIImage(named: "chevron.forward") ?? UIImage(systemName: "chevron.forward")
        img.tintColor = .textTertiaryColor
        img.contentMode = .scaleAspectFit
        return img
    }()
}
