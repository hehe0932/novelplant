//
//  MeHeaderView.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import UIKit

class MeHeaderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
        initFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(arrowImageView)
    }


    func initFrame() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(88)
            make.left.equalTo(16)
            make.top.equalTo(16)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(12)
            make.centerY.equalTo(profileImageView)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(profileImageView)
        }
    }
    
    private lazy var profileImageView: UIImageView = {
        let img = UIImageView()
        // 游客态占位头像；登录后可通过 kf 设置真实头像 URL
        img.image = UIImage(systemName: "person.crop.circle.fill")
        img.tintColor = .themeColor
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Visitor", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .textPrimaryColor
        return label
    }()

    private lazy var arrowImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "chevron.forward")
        img.tintColor = .textTertiaryColor
        return img
    }()
}
