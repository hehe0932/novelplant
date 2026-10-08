//
//  CustomJXPagingMainTableView.swift
//  Moyi
//
//  Created by hehe on 2024/4/10.
//

import Foundation

class CustomJXPagingMainTableView: JXPagingMainTableView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 如果这个视图不响应事件或者点击在子视图之外，则返回nil让事件透传
        if !isUserInteractionEnabled || self.subviews.contains(where: { $0.hitTest(convert(point, to: $0), with: event) != nil }) {
            return nil
        }
        return super.hitTest(point, with: event)
    }
}
