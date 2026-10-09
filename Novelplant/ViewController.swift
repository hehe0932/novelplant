//
//  ViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/8.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 100, height: 100));
        label.textColor = .black
        label.text = NSLocalizedString("asd", comment: "asd");
        view.addSubview(label)
    }


}

