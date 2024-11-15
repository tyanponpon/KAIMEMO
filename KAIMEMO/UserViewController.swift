import UIKit

class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        let boldFont = UIFont.boldSystemFont(ofSize: 18)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        
        let attributedText = NSMutableAttributedString(string: "ユーザー情報を設定して\nカスタマイズしよう！", attributes: [
            .font: boldFont,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.darkGray
        ])
        
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0 // 複数行対応
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "名前を入力"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    // プロフィール画像用のUIImageViewを設定
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 1
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    let cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.backgroundColor = .white // 背景色を設定して透けないようにする
        imageView.layer.cornerRadius = 17.5 // アイコンの半分のサイズにする
        imageView.layer.masksToBounds = true // 角丸を有効にする
        
        // カメラアイコンに影を追加
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowRadius = 3
        imageView.layer.masksToBounds = false
        
        return imageView
    }()

    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: "登録", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // グラデーションレイヤーのプロパティ
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setDismissKeyboard()
        setupUI()
        
        // プロフィール画像をタップ可能に設定
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        
        registerButton.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        
        // グラデーション背景の設定
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.7, green: 1.0, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.8, blue: 0.9, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // ユーザー情報を読み込む
        loadUserData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupRegisterButtonStyle()
    }

    func setupUI() {
        // プロフィール画像の設定
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // カメラアイコンをプロフィール画像に重ねる
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraImageView)
        NSLayoutConstraint.activate([
            cameraImageView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            cameraImageView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            cameraImageView.widthAnchor.constraint(equalToConstant: 35),
            cameraImageView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        // 他のUI部品の配置
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -20)
        ])
        
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(registerButton)
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 150),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupRegisterButtonStyle() {
        registerButton.layer.cornerRadius = 25
        registerButton.clipsToBounds = true
        gradientLayer.colors = [
            UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.3, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = registerButton.bounds
        gradientLayer.cornerRadius = 25
        if gradientLayer.superlayer == nil {
            registerButton.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            gradientLayer.frame = registerButton.bounds
        }
    }
    
    // 画像選択アクション
    @objc func selectImage() {
        let alertController = UIAlertController(title: "画像を選択", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { _ in
                self.openCamera()
            }
            alertController.addAction(cameraAction)
        }
        let libraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { _ in
            self.openPhotoLibrary()
        }
        alertController.addAction(libraryAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @objc func registerUser() {
        let userName = nameTextField.text ?? ""
        let profileImage = profileImageView.image ?? UIImage(named: "defaultProfileImage")
        
        saveUserData(name: userName, profileImage: profileImage)
        showAlert(message: "ユーザー情報を登録しました。")
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func saveUserData(name: String, profileImage: UIImage?) {
        // ユーザー名の保存処理
        UserDefaults.standard.set(name, forKey: "userName")
        
        // プロフィール画像の保存処理
        if let profileImageData = profileImage?.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(profileImageData, forKey: "profileImage")
        }
    }

    func loadUserData() {
        if let savedName = UserDefaults.standard.string(forKey: "userName") {
            nameTextField.text = savedName
        }
        
        if let savedImageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: savedImageData) {
            profileImageView.image = savedImage
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage")
        }
    }
    
}
