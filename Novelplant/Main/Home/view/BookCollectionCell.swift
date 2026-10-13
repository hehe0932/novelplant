//
//  BookCollectionCell.swift
//  novelplant
//
//  Created by hehe on 2026/10/10.
//

import UIKit

/// 首页书单竖版 cell：封面(3:4) + 书名 + 观看图标/观看数
class BookCollectionCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)

        initView()
        initConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initView() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(eyeIconView)
        contentView.addSubview(countLabel)
    }

    func initConstraint() {
        coverImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            // 封面固定 3:4 竖版（规范 6.5：75×100 同比例）
            make.height.equalTo(180)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(coverImageView.snp.bottom).offset(8)
            make.height.equalTo(44)
        }


        eyeIconView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.size.equalTo(16)
        }
        countLabel.snp.makeConstraints { make in
            make.left.equalTo(eyeIconView.snp.right).offset(8)
            make.centerY.equalTo(eyeIconView)
        }
    }

    /// 封面 URL / 书名 / 观看数
    func configure(coverURL: String?, name: String?, viewCount: Int) {
        if let coverURL = coverURL, let url = URL(string: coverURL) {
            coverImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else {
            coverImageView.image = nil
        }
        nameLabel.text = name
        countLabel.text = Self.formatViewCount(viewCount)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
    }

    /// 观看数格式化：不足 1w 显示原值，≥1w 缩写为 x.xw（如 1.2w、150w）
    private static func formatViewCount(_ count: Int) -> String {
        guard count >= 10_000 else { return "\(count)" }
        let value = Double(count) / 10_000
        if value >= 100 || value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0fw", value)
        }
        return String(format: "%.1fw", value)
    }

    // MARK: - 子视图

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
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .textPrimaryColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var eyeIconView: UIImageView = {
        let img = UIImageView()
        // Assets 同名切图优先，miss 后回落 SF Symbol
        img.image = UIImage(named: "eye") ?? UIImage(systemName: "eye")
        img.tintColor = .themeColor
        img.contentMode = .scaleAspectFit
        return img
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .textSecondaryColor
        return label
    }()
}
