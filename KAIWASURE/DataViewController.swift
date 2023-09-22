//
//  DateViewController.swift
//  KAIWASURE
//
//  Created by 藤崎花音 on 2023/04/21.
//

import UIKit

class DataViewController: UIViewController {

    var detailArray = [String: Any]()
    @IBOutlet var itemLabel : UILabel!
    @IBOutlet var categoryLabel : UILabel!
    @IBOutlet var itemImageView : UIImageView!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var memoButton: UIButton!
    var array = [[String: Any]]()
    var saveData: UserDefaults = UserDefaults.standard
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        array = saveData.object(forKey: "array_data") as! [[String: Any]]
        categoryLabel.text = detailArray["category"] as? String
        itemLabel.text = detailArray["item"] as? String
        itemImageView.image = UIImage(data: (detailArray["image"] as! NSData) as Data)
        commentTextView.text = detailArray["comment"] as? String
        saveData.set(array, forKey: "comment")
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardWillShow),
                                                   name: UIResponder.keyboardWillShowNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardWillHide),
                                                   name: UIResponder.keyboardWillHideNotification,
                                                   object: nil)
        // Do any additional setup after loading the view.
    }
    

    
    //他の部分を触ったときにキーボードを閉じる
       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           if (self.commentTextView.isFirstResponder) {
               self.commentTextView.resignFirstResponder()
           }
           self.view.endEditing(true)
       }
    
    @IBAction func saveMemo() {
        let alert: UIAlertController = UIAlertController(title: "保存", message: "メモを保存しました。", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "OK",
                          style: .default
                          )
        )
        present(alert,animated: true,completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

        // 編集中のtextFieldを取得
        guard let commentTextView = commentTextView else { return }
        // キーボード、画面全体、textFieldのsizeを取得
        let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        guard let keyboardHeight = rect?.size.height else { return }
        let mainBoundsSize = UIScreen.main.bounds.size
        let commentTextViewHeight = commentTextView.frame.height

        // ①
        let commentTextViewPositionY = commentTextView.frame.origin.y + commentTextViewHeight + 10.0
        // ②
        let keyboardPositionY = mainBoundsSize.height - keyboardHeight

        // ③キーボードをずらす
        if keyboardPositionY <= commentTextViewPositionY {
            let duration: TimeInterval? =
                notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            UIView.animate(withDuration: duration!) {
                // viewをy座標方向にtransformする
                self.view.transform = CGAffineTransform(translationX: 0, y: keyboardPositionY - commentTextViewPositionY)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let duration: TimeInterval? = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.transform = CGAffineTransform.identity
        }
    }

  
       // リターンがタップされた時にキーボードを閉じる
       func commenttextViewShouldReturn(_ textField: UITextField) -> Bool {
           commentTextView.resignFirstResponder()
           return true
       }

  
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension Notification {

    // キーボードの高さ
    var keyboardHeight: CGFloat? {
        return (self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
    }

    // キーボードのアニメーション時間
    var keybaordAnimationDuration: TimeInterval? {
        return self.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
    }

    // キーボードのアニメーション曲線
    var keyboardAnimationCurve: UInt? {
        return self.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
    }
}
