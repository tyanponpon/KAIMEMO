import UIKit

class DataViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var productLabel: UILabel!
    @IBOutlet var brandLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet weak private var textViewButtonConstraint: NSLayoutConstraint!
    @IBOutlet var dataPicker: UIDatePicker!  // DatePickerに変更
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var capacityTextField: UITextField!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var openURLButton: UIButton!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var markImageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView! // スクロールビューを追加
    @IBOutlet var unitPicker: UIPickerView!
    
    
    private var preSelectedLb: UILabel!
    private let prefectures: NSArray = ["ml", "L", "mg", "g", "kg", ""]
    
    
    var productDataArray = [[String: Any]]()
    var saveData: UserDefaults = UserDefaults.standard
    var selectedProduct: Product!
    var selectedProductImage: UIImage!
    var count = 1
    var selectedUnit: String = "" // 単位を保持する変数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        // 初期値0を表示
        countLabel.text = String(count)
        
        // スクロールビューの背景を透明に設定
        scrollView.backgroundColor = .clear
        
        productImageView.image = selectedProductImage
        productLabel.text = selectedProduct.name
        brandLabel.text = selectedProduct.brand.name
        openURLButton.userActivity?.webpageURL = selectedProduct.url
        commentTextView.delegate = self
        // キーボードを非表示にする
        //        setDismissKeyboard()
        
        // URLラベルにタップジェスチャーを設定
        //        setupUrlLabelGesture()
        
        // DatePickerの設定
        dataPicker.datePickerMode = .date
        
        // 枠を角丸にする
        commentTextView.layer.cornerRadius = 20.0
        commentTextView.layer.masksToBounds = true
        
        // 登録ボタンのスタイルを設定
        setupRegisterButtonStyle()
    }
    
    // 列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return prefectures.count
    }
    
    // Pickerの各行のビュー
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = prefectures[row] as! String
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font: UIFont(name: "HiraKakuProN-W3", size: 20.0)!, NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        
        pickerLabel.layer.masksToBounds = true
        pickerLabel.layer.cornerRadius = 5.0
        
        return pickerLabel
    }
    
    // Pickerの項目が選択された時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnit = prefectures[row] as! String
        print("選択された単位: \(selectedUnit)") // 選択されたデータを取得
    }
    
    // 登録ボタンのスタイルを設定
    func setupRegisterButtonStyle() {
        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: "買いメモする", attributes: attributes)
        registerButton.setAttributedTitle(attributedTitle, for: .normal)
        
        // ボタンの背景を紺色のグラデーションに設定
        let buttonGradientLayer = CAGradientLayer()
        buttonGradientLayer.colors = [
            UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0).cgColor,  // 紺色
            UIColor(red: 0.0, green: 0.0, blue: 0.3, alpha: 1.0).cgColor   // 濃い紺色
        ]
        buttonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        buttonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        buttonGradientLayer.frame = registerButton.bounds
        buttonGradientLayer.cornerRadius = 25
        registerButton.layer.insertSublayer(buttonGradientLayer, at: 0)
        
        registerButton.layer.cornerRadius = 25
        registerButton.clipsToBounds = true
    }
    
    func favoritetapped(isMarked: Bool){
        if isMarked{
            markImageView.image = UIImage(systemName: "heart.fill")
        } else {
            markImageView.image = UIImage(systemName: "heart")
        }
    }
    
    
    @IBAction func addProduct() {
        var productImage: UIImage!
        if productImageView.image == nil {
            productImage = UIImage(named: "grayimage")
        } else {
            productImage = productImageView.image
        }
        
        // 今日の日付を取得してフォーマット
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd" // ←ここをいじると表示形式が変わる
        let currentDateString = dateFormatter.string(from: Date())
        let selectedDate = dataPicker.date
        
        // 商品データに選択した単位を含めて保存
        let data: [String: Any] = [
            "name": productLabel.text as Any,
            "image": productImage.pngData() as NSData? as Any,
            "brand": brandLabel.text as Any,
            "capacity": capacityTextField.text as Any,
            "unit": selectedUnit,  // 単位を保存
            "comment": commentTextView.text as Any,
            "price": priceTextField.text as Any,
            "period": selectedDate,
            "stock": count as Any,
            "url": selectedProduct.url?.description as String? as Any,
          //  "favorite": favoritetapped(isMarked: Bool) as! String? as Any,
            "currentPage": "HomeVC" as Any,
            "createdAt": currentDateString
        ]
        
        // 保存されたデータをUserDefaultsから取得
        if let savedData = saveData.array(forKey: "productData") as? [[String: Any]] {
            productDataArray = savedData
        }
        productDataArray.append(data)
        saveData.set(productDataArray, forKey: "productData")
        
        // アラートの表示
        let alert = UIAlertController(title: "登録", message: "商品情報を登録しました。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapPlusButton() {
        count += 1
        countLabel.text = String(count)
    }
    
    @IBAction func tapMinusButton() {
        count -= 1
        if count < 0 {
            count = 0 // 0以下の数字は全て0にする
        }
        countLabel.text = String(count)
    }
    
    @IBAction func openURLTapped(_ sender: Any) {
        guard let url = URL(string: selectedProduct.url!.description) else { return }
        UIApplication.shared.open(url)
    }
}


