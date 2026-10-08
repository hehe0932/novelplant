//
//  Extension+MJRefresh.swift
//  Moyi
//
//  Created by hehehe on 2023/7/12.
//

import Foundation

extension MJRefreshNormalHeader {
    open override func prepare() {
        super.prepare()
        
    }
}


extension MJRefreshAutoNormalFooter {
    open override func prepare() {
        super.prepare()
        stateLabel?.isHidden = true
    }
}
