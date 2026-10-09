//
//  ToastManager.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import Foundation

class XHToastManager{
    static func makeToast(_ message: String) {
        if message.isEmpty {
            return
        }
        XHToastManager.hideToastActivity()
        keyWindow?.makeToast(message)
    }
    
    static func makeToastActivity() {
        keyWindow?.makeToastActivity()
    }
    
    static func hideToastActivity() {
        keyWindow?.hideToastActivity()
    }
}
