import UIKit

class HomeViewController: UIViewController {
    
    // 保存された商品データを管理する配列
    var productDataArray: [[String: Any]] = []
    var saveData: UserDefaults = UserDefaults.standard // データを保存するための UserDefaults インスタンス
    
    // ボタンのサイズとボタン同士の間隔
    let buttonSize: CGFloat = 100.0
    let padding: CGFloat = 10.0
    
    // 画面上で浮遊するボタンのリスト
    var floatingButtons: [UIButton] = []
    
    // 現在選択されている商品ボタンのインデックス
    var selectedIndex: Int = 0
    
    // キッチンと緊急キットと新規追加用のボタン
    var kitchenButton: UIButton!
    var emergencyButton: UIButton!
    var plusButton: UIButton!
    
    // 商品を削除するためのゴミ箱ボタン
    @IBOutlet var trashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タブバーの高さを取得
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        
        // 背景にグラデーションを設定
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.94, blue: 0.7, alpha: 1.0).cgColor,  // パステルイエロー
            UIColor(red: 0.7, green: 1.0, blue: 0.7, alpha: 1.0).cgColor    // パステルグリーン
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // グラデーションのフレームをタブバーの高さを引いたサイズにする
        let gradientFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - tabBarHeight)
        gradientLayer.frame = gradientFrame
        
        // すでにグラデーションレイヤーが存在する場合、重複を避けるため削除
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        // グラデーションレイヤーをビューに追加
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // プラスボタンを生成してビューに追加
        plusButton = UIButton(type: .system)
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        plusButton.frame = CGRect(x: view.frame.width - 70, y: view.frame.height - tabBarHeight - 70, width: 60, height: 60)
        plusButton.backgroundColor = .blue
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.layer.cornerRadius = 30
        view.addSubview(plusButton)
        
        
        // plusButtonにアクションを追加
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        setupButtons()
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProductData() // 保存された商品データを読み込む
        createProductButtons() // 読み込んだ商品データからボタンを作成
        self.tabBarController?.tabBar.isHidden = false // タブバーを表示
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createProductButtons() // 画面のレイアウトが変わったときに商品ボタンを再描画
    }
    
    // 次の画面に移動する前にデータを準備する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailViewController" {
            // 商品の詳細画面に選択した商品データを渡す
            let next = segue.destination as? DetailViewController
            next?.productData = productDataArray[selectedIndex]
            next?.productIndex = selectedIndex
        } else if let identifier = segue.identifier {
            // キッチンビューまたは緊急キットビューにデータを渡す
            if identifier == "toKitchenView" {
                let destination = segue.destination as? KitchenViewController
                destination?.productDataArray = productDataArray
            } else if identifier == "toEmergencyView" {
                let destination = segue.destination as? EmergencyViewController
                destination?.productDataArray = productDataArray
            }
        }
    }
    
    // 特定のTabBarで切り替えた画面に遷移
        func switchToTabBar(at index: Int) {
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = index
            }
        }
    
    // 保存されたデータを読み込むメソッド
    func loadProductData() {
        if let savedData = saveData.array(forKey: "array_data") as? [[String: Any]] {
            // 保存されている全ての商品データを読み込む
            productDataArray = savedData
            print(productDataArray) // データが正しく読み込まれたか確認のために表示
        }
    }
    
    func setupButtons() {
        // タブバーの高さを取得
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
        
        // ボタンの共通設定
        let buttonSize: CGFloat = 100
        let buttonCornerRadius: CGFloat = buttonSize / 2
        let yOffset = self.view.frame.height - tabBarHeight - 150
        
        // キッチン用ボタン
        kitchenButton = UIButton(type: .system)
        kitchenButton.frame = CGRect(x: 50, y: yOffset, width: buttonSize, height: buttonSize)
        kitchenButton.configuration = createButtonConfiguration(imageName: "onigiriIcon", title: "食品", backgroundColor: UIColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 1.0))
        kitchenButton.layer.cornerRadius = buttonCornerRadius
        kitchenButton.clipsToBounds = true
        kitchenButton.addTarget(self, action: #selector(kitchenButtonTapped), for: .touchUpInside)
        self.view.addSubview(kitchenButton)
        
        // 緊急キット用ボタン
        emergencyButton = UIButton(type: .system)
        emergencyButton.frame = CGRect(x: self.view.frame.width - 150, y: yOffset, width: buttonSize, height: buttonSize)
        emergencyButton.configuration = createButtonConfiguration(imageName: "baketuIcon", title: "日用品", backgroundColor: UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0))
        emergencyButton.layer.cornerRadius = buttonCornerRadius
        emergencyButton.clipsToBounds = true
        emergencyButton.addTarget(self, action: #selector(emergencyButtonTapped), for: .touchUpInside)
        self.view.addSubview(emergencyButton)
    }
    
    
    // ボタンの設定を生成するヘルパーメソッド
    private func createButtonConfiguration(imageName: String, title: String, backgroundColor: UIColor) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(named: imageName)
        configuration.imagePlacement = .top // 画像を上部に配置
        configuration.imagePadding = 0 // 画像とテキストの間に余白を設定
        configuration.title = title
        configuration.baseForegroundColor = .black // テキストの色
        configuration.baseBackgroundColor = backgroundColor // 背景色を設定
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        return configuration
    }
    
    // キッチンボタンをタップしたときの処理
    @objc func kitchenButtonTapped() {
        performSegue(withIdentifier: "toKitchenView", sender: self) // キッチン画面に移動
    }
    
    // 緊急キットボタンをタップしたときの処理
    @objc func emergencyButtonTapped() {
        performSegue(withIdentifier: "toEmergencyView", sender: self) // 緊急キット画面に移動
    }
    
    // plusButtonがタップされたときの処理
    @objc func plusButtonTapped() {
        // Storyboard上で"toNewCameraView"というIDのSegueを作成しておく
        performSegue(withIdentifier: "toNewCameraView", sender: self)
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
    
    
    // 商品データを別のビューに登録するメソッド
    func registerProductToView(productData: [String: Any], forView view: String) {
        switch view {
        case "kitchenView":
            let kitchenViewController = KitchenViewController()
            kitchenViewController.addProductToKitchenView(product: productData)
        case "emergencyView":
            let emergencyViewController = EmergencyViewController()
            emergencyViewController.addProductToEmergencyView(product: productData)
        default:
            break
        }
        
        // 商品が別のビューに移動された後、データを再読み込み
        loadProductData()
    }
    
    // 商品データを削除するメソッド
    func removeProductData(productData: [String: Any]) {
        if let index = productDataArray.firstIndex(where: { NSDictionary(dictionary: $0).isEqual(to: productData) }) {
            // 商品データをリストから削除
            productDataArray.remove(at: index)
            
            // 保存されているボタンの位置データを更新
            var buttonPositions = saveData.dictionary(forKey: "kitchen_button_positions") as? [String: [String: CGFloat]] ?? [:]
            buttonPositions.removeValue(forKey: "button_\(index)") // 削除されたボタンの位置を削除
            
            // インデックスの変更に対応するため、他のボタンのキーを更新
            var updatedButtonPositions: [String: [String: CGFloat]] = [:]
            for (key, value) in buttonPositions {
                if let buttonIndex = Int(key.replacingOccurrences(of: "button_", with: "")), buttonIndex > index {
                    // 削除されたボタン以降のキーを1つ前にずらす
                    updatedButtonPositions["button_\(buttonIndex - 1)"] = value
                } else {
                    updatedButtonPositions[key] = value
                }
            }
            
            // 更新された位置データを保存
            saveData.set(updatedButtonPositions, forKey: "kitchen_button_positions")
            
            // 削除後のデータを保存
            saveData.set(productDataArray, forKey: "array_data")
            
            // ボタンを再生成
            createProductButtons()
        }
    }
    
    // 商品データからボタンを生成するメソッド
    func createProductButtons() {
        // 既存のボタンを削除して再生成する
        for button in floatingButtons {
            button.removeFromSuperview()
        }
        floatingButtons.removeAll()
        
        // 保存されているボタンの位置を取得
        let savedButtonPositions = saveData.dictionary(forKey: "button_positions") as? [String: [String: CGFloat]] ?? [:]
        let safeAreaInsets = view.safeAreaInsets
        let navBarHeight = safeAreaInsets.top
        let tabBarHeight = safeAreaInsets.bottom
        var xOffset: CGFloat = padding
        var yOffset: CGFloat = padding + navBarHeight
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height - navBarHeight - tabBarHeight
        
        for (index, productData) in productDataArray.enumerated() {
            if let currentPage = productData["currentPage"] as? String, currentPage == "HomeVC" {
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
    
    // 商品ボタンがタップされたときの処理
    @objc func productButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        performSegue(withIdentifier: "toDetailViewController", sender: nil) // 詳細画面に移動
    }
    
    // ボタンにバブルアニメーションを追加するメソッド
    func addBubbleAnimation(to button: UIButton) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.9 // 小さくするサイズ
        scaleAnimation.toValue = 1.1 // 大きくするサイズ
        scaleAnimation.duration = 1.5 // アニメーションの時間
        scaleAnimation.autoreverses = true // 元のサイズに戻るようにする
        scaleAnimation.repeatCount = .infinity // アニメーションを無限に繰り返す
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8 // 透明度の最小値
        opacityAnimation.toValue = 1.0 // 透明度の最大値
        opacityAnimation.duration = 1.5
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        
        button.layer.add(scaleAnimation, forKey: "scaleAnimation")
        button.layer.add(opacityAnimation, forKey: "opacityAnimation")
    }
    
    // ボタンに浮遊するアニメーションを追加するメソッド
    func addFloatingAnimation(to button: UIButton) {
        let floatAnimation = CABasicAnimation(keyPath: "position.y")
        floatAnimation.fromValue = button.center.y - 10 // 浮かび上がる高さ
        floatAnimation.toValue = button.center.y + 10 // 下がる高さ
        floatAnimation.duration = 2.0 // アニメーションの時間
        floatAnimation.autoreverses = true // アニメーションを逆にする
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 滑らかな動きにする
        button.layer.add(floatAnimation, forKey: "floatAnimation")
    }
    
    // 浮遊アニメーションを停止するメソッド
    func stopFloatingAnimation(for button: UIButton) {
        button.layer.removeAnimation(forKey: "floatAnimation") // 浮遊アニメーションを取り除く
    }
    
    // 浮遊アニメーションを再開するメソッド
    func restartFloatingAnimation(for button: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.addFloatingAnimation(to: button) // 0.5秒後にアニメーションを再開
        }
    }
    
    // ボタンの位置を保存するメソッド
    func saveButtonPositions() {
        var buttonPositions: [String: CGPoint] = [:]
        for button in floatingButtons {
            buttonPositions["button_\(button.tag)"] = button.center
        }
        saveData.set(buttonPositions.mapValues { ["x": $0.x, "y": $0.y] }, forKey: "button_positions") // CGPointを辞書として保存
    }
    
    // パンジェスチャー（ボタンのドラッグ）の処理
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let productButton = gesture.view as? UIButton else { return }
        
        let translation = gesture.translation(in: self.view)
        productButton.center = CGPoint(x: productButton.center.x + translation.x, y: productButton.center.y + translation.y)
        gesture.setTranslation(.zero, in: self.view)
        
        switch gesture.state {
        case .began:
            stopFloatingAnimation(for: productButton) // ドラッグ中はアニメーションを停止
        case .changed:
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.prepare()
            
            if kitchenButton.frame.contains(productButton.center) ||
                emergencyButton.frame.contains(productButton.center) ||
                trashButton.frame.contains(productButton.center) {
                feedbackGenerator.selectionChanged()
            }
        case .ended, .cancelled:
            restartFloatingAnimation(for: productButton) // ドラッグが終わったらアニメーションを再開
            
            // ボタンがどの領域にドロップされたかを確認して処理を行う
            if kitchenButton.frame.contains(productButton.center) {
                animateImageDrop(to: kitchenButton, productButton: productButton)
                productDataArray[productButton.tag]["currentPage"] = "KitchenVC"
                saveData.set(productDataArray, forKey: "array_data")
                registerProductToView(productData: productDataArray[productButton.tag], forView: "kitchenView")
            } else if emergencyButton.frame.contains(productButton.center) {
                animateImageDrop(to: emergencyButton, productButton: productButton)
                productDataArray[productButton.tag]["currentPage"] = "EmergencyVC"
                saveData.set(productDataArray, forKey: "array_data")
                registerProductToView(productData: productDataArray[productButton.tag], forView: "emergencyView")
            } else if trashButton.frame.contains(productButton.center) {
                confirmDeletion(for: productButton)
            }
            
            // ドラッグが終了した時点でボタンの位置を保存
            saveButtonPositions()
        default:
            break
        }
    }
    
}
