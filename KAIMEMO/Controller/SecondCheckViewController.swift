import UIKit

class SecondCheckViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var productTextField: UITextField!
    @IBOutlet var brandTextField: UITextField!
    @IBOutlet var capacityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var dataPicker: UIDatePicker!
    @IBOutlet var storeTextField: UITextField!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var unitPicker: UIPickerView!
    @IBOutlet var scrollView: UIScrollView!
    
    private let units = ["ml", "L", "mg", "g", "kg", ""]
    private var selectedUnit: String = ""
    
    var productDataArray = [[String: Any]]()
    var saveData: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        // UserDefaultsから保存した画像を取得して表示
        if let imageData = UserDefaults.standard.data(forKey: "capturedPhoto"),
           let image = UIImage(data: imageData) {
            productImageView.image = image
        } else {
            productImageView.image = UIImage(named: "defaultImage") // 画像がない場合のデフォルト画像
        }
        
        dataPicker.datePickerMode = .date
        commentTextView.delegate = self
        setDismissKeyboard()
        setupRegisterButtonStyle()
    }
    
    // Segueを使用して別の画面に移動する前にデータを準備する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondCheckView" {
            // 商品の詳細画面に選択した商品データを渡す
            _ = segue.destination as? NewCameraViewController
            
        }
    }
    
    
    
    // PickerViewの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // PickerViewの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return units.count
    }
    
    // Pickerの各行のビュー
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = units[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        pickerLabel.layer.masksToBounds = true
        pickerLabel.layer.cornerRadius = 5.0
        return pickerLabel
    }
    
    // Pickerの項目が選択された時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnit = units[row]
    }
    
    // 登録ボタンのスタイルを設定
    func setupRegisterButtonStyle() {
        registerButton.layer.cornerRadius = 25
        registerButton.clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.3, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = registerButton.bounds
        registerButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func registerProduct() {
        var productImage: UIImage! = productImageView.image ?? UIImage(named: "defaultImage")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        // 商品データに選択した情報を保存
        let data: [String: Any] = [
            "name": productTextField.text ?? "",
            "brand": brandTextField.text ?? "",
            "capacity": capacityTextField.text ?? "",
            "unit": selectedUnit,
            "price": priceTextField.text ?? "",
            "expirationDate": dataPicker.date,
            "stock": countLabel.text ?? "",
            "store": storeTextField.text ?? "",
            "comment": commentTextView.text ?? "",
            "image": productImage.pngData() ?? Data()
        ]
        
        // 保存されたデータを取得し、新しいデータを追加して保存
        if let savedData = saveData.array(forKey: "productData") as? [[String: Any]] {
            productDataArray = savedData
        }
        productDataArray.append(data)
        saveData.set(productDataArray, forKey: "productData")
        
        // アラートの表示
        let alert = UIAlertController(title: "登録", message: "商品情報を登録しました。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

