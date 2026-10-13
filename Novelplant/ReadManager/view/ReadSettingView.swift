//
//  ReadSettingView.swift
//  novelplant
//
//  Created by hehe on 2026/10/13.
//

import UIKit

class ReadSettingView: UIView {

    var onConfigChanged: ((ReadSettingConfig) -> Void)?
    private let config: ReadSettingConfig
    private var originalBrightness: CGFloat = UIScreen.main.brightness

    // MARK: - 初始化
    init(config: ReadSettingConfig) {
        self.config = config
        self.originalBrightness = UIScreen.main.brightness
        super.init(frame: .zero)
        setupUI()
        updateUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 组件
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "阅读设置"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .textPrimaryColor
        label.textAlignment = .center
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        if let image = UIImage(systemName: "xmark") {
            button.setImage(image, for: .normal)
            button.tintColor = .textSecondaryColor
        }
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return button
    }()

    // 亮度调节
    private lazy var brightnessLabel: UILabel = {
        let label = UILabel()
        label.text = "屏幕亮度"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textPrimaryColor
        return label
    }()

    private lazy var brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.1
        slider.maximumValue = 1.0
        slider.minimumTrackTintColor = .themeColor
        slider.maximumTrackTintColor = UIColor(hex: "#E5E5E5")
        slider.addTarget(self, action: #selector(brightnessChanged), for: .valueChanged)
        return slider
    }()

    // 主题色
    private lazy var themeLabel: UILabel = {
        let label = UILabel()
        label.text = "主题背景"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textPrimaryColor
        return label
    }()

    private lazy var themeButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    private var themeButtons: [UIButton] = []

    // 翻页方式
    private lazy var pageTransitionLabel: UILabel = {
        let label = UILabel()
        label.text = "翻页方式"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textPrimaryColor
        return label
    }()

    private lazy var pageTransitionSegment: UISegmentedControl = {
        let items = ["仿真翻页", "平滑滑动"]
        let segment = UISegmentedControl(items: items)
        segment.addTarget(self, action: #selector(pageTransitionChanged), for: .valueChanged)
        return segment
    }()

    // MARK: - 布局
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(brightnessLabel)
        containerView.addSubview(brightnessSlider)
        containerView.addSubview(themeLabel)
        containerView.addSubview(themeButtonsStack)
        containerView.addSubview(pageTransitionLabel)
        containerView.addSubview(pageTransitionSegment)

        // 创建 5 个主题按钮
        let themeColors: [(bg: UIColor, border: UIColor)] = [
            (UIColor(hex: "#F5EDD8"), UIColor(hex: "#D4C5A8")),  // 米黄
            (UIColor(hex: "#FFFFFF"), UIColor(hex: "#DDDDDD")),  // 灰白
            (UIColor(hex: "#E3F2E1"), UIColor(hex: "#B8D7B5")),  // 青绿
            (UIColor(hex: "#FFE4E9"), UIColor(hex: "#FFAAC0")),  // 浅粉
            (UIColor(hex: "#1C1C1E"), UIColor(hex: "#444444"))   // 夜间黑
        ]

        for (index, colors) in themeColors.enumerated() {
            let button = UIButton(type: .custom)
            button.backgroundColor = colors.bg
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 2
            button.layer.borderColor = colors.border.cgColor
            button.tag = index
            button.addTarget(self, action: #selector(themeButtonTapped(_:)), for: .touchUpInside)

            // 夜间黑色按钮添加月牙图标
            if index == 4 {
                if let moonImage = UIImage(systemName: "moon.fill") {
                    let imageView = UIImageView(image: moonImage)
                    imageView.tintColor = UIColor(hex: "#FFD700")
                    imageView.contentMode = .scaleAspectFit
                    button.addSubview(imageView)
                    imageView.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                        make.width.height.equalTo(16)
                    }
                }
            }

            themeButtons.append(button)
            themeButtonsStack.addArrangedSubview(button)
        }

        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(400)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }

        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(44)
        }

        brightnessLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
        }

        brightnessSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(brightnessLabel.snp.bottom).offset(12)
        }

        themeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(brightnessSlider.snp.bottom).offset(28)
        }

        themeButtonsStack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(themeLabel.snp.bottom).offset(12)
            make.height.equalTo(40)
        }

        pageTransitionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(themeButtonsStack.snp.bottom).offset(28)
        }

        pageTransitionSegment.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(pageTransitionLabel.snp.bottom).offset(12)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().offset(-20 - safeAreaBottomSpace)
        }

        // 添加点击手势关闭
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    private func updateUI() {
        brightnessSlider.value = Float(config.brightness)
        pageTransitionSegment.selectedSegmentIndex = config.pageTransitionMode

        // 更新主题按钮选中态
        for (index, button) in themeButtons.enumerated() {
            if index == config.themeIndex {
                button.layer.borderWidth = 3
                button.layer.borderColor = UIColor.themeColor.cgColor
            } else {
                button.layer.borderWidth = 2
                let borderColors: [UIColor] = [
                    UIColor(hex: "#D4C5A8"),  // 米黄
                    UIColor(hex: "#DDDDDD"),  // 灰白
                    UIColor(hex: "#B8D7B5"),  // 青绿
                    UIColor(hex: "#FFAAC0"),  // 浅粉
                    UIColor(hex: "#444444")   // 夜间黑
                ]
                button.layer.borderColor = borderColors[index].cgColor
            }
        }
    }

    // MARK: - 事件处理
    @objc private func brightnessChanged() {
        let value = CGFloat(brightnessSlider.value)
        config.brightness = value
        UIScreen.main.brightness = value
        notifyConfigChanged()
    }

    @objc private func themeButtonTapped(_ sender: UIButton) {
        config.themeIndex = sender.tag
        updateUI()
        notifyConfigChanged()
    }

    @objc private func pageTransitionChanged() {
        config.pageTransitionMode = pageTransitionSegment.selectedSegmentIndex
        notifyConfigChanged()
    }

    @objc private func closeAction() {
        dismiss()
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !containerView.frame.contains(location) {
            dismiss()
        }
    }

    private func notifyConfigChanged() {
        config.save()
        onConfigChanged?(config)
    }

    // MARK: - 显示/隐藏
    func show(in view: UIView) {
        view.addSubview(self)
        self.frame = view.bounds

        // 初始位置在屏幕下方
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        alpha = 0

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
            self.alpha = 1
        }
    }

    private func dismiss() {
        // 不恢复亮度（用户调整的亮度应该保持，只在退出阅读页时恢复）
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

extension ReadSettingView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self
    }
}
