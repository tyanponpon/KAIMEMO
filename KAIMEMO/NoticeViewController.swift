import UIKit
import UserNotifications

class NoticeViewController: UIViewController {
    
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var registerButton: UIButton!
    
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 通知許可を求める
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                print("通知許可が得られました")
            } else {
                print("通知許可が拒否されました: \(error?.localizedDescription ?? "不明なエラー")")
            }
        }
        
        // DatePickerのスタイルを設定
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .automatic
        
        // DatePickerを中心より少し上に配置
        centerDatePicker()
        
        // 「通知を設定して書い忘れを防止しよう！」というラベルを追加
        setupNoticeLabel()
        
        // 登録ボタンのスタイルを設定
        setupRegisterButtonStyle()
        
        // ボタンにアクションを追加
        registerButton.addTarget(self, action: #selector(registerButtonTapped(_:)), for: .touchUpInside)
        
        // 背景にグラデーションを設定（パステル水色からパステルピンクへのグラデーション）
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.7, green: 1.0, blue: 1.0, alpha: 1.0).cgColor, // パステル水色
            UIColor(red: 1.0, green: 0.8, blue: 0.9, alpha: 1.0).cgColor  // パステルピンク
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    func setupNoticeLabel() {
        let noticeLabel = UILabel()
        
        // 太字フォントを設定
        let boldFont = UIFont.boldSystemFont(ofSize: 18)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        
        // 改行を入れるテキスト
        let text = "通知を設定して\n買い忘れを防止しよう！"
        
        let attributedText = NSMutableAttributedString(string: text, attributes: [
            .font: boldFont,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.darkGray
        ])
        
        noticeLabel.attributedText = attributedText
        noticeLabel.numberOfLines = 0
        noticeLabel.textAlignment = .center
        
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noticeLabel)
        
        // AutoLayoutの制約を追加
        NSLayoutConstraint.activate([
            noticeLabel.bottomAnchor.constraint(equalTo: datePicker.topAnchor, constant: -20),
            noticeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noticeLabel.widthAnchor.constraint(equalToConstant: 300),
            noticeLabel.heightAnchor.constraint(equalToConstant: 60)  // 高さを調整
        ])
    }

    func setupRegisterButtonStyle() {
        // ボタンのテキストスタイル
        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: "登録", attributes: attributes)
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

    func centerDatePicker() {
        // Auto Layoutの制約をコードで設定
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
    }
    
    @objc func registerButtonTapped(_ sender: UIButton) {
        scheduleNotification(for: datePicker.date)
        
        // アラートを表示
        let alert = UIAlertController(title: "登録完了", message: "通知が設定されました。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func scheduleNotification(for date: Date) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: date)
        dateComponents.month = calendar.component(.month, from: date)
        dateComponents.day = calendar.component(.day, from: date)
        dateComponents.hour = calendar.component(.hour, from: date)
        dateComponents.minute = calendar.component(.minute, from: date)
        
        let content = UNMutableNotificationContent()
        content.title = "買い物の時間だよ"
        content.body = "買い忘れがないか確認してね！"
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "DailyNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("通知リクエストの追加に失敗しました: \(error.localizedDescription)")
            } else {
                print("通知が設定されました")
            }
        }
    }
}
