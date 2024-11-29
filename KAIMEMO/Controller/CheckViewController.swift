//
//  CheckViewController.swift
//  KAIMEMO
//
//  Created by 藤崎花音 on 2024/06/21.
//

import UIKit

class CheckViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var barcode: String = ""
    var productList: [Product] = []
    var productImage: [UIImage?] = []
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self  // デリゲートの設定
        
        Task {
            let response: ProductResponse? = await requestProduct()
            guard let productResult = response else { return }
            productList = productResult.hits
            
            productImage = []
            for product in productList {
                let image = await getImage(url: product.image.medium)
                productImage.append(image)
            }
            print("画像データ取得中")
            print(productImage.count)
            tableView.reloadData()
        }
        
        print("CheckViewControllerが表示されました。")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segueのIDを確認して特定のsegueのときのみ動作させる
        if segue.identifier == "toDataViewController" {
            // 2. 遷移先のViewControllerを取得
            let next = segue.destination as? DataViewController
            // 3. １で用意した遷移先の変数に値を渡す
            next?.selectedProduct = productList[selectedIndex]
            next?.selectedProductImage = productImage[selectedIndex]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        // 1. 画面遷移実行
        performSegue(withIdentifier: "toDataViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = productImage[indexPath.row]
        content.text = productList[indexPath.row].name
        cell.contentConfiguration = content
        
        return cell
    }
    
    func requestProduct() async -> ProductResponse? {
        let urlString = "https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch?appid=dj00aiZpPUlYaVN0SEdVS2FFOCZzPWNvbnN1bWVyc2VjcmV0Jng9OGY-&query=\(barcode)&results=30"
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        guard let url = URL(string: encodedUrlString) else { return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else { return nil }
            
            if httpResponse.statusCode == 200 {
                let decodedData = try JSONDecoder().decode(ProductResponse.self, from: data)
                return decodedData
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    func getImage(url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            return image
        } catch {
            return nil
        }
    }
}



