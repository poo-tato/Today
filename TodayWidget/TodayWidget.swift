import WidgetKit
import SwiftUI

// 🌟 [항목 정의] 위젯에서도 isExpense를 인식할 수 있게 필드를 추가합니다.
struct LedgerItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var channel: String
    var amount: Int
    var date: Date
    var isExpense: Bool // ✨ 추가됨
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), total: 1250000, goal: 3000000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), total: 1250000, goal: 3000000)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedSuite = UserDefaults(suiteName: "group.com.junseong.today")
        var netProfit = 0
        var goalAmount = 3000000
        
        // 🌟 [핵심 수정] 지출은 빼고 수입은 더해서 '순수익' 계산
        if let d = sharedSuite?.data(forKey: "l_db"),
           let items = try? JSONDecoder().decode([LedgerItem].self, from: d) {
            netProfit = items.filter {
                Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month)
            }.reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
        }
        
        if let goalStr = sharedSuite?.string(forKey: "monthly_goal"), let goalInt = Int(goalStr) {
            goalAmount = goalInt
        }

        let entry = SimpleEntry(date: Date(), total: netProfit, goal: goalAmount)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let total: Int
    let goal: Int
}

struct TodayWidgetEntryView : View {
    var entry: Provider.Entry
    
    var percentage: Double {
        guard entry.goal > 0 else { return 0 }
        // 적자일 때는 0%로 표시
        return max(0, Double(entry.total) / Double(entry.goal))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.total < 0 ? "📉" : "💰").font(.system(size: 18))
                Spacer()
                Text("\(Int(min(percentage * 100, 999)))%")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.black.opacity(0.6))
            }
            
            Spacer(minLength: 0)
            
            Text(entry.total < 0 ? "이번 달 손실" : "이번 달 수익")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.black.opacity(0.5))
            
            // 마이너스 금액일 때 빨간색으로 강조
            Text("\(entry.total)원")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(entry.total < 0 ? .red : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // 미니 프로그레스 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        // 적자면 빨간색, 달성 완료면 주황색, 진행 중이면 흰색
                        .fill(entry.total < 0 ? Color.red : (percentage >= 1.0 ? Color.orange : Color.white))
                        .frame(width: min(geo.size.width * CGFloat(percentage), geo.size.width), height: 8)
                }
            }
            .frame(height: 8)
        }
        .containerBackground(for: .widget) {
            // 적자 상태일 때 위젯 배경에 살짝 붉은 기운을 줍니다.
            LinearGradient(
                gradient: Gradient(colors: entry.total < 0
                                   ? [Color(red: 1.0, green: 0.9, blue: 0.9), Color(red: 1.0, green: 0.95, blue: 0.95)]
                                   : [Color(red: 0.73, green: 0.89, blue: 0.86), Color(red: 0.85, green: 0.95, blue: 0.92)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct TodayWidget: Widget {
    let kind: String = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("내 정산 위젯")
        .description("순수익과 목표 달성률을 확인하세요.")
        .supportedFamilies([.systemSmall])
    }
}
