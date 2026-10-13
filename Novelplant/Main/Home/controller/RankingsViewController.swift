//
//  RankingsViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/10.
//  排行榜

import UIKit

class RankingsViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension RankingsViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        view
    }
}
