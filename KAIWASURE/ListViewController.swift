//
//  ListViewController.swift
//  KAIWASURE
//
//  Created by 藤崎花音 on 2022/11/11.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet var addButton: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var array = [[String: Any]]()
    var saveData: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.layer.cornerRadius = 35
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        array = []
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItems = [editButtonItem]
        //UserDefaultsに名前を登録するために空のデータを保存する
        if (saveData.object(forKey: "array_data") == nil){
            saveData.set(array, forKey: "array_data")
            saveData.set(array, forKey: "category")
        }
        //カスタムを使えるようにしている
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        array = saveData.object(forKey: "array_data") as! [[String: Any]]
        tableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    //Cellの表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MainTableViewCell
        cell.categorylabel.text = array[indexPath.row]["category"] as? String
        cell.itemlabel.text = array[indexPath.row]["item"] as? String
        cell.itemImageView.image = UIImage(data: (array[indexPath.row]["image"] as! NSData) as Data)
        cell.selectionStyle = .none
        return cell
    }
    //Cellの編集をできるようにするコード
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let array_item = array[sourceIndexPath.row]
        array.remove(at: sourceIndexPath.row)
        array.insert(array_item, at: destinationIndexPath.row)
        saveData.set(array, forKey: "array_data")
    }
    // Cellを移動できるようにするコード
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            array.remove(at: indexPath.row)
            saveData.set(array, forKey: "array_data")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing == true {
            return .delete
        } else {
            return .none
        }
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let cell = tableView.cellForRow(at: indexPath)
    //        if(cell?.accessoryType == UITableViewCell.AccessoryType.none){
    //            //セルにチェックマークをつける
    //            cell?.accessoryType = .checkmark
    //        }else{
    //            //セルのチェックマークを消す
    //            cell?.accessoryType = .none
    //        }
    //       // cell?.backgroundColor = UIColor(red: 0.98, green: 0.56, blue: 0.58, alpha: 1.0)
    //        tableView.deselectRow(at: indexPath, animated: true)
    //    }
    
    //エンターを押した時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        if let keyword = searchBar.text {
            if keyword.isEmpty {
                //キーワードが空だから、全データをanimalに代入する
                array = saveData.object(forKey: "array_data") as! [[String: Any]]
            } else {
                //取得したデータから、キーワードに合致するものをanimalに代入する
                array = array.filter{ (str) -> Bool in
                    let itemName = str["item"] as! String
                    let categoryName = str["category"] as! String
                    print(itemName)
                    print(categoryName)
                    return itemName.lowercased().contains(keyword.lowercased()) ||
                        categoryName.lowercased().contains(keyword.lowercased())

                    
                
                    // $0["item"].lowercased().contains(keyword.lowercased())
                    
                }
            }
            tableView.reloadData()
        }
    }
    
    

    //検索バーが変わった時
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let keyword = searchBar.text {
            if keyword.isEmpty {
                //キーワードが空だから、全データをarray_dataに代入する
                array = saveData.object(forKey: "array_data") as! [[String: Any]]
            } else {
                //取得したデータから、キーワードに合致するものをanimalに代入する
                array = array.filter{ (str) -> Bool in
                    let itemName = str["item"] as! String
                    let categoryName = str["category"] as! String
                    print(itemName)
                    print(categoryName)
                    return itemName.lowercased().contains(keyword.lowercased()) ||
                        categoryName.lowercased().contains(keyword.lowercased())

                    // $0["item"].lowercased().contains(keyword.lowercased())
                    
                }
            }
            tableView.reloadData()
        }
        
    }
    
    
    //タップして詳細画面に移動する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetailSegue", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //詳細画面の表示
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? DataViewController else {
                    fatalError("Failed to prepare DetailViewController.")
                }
                
                destination.detailArray = array[indexPath.row]
            }
        }
    }
    
    }


