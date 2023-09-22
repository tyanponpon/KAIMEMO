//
//  NeViewController.swift
//  KAIWASURE
//
//  Created by 藤崎花音 on 2022/12/16.
//

import UIKit

class AddCategoryViewController: UIViewController {

    var saveData: UserDefaults = UserDefaults.standard
    var categoryArray = [String]()
    @IBOutlet var categoryTextField : UITextField!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryArray = saveData.object(forKey: "category") as! [String]

    }
    
    override func viewWillAppear(_ animated: Bool) {
             categoryTextField.becomeFirstResponder()
        }

    @IBAction func addItem() {
        categoryArray.append(categoryTextField.text!)
        saveData.set(categoryArray, forKey: "category")
        print(categoryArray)
        self.navigationController?.popViewController(animated: true)
       
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }

}
