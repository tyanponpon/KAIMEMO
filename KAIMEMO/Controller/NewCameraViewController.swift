import UIKit
import AVFoundation

class NewCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    // カメラセッション関連のプロパティ
    var captureSession: AVCaptureSession! // カメラセッションの管理
    var previewLayer: AVCaptureVideoPreviewLayer! // カメラプレビューを表示するレイヤー
    var captureOutput: AVCapturePhotoOutput! // 写真のキャプチャを行う出力
    
    // イメージピッカー（画像の選択や撮影を行うクラス）
    var imagePicker = UIImagePickerController()
    
    // 画面が読み込まれた際の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景色を黒に設定
        view.backgroundColor = .black
        
        // カメラをセットアップして撮影画面を表示
        takePhoto()
        
        // イメージピッカーの設定（必要に応じて使用）
        setupImagePicker()
    }
    
    // 画面が表示された後の処理
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    // 画面が非表示になる際の処理
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
    }
    
    // 別画面に移動する前のデータ準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondCheckView" {
            print("画面遷移")
            // 遷移先のViewControllerにデータを渡す準備
            _ = segue.destination as? NewCameraViewController
        }
    }
    
    // カメラを起動して写真を撮影
    func takePhoto() {
        // カメラが利用可能か確認
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // カメラの起動
            let picker = UIImagePickerController()
            picker.sourceType = .camera // カメラを利用する設定
            picker.delegate = self // デリゲートを設定
            picker.allowsEditing = true // 撮影後に編集を許可
            
            // カメラを画面に表示
            present(picker, animated: true, completion: nil)
        } else {
            // カメラが利用できない場合にエラーメッセージを出力
            print("error")
        }
    }
    
    // 撮影後の処理（未使用）
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickerMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
    }
    
    // カメラのセットアップ処理
    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings() // 撮影の設定
        captureOutput.capturePhoto(with: settings, delegate: self) // 写真をキャプチャ
    }
    
    // イメージピッカーの設定
    func setupImagePicker() {
        imagePicker.delegate = self // デリゲートを設定
        imagePicker.sourceType = .camera // カメラを利用
        imagePicker.cameraCaptureMode = .photo // 撮影モードを写真に設定
        imagePicker.allowsEditing = false // 編集を許可しない
    }
    
    // イメージピッカーを起動
    func launchImagePicker() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 撮影した画像を保存し、次の画面に遷移
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let capturedImage = info[.originalImage] as? UIImage {
            saveAndNavigate(image: capturedImage, picker: picker)
        }
    }
    
    // 写真撮影後のデリゲート処理
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            // エラーがあれば表示
            print("写真撮影エラー: \(error)")
            return
        }
        
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            // 撮影画像を保存（未使用部分）
            // saveAndNavigate(image: image)
        }
    }
    
    // 撮影した画像を保存し、次の画面へ遷移
    func saveAndNavigate(image: UIImage, picker: UIImagePickerController) {
        // 画像をUserDefaultsに保存
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            UserDefaults.standard.set(imageData, forKey: "capturedPhoto")
        }
        
        print("dismiss picker")
        // UIImagePickerControllerを閉じる
        picker.dismiss(animated: true) { [weak self] in
            print("show alert")
            // アラートを表示
            let alert = UIAlertController(title: "写真が撮れました", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                // DataViewControllerへ遷移
                self?.performSegue(withIdentifier: "toSecondCheckView", sender: image)
            }))
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
