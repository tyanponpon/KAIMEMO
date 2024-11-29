import UIKit

class KitchenViewController: UIViewController {
    
    // 保存された商品データの配列
    var productDataArray: [[String: Any]] = [] // 商品データは最初は空
    let buttonSize: CGFloat = 100.0 // ボタンのサイズを定義
    let padding: CGFloat = 10.0 // ボタン間の余白
    var saveData: UserDefaults = UserDefaults.standard // データを保存するためのインスタンス
    var floatingButtons: [UIButton] = [] // 商品ボタンのリスト
    var selectedIndex: Int = 0 // 現在選択されている商品ボタンのインデックス
    var dropTargetArea: UIView! // ドロップ対象のエリアを定義（例えばキッチン）
    // 商品を削除するためのゴミ箱ボタン
    @IBOutlet var trashButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タブバーを非表示にする（他のタブに移動しないように）
        self.tabBarController?.tabBar.isHidden = true
        
        // ドロップエリアの設定（例えば画面中央に200x200のエリアを作成）
        dropTargetArea = UIView(frame: CGRect(x: (self.view.frame.width - 200) / 2, y: (self.view.frame.height - 200) / 2, width: 200, height: 200))
        dropTargetArea.backgroundColor = .clear // 背景色を設定しないことで、見えないエリアになる
        self.view.addSubview(dropTargetArea) // ドロップエリアを画面に追加
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProductData() // 保存された商品データを読み込む
        createProductButtons() // 読み込んだ商品データからボタンを作成
        self.tabBarController?.tabBar.isHidden = false // タブバーを表示
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createProductButtons() // レイアウト変更時に商品ボタンを再描画
    }
    
    // 保存されたデータを読み込むメソッド
    func loadProductData() {
        if let savedData = saveData.array(forKey: "array_data") as? [[String: Any]] {
            // 保存されている全ての商品データを読み込む
            productDataArray = savedData
            print(productDataArray) // 読み込んだデータをコンソールに表示して確認
        }
    }
    
    // Segueを使用して別の画面に移動する前にデータを準備する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailViewController" {
            // 商品の詳細画面に選択した商品データを渡す
            let next = segue.destination as? DetailViewController
            next?.productData = productDataArray[selectedIndex]
            next?.productIndex = selectedIndex
        }
    }
    
    // ドラッグ＆ドロップで商品をキッチンビューに追加する処理
    func addProductToKitchenView(product: [String: Any]) {
        productDataArray.append(product) // 商品データを追加
        createProductButtons() // 新しい商品データからボタンを再描画
    }
    
    // 商品データからボタンを生成するメソッド
    func createProductButtons() {
        // 既存のボタンを削除して再生成する
        for button in floatingButtons {
            button.removeFromSuperview() // 画面から削除
        }
        floatingButtons.removeAll() // リストをクリア
        
        // 保存されているボタンの位置を取得
        let savedButtonPositions = saveData.dictionary(forKey: "kitchen_button_positions") as? [String: [String: CGFloat]] ?? [:]
        let safeAreaInsets = view.safeAreaInsets
        let navBarHeight = safeAreaInsets.top
        let tabBarHeight = safeAreaInsets.bottom
        var xOffset: CGFloat = padding
        var yOffset: CGFloat = padding + navBarHeight
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height - navBarHeight - tabBarHeight
        
        for (index, productData) in productDataArray.enumerated() {
            // currentPageが "KitchenVC" の場合のみボタンを作成
            if let currentPage = productData["currentPage"] as? String, currentPage == "KitchenVC" {
                // 商品画像を設定
                var productImage: UIImage? = UIImage(named: "placeholder") // プレースホルダー画像を設定
                if let imageData = productData["image"] as? Data {
                    productImage = UIImage(data: imageData) // 保存された画像を設定
                }
                
                // 商品用のボタンを作成して設定
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: xOffset, y: yOffset, width: buttonSize, height: buttonSize)
                button.setImage(productImage, for: .normal)
                button.layer.cornerRadius = buttonSize / 2 // ボタンを丸くする
                button.clipsToBounds = true
                
                // 保存されたボタンの位置を適用
                if let savedPosition = savedButtonPositions["button_\(index)"], let x = savedPosition["x"], let y = savedPosition["y"] {
                    button.center = CGPoint(x: x, y: y)
                }
                
                // バブルアニメーションをボタンに追加
                addBubbleAnimation(to: button)
                
                button.tag = index // ボタンのインデックスをタグとして設定
                button.addTarget(self, action: #selector(productButtonTapped(_:)), for: .touchUpInside)
                
                // 在庫数や賞味期限に基づいてボタンの見た目を変える（在庫が少ないと赤枠）
                if let stock = productData["stock"] as? Int, stock <= 1 {
                    button.layer.borderColor = UIColor.red.cgColor
                    button.layer.borderWidth = 3.0
                }
                
                // 賞味期限が近い場合も赤枠にする
                if let expiryDate = productData["period"] as? Date {
                    let currentDate = Date()
                    let calendar = Calendar.current
                    if let daysDifference = calendar.dateComponents([.day], from: currentDate, to: expiryDate).day, daysDifference <= 3 || expiryDate < currentDate {
                        button.layer.borderColor = UIColor.red.cgColor
                        button.layer.borderWidth = 3.0
                    }
                }
                
                // ドラッグで移動できるようにジェスチャーを追加
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                button.addGestureRecognizer(panGesture)
                
                // ボタンを画面に追加
                self.view.addSubview(button)
                
                // 次のボタンの位置を計算
                xOffset += buttonSize + padding
                if xOffset + buttonSize > screenWidth {
                    xOffset = padding
                    yOffset += buttonSize + padding
                    if yOffset + buttonSize > screenHeight {
                        break
                    }
                }
                
                floatingButtons.append(button) // ボタンをリストに追加
                addFloatingAnimation(to: button) // 浮遊アニメーションを追加
            }
        }
    }

    
    // 商品ボタンがタップされたときの処理
    @objc func productButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        performSegue(withIdentifier: "toDetailViewController", sender: nil) // 詳細画面に移動
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
    
    // ボタンに浮遊アニメーションを追加するメソッド
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
        var buttonPositions: [String: [String: CGFloat]] = [:]
        for button in floatingButtons {
            buttonPositions["button_\(button.tag)"] = ["x": button.center.x, "y": button.center.y]
        }
        saveData.set(buttonPositions, forKey: "kitchen_button_positions") // ボタンの位置を保存
    }

    
    // ドラッグの操作を処理するメソッド
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }
        
        // ドラッグによる位置の変化を適用
        let translation = gesture.translation(in: self.view)
        var newCenter = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
        
        // ボタンが画面外に出ないように制限
        let margin: CGFloat = padding
        let halfWidth = button.frame.width / 2
        let halfHeight = button.frame.height / 2
        newCenter.x = max(halfWidth + margin, min(newCenter.x, self.view.bounds.width - halfWidth - margin))
        newCenter.y = max(halfHeight + margin, min(newCenter.y, self.view.bounds.height - halfHeight - margin))
        
        button.center = newCenter // ボタンの新しい位置を設定
        gesture.setTranslation(.zero, in: self.view) // 変化量をリセット
        
        switch gesture.state {
        case .began:
            stopFloatingAnimation(for: button) // ドラッグ中はアニメーションを停止
        case .ended, .cancelled:
            // ドラッグが終わったらアニメーションを再開
            restartFloatingAnimation(for: button)
            
            // ドラッグ終了時に位置を保存
            saveButtonPositions()
            
            if trashButton.frame.contains(button.center) {
                // ゴミ箱ボタン上にドロップされた場合の削除確認
                confirmDeletion(for: button)
            }
        default:
            break
        }
    }

    
    // ドロップエリアにボタンが入っているかを確認するメソッド
    func isProductDroppedInTargetArea(_ button: UIButton) -> Bool {
        return dropTargetArea.frame.contains(button.center) // ボタンがドロップエリア内にあるかどうかを判定
    }
}
