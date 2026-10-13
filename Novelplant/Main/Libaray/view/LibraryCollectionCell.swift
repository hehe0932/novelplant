//
//  LibraryCollectionCell.swift
//  novelplant
//
//  Created by hehe on 2026/10/10.
//

import UIKit

class LibraryCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(coverImageView)
        contentView.addSubview(nameLabel)
        
        coverImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(coverImageView.snp.bottom).offset(8)
//            make.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(coverURL: String?, name: String?) {
        if let coverURL = coverURL, let url = URL(string: coverURL) {
            coverImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else {
            coverImageView.image = nil
        }
        nameLabel.text = name
    }
    
    
    private lazy var coverImageView: UIImageView = {
        let img = UIImageView()
        // 加载前/失败时的灰底占位（深色模式自适应）
        img.backgroundColor = .placeholderColor
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.cornerRadius = 8
        return img
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .textPrimaryColor
        label.numberOfLines = 2
        return label
    }()
}
