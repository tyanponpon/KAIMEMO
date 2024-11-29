import UIKit

class EmergencyViewController: UIViewController {

    var productDataArray: [[String: Any]] = []
    let buttonSize: CGFloat = 100.0
    let padding: CGFloat = 10.0
    var saveData: UserDefaults = UserDefaults.standard
    var floatingButtons: [UIButton] = []
    var selectedIndex: Int = 0
    // 商品を削除するためのゴミ箱ボタン
    @IBOutlet var trashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タブバーを非表示にする
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProductData()
        createProductButtons()
        // タブバーを表示
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createProductButtons()
    }
    
    func loadProductData() {
        if let savedData = saveData.array(forKey: "array_data") as? [[String: Any]] {
            // フィルタせずに全てのデータを読み込む
            productDataArray = savedData
            print(productDataArray)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailViewController" {
            let next = segue.destination as? DetailViewController
            next?.productData = productDataArray[selectedIndex]
            next?.productIndex = selectedIndex
        }
    }
    
    // 商品データを削除するメソッド
    func removeProductData(productData: [String: Any]) {
        if let index = productDataArray.firstIndex(where: { NSDictionary(dictionary: $0).isEqual(to: productData) }) {
            productDataArray.remove(at: index) // 商品データをリストから削除
            saveData.set(productDataArray, forKey: "array_data") // 削除後のデータを保存
            createProductButtons() // ボタンを再生成
        }
    }
    
    // 削除の確認をするアラートを表示するメソッド
    func confirmDeletion(for productButton: UIButton) {
        let alert = UIAlertController(title: "確認", message: "この商品を削除しますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { _ in
            self.animateImageDrop(to: self.trashButton, productButton: productButton)
            self.removeProductData(productData: self.productDataArray[productButton.tag])
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // ボタンを移動するときのアニメーション
    func animateImageDrop(to button: UIButton, productButton: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            productButton.center = button.center // ボタンの位置を移動
            productButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1) // ボタンを小さくするアニメーション
        }, completion: { _ in
            productButton.removeFromSuperview() // アニメーションが終わったらボタンを画面から削除
        })
    }
    
    func createProductButtons() {
        // 既存のボタンを削除
        for button in floatingButtons {
            button.removeFromSuperview()
        }
        floatingButtons.removeAll()
        
        // ボタンの配置
        let savedButtonPositions = saveData.dictionary(forKey: "emergency_button_positions") as? [String: [String: CGFloat]] ?? [:]
        let safeAreaInsets = view.safeAreaInsets
        let navBarHeight = safeAreaInsets.top
        let tabBarHeight = safeAreaInsets.bottom
        var xOffset: CGFloat = padding
        var yOffset: CGFloat = padding + navBarHeight
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height - navBarHeight - tabBarHeight
        
        for (index, productData) in productDataArray.enumerated() {
            if let currentPage = productData["currentPage"] as? String, currentPage == "EmergencyVC" {
                var productImage: UIImage? = UIImage(named: "placeholder")
                if let imageData = productData["image"] as? Data {
                    productImage = UIImage(data: imageData)
                }
                
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: xOffset, y: yOffset, width: buttonSize, height: buttonSize)
                button.setImage(productImage, for: .normal)
                button.layer.cornerRadius = buttonSize / 2
                button.clipsToBounds = true
                
                // 保存されている位置があれば、ボタンの位置を設定
                if let savedPosition = savedButtonPositions["button_\(index)"], let x = savedPosition["x"], let y = savedPosition["y"] {
                    button.center = CGPoint(x: x, y: y)
                }
                
                addBubbleAnimation(to: button)
                
                button.tag = index
                button.addTarget(self, action: #selector(productButtonTapped(_:)), for: .touchUpInside)
                
                if let stock = productData["stock"] as? Int, stock <= 1 {
                    button.layer.borderColor = UIColor.red.cgColor
                    button.layer.borderWidth = 3.0
                }
                
                if let expiryDate = productData["period"] as? Date {
                    let currentDate = Date()
                    let calendar = Calendar.current
                    if let daysDifference = calendar.dateComponents([.day], from: currentDate, to: expiryDate).day, daysDifference <= 3 || expiryDate < currentDate {
                        button.layer.borderColor = UIColor.red.cgColor
                        button.layer.borderWidth = 3.0
                    }
                }
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                button.addGestureRecognizer(panGesture)
                
                self.view.addSubview(button)
                
                xOffset += buttonSize + padding
                if xOffset + buttonSize > screenWidth {
                    xOffset = padding
                    yOffset += buttonSize + padding
                    if yOffset + buttonSize > screenHeight {
                        break
                    }
                }
                
                floatingButtons.append(button)
                addFloatingAnimation(to: button)
            }
        }
    }


    @objc func productButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        performSegue(withIdentifier: "toDetailViewController", sender: nil)
    }
    
    // ドラッグ＆ドロップで商品を追加する処理
        func addProductToEmergencyView(product: [String: Any]) {
            productDataArray.append(product)
            createProductButtons()  // ボタンを再描画
        }
    func addBubbleAnimation(to button: UIButton) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.9
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 1.5
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = 1.5
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        
        button.layer.add(scaleAnimation, forKey: "scaleAnimation")
        button.layer.add(opacityAnimation, forKey: "opacityAnimation")
    }

    func addFloatingAnimation(to button: UIButton) {
        let floatAnimation = CABasicAnimation(keyPath: "position.y")
        floatAnimation.fromValue = button.center.y - 10
        floatAnimation.toValue = button.center.y + 10
        floatAnimation.duration = 2.0
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        button.layer.add(floatAnimation, forKey: "floatAnimation")
    }

    func stopFloatingAnimation(for button: UIButton) {
        button.layer.removeAnimation(forKey: "floatAnimation")
    }
    
    func restartFloatingAnimation(for button: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.addFloatingAnimation(to: button)
        }
    }
    
    // ボタンの位置を保存するメソッド
    func saveButtonPositions() {
        var buttonPositions: [String: [String: CGFloat]] = [:]
        for button in floatingButtons {
            buttonPositions["button_\(button.tag)"] = ["x": button.center.x, "y": button.center.y]
        }
        saveData.set(buttonPositions, forKey: "emergency_button_positions") // ボタン位置の情報を保存
    }

    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }
        
        let translation = gesture.translation(in: self.view)
        var newCenter = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
        let margin: CGFloat = padding
        let halfWidth = button.frame.width / 2
        let halfHeight = button.frame.height / 2
        newCenter.x = max(halfWidth + margin, min(newCenter.x, self.view.bounds.width - halfWidth - margin))
        newCenter.y = max(halfHeight + margin, min(newCenter.y, self.view.bounds.height - halfHeight - margin))
        button.center = newCenter
        gesture.setTranslation(.zero, in: self.view)
        
        switch gesture.state {
        case .began:
            stopFloatingAnimation(for: button)
        case .ended, .cancelled:
            restartFloatingAnimation(for: button)
            
            // ドラッグが終了した時点でボタンの位置を保存
            saveButtonPositions()
            
            if trashButton.frame.contains(button.center) {
                // ゴミ箱ボタン上にドロップされた場合の削除確認
                confirmDeletion(for: button)
            }
        default:
            break
        }
    }

}
