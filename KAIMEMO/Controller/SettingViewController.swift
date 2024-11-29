import UIKit

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    
    var userArray = ["ユーザー設定", "通知設定"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        
        // ユーザー名と画像を読み込む
        loadUserData()
        
        // プロフィール画像を元のサイズに戻す
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.gray.cgColor
        
        // 画像が余白なく表示されるようにコンテンツモードを設定
        userImage.contentMode = .scaleAspectFill
        
        // 雲の画像を3箇所に散りばめる
        addCloudImage(at: CGRect(x: 120, y: 200, width: 100, height: 60))  // 上部に雲
        addCloudImage(at: CGRect(x: 200, y: 300, width: 150, height: 80)) // 中央に雲
        addCloudImage(at: CGRect(x: 120, y: 400, width: 120, height: 70)) // 下部に雲
        
        // タブバーの高さを取得
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        
        // グラデーション背景の設定（上から下にパステルブルーからパステルピンク、真ん中より下にブルーの範囲）
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - tabBarHeight)
        gradientLayer.colors = [
            UIColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0).cgColor, // 濃いめのパステルブルー
            UIColor.white.cgColor, // 中間の白
            UIColor(red: 1.0, green: 0.8, blue: 0.9, alpha: 1.0).cgColor  // パステルピンク
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)  // ブルーの範囲を下げる
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // 既存のグラデーションレイヤーを削除して追加
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // TableViewの背景を透明に設定
        table.backgroundColor = .clear
        
        // テーブルビューの更新をする
        table.reloadData()
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    // セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = userArray[indexPath.row]
        
        // 文字をBoldにする
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)  // Bold設定
        
        // セルの背景を透明にして、背景のグラデーションが見えるようにする
        cell.backgroundColor = .clear
        
        return cell
    }
    
    // セルがタップされたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // ユーザー設定に遷移
            self.performSegue(withIdentifier: "toUserView", sender: nil)
        case 1:
            // 通知設定に遷移
            self.performSegue(withIdentifier: "toNoticeView", sender: nil)
        default:
            print("未対応のセルがタップされました。")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // ユーザーデータを読み込んで表示する
    func loadUserData() {
        let userDefaults = UserDefaults.standard
        
        // ユーザー名を表示（ない場合は「ユーザー名」を表示）
        if let savedName = userDefaults.string(forKey: "userName") {
            userName.text = savedName
        } else {
            userName.text = "ユーザー名"
        }
        
        // ユーザー名にBoldを適用
        userName.font = UIFont.boldSystemFont(ofSize: 22)  // Bold設定
        
        // プロフィール画像を表示（ない場合は灰色の画像を表示）
        if let imageData = userDefaults.data(forKey: "userProfileImage"), let profileImage = UIImage(data: imageData) {
            userImage.image = profileImage
        } else {
            userImage.backgroundColor = .lightGray // プロフィール画像がない場合は背景色を灰色に設定
            userImage.image = nil // デフォルトで画像は設定しない
        }
    }
    
    // セグエで戻ってきたときに再度ユーザーデータを読み込む
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()  // 画面に戻った際にデータを更新する
    }
    
    // 雲の画像を指定した位置に追加するメソッド
    func addCloudImage(at frame: CGRect) {
        let cloudImageView = UIImageView(frame: frame)
        cloudImageView.image = UIImage(named: "雲")  // 雲の画像を指定
        cloudImageView.contentMode = .scaleAspectFill
        cloudImageView.alpha = 0.5  // 透明度を設定
        view.addSubview(cloudImageView)
        view.sendSubviewToBack(cloudImageView)
    }
}
