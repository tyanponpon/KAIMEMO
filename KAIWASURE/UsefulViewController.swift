//
//  UsefulViewController.swift
//  KAIWASURE
//
//  Created by 藤崎花音 on 2022/11/11.
//

import UIKit

class UsefulViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var cameraImageView: UIImageView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    var array = [[String: Any]]()
    var saveData: UserDefaults = UserDefaults.standard
    var  originalImage: UIImage!
    
    //let dataList = ["文房具","食料","洋服","本","台所","お風呂","トイレ","グッズ","おつかい","その他"]
    var dataList = [String]()
    var serectItem: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        array = saveData.object(forKey: "array_data") as! [[String: Any]]
        dataList = saveData.object(forKey: "category") as! [String]
        // Do any additional setup after loading the view.
        pickerView.delegate = self
        pickerView.dataSource = self
        label.text = "買いたいもの"
        //データリストの中にデータがあれば
        if dataList.count > 0 {
            serectItem = dataList[0]
        }
       
        textField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
             textField.becomeFirstResponder()
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
        
        label.text = dataList[row]
        serectItem = dataList[row]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        textField.text = textField.text
        return true
    }
    
    
    @IBAction func addItem() {
        if (originalImage == nil){
            originalImage = UIImage(named: "grayimage")
        }
        let data: [String: Any] = [
            "item": textField.text as Any,
            "category": serectItem as Any,
            "image": originalImage.pngData() as NSData? as Any
        ]
        array.append(data)
        saveData.set(array, forKey: "array_data")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        } else {
            print("error")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cameraImageView.image = info[.editedImage] as? UIImage
        originalImage = cameraImageView.image
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func savePhoto() {
        UIImageWriteToSavedPhotosAlbum(cameraImageView.image!, nil, nil, nil)
        let alert: UIAlertController = UIAlertController(title: "保存", message: "写真を保存しました。", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "OK",
                          style: .default
                          )
        )
        present(alert,animated: true,completion: nil)
    }
    
    
    
}
