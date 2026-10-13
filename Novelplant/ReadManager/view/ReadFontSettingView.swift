//
//  ReadFontSettingView.swift
//  novelplant
//
//  Created by hehe on 2026/10/13.
//

import UIKit

class ReadFontSettingView: UIView {

    var onConfigChanged: ((ReadFontConfig) -> Void)?
    private let config: ReadFontConfig
    private var debounceTimer: Timer?

    // MARK: - 初始化
    init(config: ReadFontConfig) {
        self.config = config
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
        label.text = "字体设置"
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

    // 字体大小
    private lazy var fontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "字体大小"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textPrimaryColor
        return label
    }()

    private lazy var fontSizeValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .themeColor
        return label
    }()

    private lazy var fontSizeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 12
        slider.maximumValue = 28
        slider.minimumTrackTintColor = .themeColor
        slider.maximumTrackTintColor = UIColor(hex: "#E5E5E5")
        slider.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(fontSizeEditingEnded), for: [.touchUpInside, .touchUpOutside])
        return slider
    }()

    // 行间距
    private lazy var lineSpacingLabel: UILabel = {
        let label = UILabel()
        label.text = "行间距"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textPrimaryColor
        return label
    }()

    private lazy var lineSpacingSegment: UISegmentedControl = {
        let items = ["紧凑", "标准", "宽松"]
        let segment = UISegmentedControl(items: items)
        segment.addTarget(self, action: #selector(lineSpacingChanged), for: .valueChanged)
        return segment
    }()

    // 字体
    private lazy var fontFamilyLabel: UILabel = {
        let label = UILabel()
        label.text = "字体"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textPrimaryColor
        return label
    }()

    private lazy var fontFamilySegment: UISegmentedControl = {
        let items = ["系统", "Merriweather", "Georgia"]
        let segment = UISegmentedControl(items: items)
        segment.addTarget(self, action: #selector(fontFamilyChanged), for: .valueChanged)
        return segment
    }()

    // MARK: - 布局
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(fontSizeLabel)
        containerView.addSubview(fontSizeValueLabel)
        containerView.addSubview(fontSizeSlider)
        containerView.addSubview(lineSpacingLabel)
        containerView.addSubview(lineSpacingSegment)
        containerView.addSubview(fontFamilyLabel)
        containerView.addSubview(fontFamilySegment)

        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(360)
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

        fontSizeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
        }

        fontSizeValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(fontSizeLabel)
        }

        fontSizeSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(fontSizeLabel.snp.bottom).offset(12)
        }

        lineSpacingLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(fontSizeSlider.snp.bottom).offset(28)
        }

        lineSpacingSegment.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(lineSpacingLabel.snp.bottom).offset(12)
            make.height.equalTo(32)
        }

        fontFamilyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(lineSpacingSegment.snp.bottom).offset(28)
        }

        fontFamilySegment.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(fontFamilyLabel.snp.bottom).offset(12)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().offset(-20 - safeAreaBottomSpace)
        }

        // 添加点击手势关闭
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    private func updateUI() {
        fontSizeSlider.value = Float(config.fontSize)
        fontSizeValueLabel.text = "\(Int(config.fontSize))"
        lineSpacingSegment.selectedSegmentIndex = config.lineSpacingLevel
        fontFamilySegment.selectedSegmentIndex = config.fontFamilyLevel
    }

    // MARK: - 事件处理
    @objc private func fontSizeChanged() {
        // 拖动时显示当前值，并启动防抖定时器
        let roundedValue = round(fontSizeSlider.value / 2) * 2
        fontSizeValueLabel.text = "\(Int(roundedValue))"

        // 取消之前的定时器
        debounceTimer?.invalidate()

        // 0.3秒后自动应用（拖动停顿时触发）
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.config.fontSize = CGFloat(roundedValue)
            self.notifyConfigChanged()
        }
    }

    @objc private func fontSizeEditingEnded() {
        // 松手时立即应用（取消定时器，直接触发）
        debounceTimer?.invalidate()

        let roundedValue = round(fontSizeSlider.value / 2) * 2
        fontSizeSlider.value = roundedValue
        config.fontSize = CGFloat(roundedValue)
        fontSizeValueLabel.text = "\(Int(roundedValue))"
        notifyConfigChanged()
    }

    @objc private func lineSpacingChanged() {
        config.lineSpacingLevel = lineSpacingSegment.selectedSegmentIndex
        notifyConfigChanged()
    }

    @objc private func fontFamilyChanged() {
        config.fontFamilyLevel = fontFamilySegment.selectedSegmentIndex
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
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

extension ReadFontSettingView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self
    }
}
