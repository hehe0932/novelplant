//
//  BaseTabbarViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import UIKit

class BaseTabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        addChildVC()
        
    }

    private func setupViews() {
        setValue(BaseTabbar(), forKey: "tabBar")

    }
    
    private func addChildVC() {

        addChildController(title: NSLocalizedString("Home", comment: ""), controller: HomeViewController(), imageName: "house", selectedImageName: "house.fill")

        addChildController(title: NSLocalizedString("Library", comment: ""), controller: LibraryViewController(), imageName: "books.vertical", selectedImageName: "books.vertical.fill")
        
        addChildController(title: NSLocalizedString("Me", comment: ""), controller: MeViewController(), imageName: "person", selectedImageName: "person.fill")
    }
    
    private func addChildController(title: String, controller: UIViewController, imageName: String, selectedImageName: String)  {
        
        controller.title = title
        controller.tabBarItem.image = UIImage(named: imageName) ?? UIImage(systemName: imageName)
        controller.tabBarItem.selectedImage = UIImage(named: selectedImageName) ?? UIImage(systemName: selectedImageName)
        
        let nav = BaseNavigationController(rootViewController: controller)
        
        addChild(nav)
        
    }

}
