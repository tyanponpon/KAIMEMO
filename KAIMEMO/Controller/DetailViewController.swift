import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return prefectures.count
    }
    
    // 列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // データを受け取るためのプロパティ
    var productData: [String: Any]?
    var productDataArray: [[String: Any]] = []
    var productIndex: Int = 0  // データのインデックス
    var saveData: UserDefaults = UserDefaults.standard
    var count = 0
    var isLike: Bool!
    
    
    // UIの接続
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var brandLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var capacityTextField: UITextField!
    @IBOutlet var stockLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var dataPicker: UIDatePicker!
    @IBOutlet var unitPicker: UIPickerView!
    @IBOutlet var openURLButton: UIButton!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var scrollView: UIScrollView! // スクロールビューを追加
    
    private var preSelectedLb: UILabel!
    private let prefectures: [String] = ["ml", "L", "mg", "g", "kg", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        setDismissKeyboard()
        
        // 受け取ったデータを表示する
        if let productData = productData {
            if let imageData = productData["image"] as? Data {
                productImageView.image = UIImage(data: imageData)
            } else {
                productImageView.image = UIImage(named: "grayimage")
            }
            productNameLabel.text = productData["name"] as? String
            brandLabel.text = productData["brand"] as? String
            capacityTextField.text = productData["capacity"] as? String
            commentTextView.text = productData["comment"] as? String
            priceTextField.text = productData["price"] as? String
            stockLabel.text = "\(productData["stock"] ?? 0)"
            createdAtLabel.text = productData["createdAt"] as? String
            isLike = (productData["favorite"] as? Bool)!
            if isLike == true {
                heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            
            if let period = productData["period"] as? Date {
                dataPicker.date = period
            }
            
            // 単位をピッカーで選択させる
            if let unit = productData["unit"] as? String, let index = prefectures.firstIndex(of: unit) {
                unitPicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
        // 枠を角丸にする
        commentTextView.layer.cornerRadius = 20.0
        commentTextView.layer.masksToBounds = true
        
        // 登録ボタンのスタイルを設定
        setupRegisterButtonStyle()
    }
    
    // pickerに表示するUIViewを返す
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = prefectures[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font: UIFont(name: "HiraKakuProN-W3", size: 20.0)!, NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        // fontサイズ、テキスト
        pickerLabel.attributedText = myTitle
        // 中央寄せ
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        
        // ラベルを角丸に
        pickerLabel.layer.masksToBounds = true
        pickerLabel.layer.cornerRadius = 5.0
        
        return pickerLabel
    }
    
    func setupRegisterButtonStyle() {
        // ボタンのテキストスタイル
        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: "更新する", attributes: attributes)
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
        
        // ボタンを丸く
        registerButton.layer.cornerRadius = 25
        registerButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // 商品情報を編集・削除するためのメソッド
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        guard var updatedData = productData else { return }
        
        updatedData["name"] = productNameLabel.text
        updatedData["brand"] = brandLabel.text
        updatedData["capacity"] = capacityTextField.text
        let selectedUnitIndex = unitPicker.selectedRow(inComponent: 0)
        updatedData["unit"] = prefectures[selectedUnitIndex]
        updatedData["comment"] = commentTextView.text
        updatedData["price"] = priceTextField.text
        updatedData["stock"] = Int(stockLabel.text ?? "0")
        updatedData["period"] = dataPicker.date // ストック情報を更新
        updatedData["favorite"] = isLike
        
        // UserDefaultsから保存されたデータを取得
        if let savedData = saveData.array(forKey: "productData") as? [[String: Any]] {
            productDataArray = savedData
        }
        
        // 在庫が0のとき削除確認のアラートを表示
        if let stockValue = updatedData["stock"] as? Int, stockValue == 0 {
            let alert = UIAlertController(title: "削除確認", message: "在庫が0です。商品情報を削除しますか？", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { _ in
                // 商品情報を削除
                self.productDataArray.remove(at: self.productIndex)
                self.saveData.set(self.productDataArray, forKey: "productData")
                self.navigationController?.popToRootViewController(animated: true)
            }
            let keepAction = UIAlertAction(title: "そのまま残す", style: .default) { _ in
                // 在庫が0のまま商品を保存
                self.productDataArray[self.productIndex] = updatedData
                self.saveData.set(self.productDataArray, forKey: "productData")
                
                let alert = UIAlertController(title: "編集完了", message: "商品情報を保存しました。", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            alert.addAction(deleteAction)
            alert.addAction(keepAction)
            present(alert, animated: true, completion: nil)
        } else {
            // 在庫がある場合、データを更新して保存
            productDataArray[self.productIndex] = updatedData
            saveData.set(productDataArray, forKey: "productData")
            
            let alert = UIAlertController(title: "編集完了", message: "商品情報を保存しました。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapHeartButton() {
        if isLike == true {
            isLike = false
            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            isLike = true
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        
    }
   
    @IBAction func openURLTapped(_ sender: Any) {
        guard let url = URL(string: productData!["url"] as! String) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func tapPlusButton() {
        count += 1
        stockLabel.text = String(count)
    }
    
    @IBAction func tapMinusButton() {
        count -= 1
        if count < 0 {
            count = 0 // 0以下の数字は全て0にする
        }
        stockLabel.text = String(count)
    }
}
