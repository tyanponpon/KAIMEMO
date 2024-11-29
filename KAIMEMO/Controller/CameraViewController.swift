import UIKit
import AVFoundation
import MLKit

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var barcodeValue: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        //カメラの設定を行う
        setCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // captureSessionが存在しない場合は、新たにカメラを設定する
        if captureSession == nil {
            setCamera()
        } else {
            // すでにセッションがある場合は、再起動
            if !captureSession.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession.startRunning()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // タブバーの高さを考慮して、previewLayerのフレームを再設定
        let safeAreaInsets = view.safeAreaInsets
        let tabBarHeight = safeAreaInsets.bottom
        let adjustedHeight = view.bounds.height - tabBarHeight
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: adjustedHeight)
    }
    
    func setCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        // 一旦ここで previewLayer を追加（フレームは viewDidLayoutSubviews で設定）
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }

    // segueが動作することをViewControllerに通知するメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "modal" {
            let next = segue.destination as? CheckViewController
            next?.barcode = barcodeValue
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferGetImageBuffer(sampleBuffer) != nil else { return }
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = imageOrientation(
            deviceOrientation: UIDevice.current.orientation,
            cameraPosition: .back
        )
        let barcodeScanner = BarcodeScanner.barcodeScanner()
        barcodeScanner.process(visionImage) { barcodes, error in
            guard error == nil, let barcodes = barcodes, !barcodes.isEmpty else {
                return
            }
            
            for barcode in barcodes {
                if let rawValue = barcode.rawValue {
                    self.barcodeValue = rawValue
                    print("Barcode value: \(rawValue)")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "商品情報を取得", message: "", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                            self.performSegue(withIdentifier: "modal", sender: nil)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                    break
                }
            }
        }
    }
    
    private func imageOrientation(
        deviceOrientation: UIDeviceOrientation,
        cameraPosition: AVCaptureDevice.Position
    ) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return .right
        case .landscapeLeft:
            return cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return .left
        case .landscapeRight:
            return cameraPosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .right
        @unknown default:
            fatalError()
        }
    }
    
    func currentUIOrientation() -> UIDeviceOrientation {
        let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        switch orientation {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .unknown
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
