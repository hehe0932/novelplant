//
//  MeViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import UIKit

class MeViewController: BaseViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.tableHeaderView = header
        return tableView
    }()
    
    private lazy var header: MeHeaderView = {
        let header = MeHeaderView(frame: CGRect(x: 0, y: 0, width: screenW, height: 300))
        header.backgroundColor = .white
        
        return header
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        hiddenNavigationBar = true
        view.addSubview(tableView)
    }

}


extension MeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.textLabel?.text = "asasd"
        return cell
        
    }
    
    
}
