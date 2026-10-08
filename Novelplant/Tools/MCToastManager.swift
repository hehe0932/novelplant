//
//  ToastManager.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
import UIKit

class MCToastManager {
    
    static func makeToast(_ message: String) {
        if message.isEmpty {
            return
        }
        MCToastManager.hideToastActivity()
        keyWindow?.makeToast(message)
    }
    
    static func makeToastActivity() {
        keyWindow?.makeToastActivity()
    }
    
    static func hideToastActivity() {
        keyWindow?.hideToastActivity()
    }
    
    
}
