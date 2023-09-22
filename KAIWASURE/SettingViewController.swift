//
//  SettingViewController.swift
//  KAIWASURE
//
//  Created by 藤崎花音 on 2023/06/09.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDataSource {
    
    var categoryArray = [String]()
    var saveData: UserDefaults = UserDefaults.standard
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingTableViewCell")
        saveData.set(categoryArray, forKey: "category")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryArray = saveData.object(forKey: "category") as! [String]
        tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.setCategoryLabel.text = categoryArray[indexPath.row]
        return cell
    }
    
    
}
