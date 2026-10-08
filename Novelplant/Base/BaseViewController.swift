//
//  BaseViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/8.
//

import UIKit

class BaseViewController: UIViewController {

    var hiddenNavigationBar = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(hiddenNavigationBar, animated: true)
    }
    
    override var modalPresentationStyle: UIModalPresentationStyle {
        set {
            super.modalPresentationStyle = newValue
        }
        get {
            return .overFullScreen
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    func hideBackBtn() {
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
        
        var name =  type(of: self).description()
        if(name.contains(".")){
          name =  name.components(separatedBy: ".")[1];
          print("释放控制器 -> \(name) Running  func \(#function)")
        }else{
          print("释放控制器 -> \(name) Running  func \(#function)")
        }
    }


}
