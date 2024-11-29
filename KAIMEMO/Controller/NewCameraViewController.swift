import UIKit
import AVFoundation

class NewCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {

    // カメラセッション関連
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureOutput: AVCapturePhotoOutput!

    // イメージピッカー
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色を設定
        view.backgroundColor = .black

        // カメラのセットアップ
        setupCamera()

        // イメージピッカーのセットアップ（必要に応じて使用）
        setupImagePicker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // セッションを開始
        captureSession.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // セッションを停止
        captureSession.stopRunning()
    }
    
    // Segueを使用して別の画面に移動する前にデータを準備する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewCameraView" {
            // 商品の詳細画面に選択した商品データを渡す
            let next = segue.destination as? NewCameraViewController
           
        }
    }

    // MARK: - Camera Setup
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        // デバイスの取得
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("カメラが見つかりません")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("カメラ入力の追加に失敗: \(error)")
            return
        }

        captureOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        setupCaptureButton()
    }

    func setupCaptureButton() {
        let captureButton = UIButton(type: .custom)
        captureButton.frame = CGRect(x: view.bounds.midX - 30, y: view.bounds.height - 100, width: 60, height: 60)
        captureButton.backgroundColor = .red
        captureButton.layer.cornerRadius = 30
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
    }

    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        captureOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Image Picker Setup
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.allowsEditing = false
    }

    func launchImagePicker() {
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let capturedImage = info[.originalImage] as? UIImage {
            saveAndNavigate(image: capturedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("写真撮影エラー: \(error)")
            return
        }

        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            saveAndNavigate(image: image)
        }
    }

    // MARK: - Shared Functionality
    func saveAndNavigate(image: UIImage) {
        // 画像を保存
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            UserDefaults.standard.set(imageData, forKey: "capturedPhoto")
        }

        // アラート表示と画面遷移
        let alert = UIAlertController(title: "写真が撮れました", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "toSecondCheckView", sender: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
