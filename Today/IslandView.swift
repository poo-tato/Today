import SwiftUI

struct IslandView: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var items: [LedgerItem] = []
    
    var currentMonthTotal: Int {
        items.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
             .reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
    }
    
    var islandLevel: Int { min(max(currentMonthTotal / 500000, 0), 100) }
    var nextLevelGoal: Int { (islandLevel + 1) * 500000 }
    
    var levelProgress: Double {
        if islandLevel >= 100 { return 1.0 }
        if currentMonthTotal < 0 { return 0.0 }
        
        let currentLevelRemainder = currentMonthTotal % 500000
        return Double(currentLevelRemainder) / 500000.0
    }

    var body: some View {
        ZStack {
            backgroundSeaGradient.ignoresSafeArea()
            backgroundDecorations
            
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("LEVEL \(islandLevel)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(currentMonthTotal < 0 ? Color.red : settings.themeColor))
                    
                    Text("\(settings.userName)의 \(rankName)")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                }
                .padding(.top, 30)
                
                ZStack {
                    Circle()
                        .fill((currentMonthTotal < 0 ? Color.red : settings.themeColor).opacity(0.2))
                        .frame(width: 250)
                        .blur(radius: 40)
                    
                    VStack(spacing: -10) {
                        Text(settings.profileEmoji)
                            .font(.system(size: 50))
                            .offset(y: -20)
                            .shadow(radius: 5)
                        
                        Text(currentMonthTotal < 0 ? "🌊" : mainEmoji)
                            .font(.system(size: 130))
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
                    }
                }
                .frame(height: 280)
                
                VStack(spacing: 15) {
                    HStack {
                        Text(currentMonthTotal < 0 ? "적자 경보 🚨" : "정산 경험치")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(levelProgress * 100))%")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(currentMonthTotal < 0 ? .red : settings.themeColor)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 15)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(currentMonthTotal < 0 ? Color.red : settings.themeColor)
                                .frame(width: geometry.size.width * CGFloat(levelProgress), height: 15)
                        }
                    }
                    .frame(height: 15)
                    
                    HStack {
                        Text(currentMonthTotal < 0 ? "\(formatCurrency(abs(currentMonthTotal))) 손실" : "\(formatCurrency(currentMonthTotal)) 순수익")
                            .font(.caption)
                            .foregroundColor(currentMonthTotal < 0 ? .red : .gray)
                        
                        Spacer()
                        
                        if islandLevel < 100 && currentMonthTotal >= 0 {
                            let remain = nextLevelGoal - currentMonthTotal
                            Text("\(formatCurrency(remain)) 남음")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(25)
                .background(Color.white.opacity(0.9))
                .cornerRadius(30)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear(perform: loadData)
    }

    
    var backgroundSeaGradient: LinearGradient {
        let baseColor = currentMonthTotal < 0 ? Color.red : settings.themeColor
        return LinearGradient(gradient: Gradient(colors: [baseColor.opacity(0.1), .white]), startPoint: .top, endPoint: .bottom)
    }
    
    var backgroundDecorations: some View {
        ZStack {
            if islandLevel >= 2 { Text("☁️").offset(x: -100, y: -250) }
            if islandLevel >= 10 { Text("🐬").offset(x: -120, y: 50) }
            if islandLevel >= 20 { Text("🚢").offset(x: 80, y: 120) }
        }.font(.system(size: 30)).opacity(0.3)
    }
    
    var mainEmoji: String {
        let emojis = ["🏖️", "⛺", "🏠", "🏡", "🏘️", "🏢", "🏛️", "🏰", "🏯", "👑", "💎"]
        return emojis[min(islandLevel / 5, emojis.count - 1)]
    }
    
    var rankName: String {
        if currentMonthTotal < 0 { return "위기의 개척자" }
        if islandLevel < 2 { return "무인도 개척자" }
        if islandLevel < 10 { return "정착한 시민" }
        if islandLevel < 20 { return "성공한 프리랜서" }
        return "정산의 신"
    }
    
    func formatCurrency(_ v: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return (f.string(from: NSNumber(value: v)) ?? "\(v)") + "원"
    }
    
    func loadData() {
        let sharedSuite = UserDefaults(suiteName: "group.com.junseong.today")
        if let d = sharedSuite?.data(forKey: "l_db"),
           let i = try? JSONDecoder().decode([LedgerItem].self, from: d) {
            items = i
        }
    }
}
