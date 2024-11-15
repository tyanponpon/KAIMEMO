//
//  Goods.swift
//  KAIMEMO
//
//  Created by 藤崎花音 on 2024/07/12.
//

import Foundation

// 構造体定義
struct ProductResponse: Codable {
    let hits: [Product]
}

struct Product: Codable{
    var brand: Brand = Brand(name: "Default Brand") //商品のメーカー
    var name: String = "Default Name" // 商品の名前
    var priceLabel: PriceLabel  //商品の値段
    var image: Image  //商品画像
    var url: String //商品のネットショッピングページへのURL
   
    
}

struct Brand: Codable {
    let name: String
}

struct PriceLabel: Codable {
    let defaultPrice: Double
}

struct Image: Codable{
    let medium: URL
}






