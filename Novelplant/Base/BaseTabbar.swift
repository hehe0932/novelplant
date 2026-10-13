//
//  BaseTabbar.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import UIKit

class BaseTabbar: UITabBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        tintColor = .themeColor
        unselectedItemTintColor = .textSecondaryColor
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
