//
//  BatteryView.swift
//  novelplant
//
//  Created by hehe on 2026/10/13.
//

import UIKit

/// 电池电量显示视图（仿系统样式）
class BatteryView: UIView {

    private lazy var batteryOutlineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 1
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()

    private lazy var batteryFillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()

    private lazy var batteryCapLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        updateBatteryLevel()

        // 监听电量变化
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupLayers() {
        layer.addSublayer(batteryOutlineLayer)
        layer.addSublayer(batteryFillLayer)
        layer.addSublayer(batteryCapLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBatteryPath()
    }

    private func updateBatteryPath() {
        let bodyWidth: CGFloat = bounds.width - 3
        let bodyHeight: CGFloat = bounds.height
        let capWidth: CGFloat = 2
        let capHeight: CGFloat = bodyHeight * 0.4
        let cornerRadius: CGFloat = 2

        // 电池外框
        let outlinePath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: bodyWidth, height: bodyHeight),
            cornerRadius: cornerRadius
        )
        batteryOutlineLayer.path = outlinePath.cgPath

        // 电池帽
        let capPath = UIBezierPath(
            roundedRect: CGRect(
                x: bodyWidth + 1,
                y: (bodyHeight - capHeight) / 2,
                width: capWidth,
                height: capHeight
            ),
            cornerRadius: 1
        )
        batteryCapLayer.path = capPath.cgPath

        updateBatteryLevel()
    }

    @objc private func batteryLevelDidChange() {
        updateBatteryLevel()
    }

    @objc private func batteryStateDidChange() {
        updateBatteryLevel()
    }

    private func updateBatteryLevel() {
        let level = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState

        guard level >= 0 else {
            // 无法获取电量（模拟器）
            batteryOutlineLayer.strokeColor = UIColor.textTertiaryColor.cgColor
            batteryFillLayer.fillColor = UIColor.clear.cgColor
            batteryCapLayer.fillColor = UIColor.textTertiaryColor.cgColor
            return
        }

        let bodyWidth: CGFloat = bounds.width - 3
        let bodyHeight: CGFloat = bounds.height
        let fillInset: CGFloat = 2
        let fillWidth = (bodyWidth - fillInset * 2) * CGFloat(level)

        // 电量填充
        let fillPath = UIBezierPath(
            roundedRect: CGRect(
                x: fillInset,
                y: fillInset,
                width: fillWidth,
                height: bodyHeight - fillInset * 2
            ),
            cornerRadius: 1
        )
        batteryFillLayer.path = fillPath.cgPath

        // 根据电量和充电状态设置颜色
        let fillColor: UIColor
        if state == .charging || state == .full {
            fillColor = .systemGreen
        } else if level < 0.2 {
            fillColor = .systemRed
        } else {
            fillColor = .textSecondaryColor
        }

        batteryOutlineLayer.strokeColor = fillColor.cgColor
        batteryFillLayer.fillColor = fillColor.cgColor
        batteryCapLayer.fillColor = fillColor.cgColor
    }

    func themeChange() {
        updateBatteryLevel()
    }
}
