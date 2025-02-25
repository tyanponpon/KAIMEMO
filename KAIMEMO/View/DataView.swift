import SwiftUI

struct DataView: View {
    @State private var maker: String = ""
    @State private var volume: String = "500"
    @State private var price: String = "160"
    @State private var expirationDate: String = "2024/12/8"
    @State private var stock: Int = 12
    @State private var memo: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 商品名とお気に入り
                HStack {
                    Text("買いメモする")
                        .font(.title)
                        .bold()
                    Spacer()
                    Image(systemName: "star.fill")
                        .foregroundColor(.black)
                }
                
                // 商品画像
                HStack {
                    Image("coca_cola") // 画像をアセットに追加しておく
                        .resizable()
                        .frame(width: 80, height: 120)
                        .scaledToFit()
                    Spacer()
                    
                    Button(action: {
                        // Yahooショッピングのリンク処理
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("Yahoo ショッピングで見る")
                        }
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                
                // メーカー入力
                VStack(alignment: .leading) {
                    Text("メーカー")
                    TextField("メーカー名を入力", text: $maker)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // 容量 & 値段
                HStack {
                    VStack(alignment: .leading) {
                        Text("容量")
                        HStack {
                            TextField("", text: $volume)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("ml")
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("値段")
                        HStack {
                            TextField("", text: $price)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("円")
                        }
                    }
                }
                
                // 期限
                VStack(alignment: .leading) {
                    Text("期限")
                    TextField("", text: $expirationDate)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // 在庫管理
                VStack(alignment: .leading) {
                    Text("在庫")
                    HStack {
                        Button(action: { if stock > 0 { stock -= 1 } }) {
                            Image(systemName: "minus.circle")
                        }
                        Text("\(stock)")
                            .frame(minWidth: 30)
                        Button(action: { stock += 1 }) {
                            Image(systemName: "plus.circle")
                        }
                        Text("個")
                    }
                }
                
                // メモ入力
                VStack(alignment: .leading) {
                    Text("メモ")
                    TextField("メモを入力", text: $memo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // ボタン
                Button(action: {
                    // 買いメモする処理
                }) {
                    Text("買いメモする")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct ShoppingMemoView_Previews: PreviewProvider {
    static var previews: some View {
       DataView()
    }
}
