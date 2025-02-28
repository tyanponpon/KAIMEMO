import SwiftUI

// ホーム画面（ルーレットの表示）
struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel // 🔹 ViewModel を監視
    
    // 🔹 最初に最上部に表示するセグメントを指定
    let firstSegment = "トイレ"
    
    @State private var rotation: Double
    @State private var lastRotation: Double
    
    let minRotation: Double = 0
    let maxRotation: Double = 240
    let centerAngle: Double = 60
    let labels = ["玄関", "トイレ", "非常", "洗面所", "お風呂", ""]
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        
        if let index = labels.firstIndex(of: firstSegment) {
            let initialRotation = 300 - Double(index) * centerAngle - 60
            _rotation = State(initialValue: initialRotation)
            _lastRotation = State(initialValue: initialRotation)
        } else {
            _rotation = State(initialValue: 60)
            _lastRotation = State(initialValue: 60)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let size = width
            let centerYOffset = size * (3 / 4)
            
            VStack {
                Spacer()
                
                ZStack {
                    // ルーレットの6つのセグメント（扇形）を作成
                    ForEach(0..<6) { i in
                        RouletteSegment(index: i, totalSegments: 6, label: labels[i])
                            .onTapGesture {
                                print("\(labels[i]) が選択されました")
                            }
                    }
                    
                    // ルーレットの中心に白い円を配置
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.1, height: size * 0.1)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                }
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation), anchor: .center) // 🔹 回転
                .offset(y: centerYOffset) // 🔹 ルーレットの中心を下に移動
                .clipped()
                .background(.white)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let delta = value.translation.width / 3
                            rotation = (lastRotation + Double(delta)).clamped(to: minRotation...maxRotation)
                            viewModel.topSegmentIndex = calculateTopSegment(rotation: rotation) // 🔹 ViewModel を更新
                        }
                        .onEnded { _ in
                            let snappedRotation = round(rotation / centerAngle) * centerAngle
                            if snappedRotation != lastRotation {
                                let feedbackGenerator = UISelectionFeedbackGenerator()
                                feedbackGenerator.prepare()
                                feedbackGenerator.selectionChanged()
                            }
                            rotation = snappedRotation
                            lastRotation = snappedRotation
                            viewModel.topSegmentIndex = calculateTopSegment(rotation: rotation) // 🔹 ViewModel を更新
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // 🔹 現在最上部にあるセグメントを計算
    private func calculateTopSegment(rotation: Double) -> Int {
        let normalizedRotation = (rotation.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let segmentIndex = (6 - Int((normalizedRotation + centerAngle / 2) / centerAngle)) % 6  // 🔹 時計回りに修正
        return segmentIndex
    }
}

// ルーレットのセグメント（扇形を1つ描く）
struct RouletteSegment: View {
    let index: Int
    let totalSegments: Int
    let label: String // 🔹 追加：ラベルの文字列
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .white]
    
    func contains(point: CGPoint, center: CGPoint, radius: CGFloat) -> Bool {
        let angle = 360.0 / Double(totalSegments)
        let startAngle = Double(index) * angle
        let endAngle = startAngle + angle
        
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        
        guard distance <= radius else { return false } // 半径の範囲外なら false
        
        let pointAngle = atan2(dy, dx) * 180 / .pi
        let normalizedAngle = (pointAngle >= 0 ? pointAngle : (360 + pointAngle)) // 負の角度を補正
        
        return normalizedAngle >= startAngle && normalizedAngle <= endAngle
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width * 1.5
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.width / 2)
            let radius = size / 2
            let angle = 360.0 / Double(totalSegments)
            let startAngle = Double(index) * angle
            let endAngle = startAngle + angle
            let midAngle = (startAngle + endAngle) / 2 // 🔹 セグメントの中心角度
            
            ZStack {
                Path { path in
                    path.move(to: center)
                    path.addArc(center: center,
                                radius: radius,
                                startAngle: .degrees(startAngle),
                                endAngle: .degrees(endAngle),
                                clockwise: false)
                    path.closeSubpath()
                }
                .fill(colors[index])
                .overlay(
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center,
                                    radius: radius,
                                    startAngle: .degrees(startAngle),
                                    endAngle: .degrees(endAngle),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                        .stroke(Color.black, lineWidth: 2)
                )
                
                // 🔹 テキストを追加
                Text(label)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(midAngle + 90)) // 🔹 文字の向きを調整
                    .position(x: center.x + radius * 0.65 * cos(midAngle * .pi / 180),
                              y: center.y + radius * 0.65 * sin(midAngle * .pi / 180))
            }
        }
    }
}

// **範囲制限用の拡張**
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
