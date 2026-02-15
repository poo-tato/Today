import SwiftUI

struct WorkAnalysisView: View {
    @State private var items: [LedgerItem] = []
    
    // 1. 작업 종류별(카테고리별) 시급 분석 로직
    var categoryStats: [CategoryStat] {
        let grouped = Dictionary(grouping: items) { $0.category ?? "미분류" }
        return grouped.map { (key, value) in
            let totalAmount = value.reduce(0) { $0 + $1.amount }
            let totalHours = value.compactMap { $0.workHours }.reduce(0, +)
            let avgRate = totalHours > 0 ? Int(Double(totalAmount) / totalHours) : 0
            return CategoryStat(name: key, totalAmount: totalAmount, avgHourlyRate: avgRate, count: value.count)
        }.sorted { $0.avgHourlyRate > $1.avgHourlyRate } // 시급 높은 순 정렬
    }

    var body: some View {
        NavigationView {
            List {
                // 상단 요약 섹션
                Section(header: Text("전체 효율 리포트").font(.caption)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("평균 시급")
                                .font(.subheadline).foregroundColor(.secondary)
                            Text("\(overallAvgRate)원")
                                .font(.title2).bold()
                                .foregroundColor(.mintBackground)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("최고 가성비")
                                .font(.subheadline).foregroundColor(.secondary)
                            Text(categoryStats.first?.name ?? "-")
                                .font(.title2).bold()
                        }
                    }
                    .padding(.vertical, 10)
                }

                // 🌟 작업 종류별 상세 리스트
                Section(header: Text("작업 종류별 가성비 순위").font(.caption)) {
                    ForEach(categoryStats, id: \.name) { stat in
                        HStack(spacing: 15) {
                            // 시급에 따른 아이콘 컬러
                            Circle()
                                .fill(colorForRate(stat.avgHourlyRate))
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(stat.name)
                                    .font(.headline)
                                Text("\(stat.count)건의 작업 완료")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(stat.avgHourlyRate)원 / h")
                                    .font(.system(.subheadline, design: .rounded))
                                    .bold()
                                Text("총 \(stat.totalAmount)원")
                                    .font(.caption2).foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                // 💡 준성님을 위한 전략적 조언
                Section(header: Text("AI 전략 제안").font(.caption)) {
                    Text(strategyComment)
                        .font(.system(size: 14))
                        .foregroundColor(.primary.opacity(0.8))
                        .lineSpacing(4)
                }
            }
            .navigationTitle("가성비 대시보드")
            .onAppear(perform: loadData)
        }
    }

    // --- 데이터 가공용 보조 로직 ---
    
    var overallAvgRate: Int {
        let totalAmount = items.reduce(0) { $0 + $1.amount }
        let totalHours = items.compactMap { $0.workHours }.reduce(0, +)
        return totalHours > 0 ? Int(Double(totalAmount) / totalHours) : 0
    }
    
    var strategyComment: String {
        guard let best = categoryStats.first, let worst = categoryStats.last, categoryStats.count > 1 else {
            return "데이터가 더 쌓이면 가성비 전략을 제안해드릴게요!"
        }
        return "현재 [\(best.name)] 작업이 시간 대비 수익이 가장 좋습니다. [\(worst.name)] 작업은 단가를 20% 정도 인상하거나 작업 시간을 단축하는 전략이 필요해 보입니다. 🚀"
    }

    func colorForRate(_ rate: Int) -> Color {
        if rate >= 50000 { return .green }
        if rate >= 20000 { return .mintBackground }
        if rate >= 10000 { return .orange }
        return .red
    }
    
    func loadData() {
            // 장부 뷰에서 사용하는 것과 동일한 App Group 저장소 이름을 사용해야 합니다.
            let sharedSuite = UserDefaults(suiteName: "group.com.junseong.today")
            
            if let d = sharedSuite?.data(forKey: "l_db"),
               let decodedItems = try? JSONDecoder().decode([LedgerItem].self, from: d) {
                // 가져온 데이터를 items 변수에 쏙 넣어줍니다.
                self.items = decodedItems
            }
        }
}

struct CategoryStat {
    let name: String
    let totalAmount: Int
    let avgHourlyRate: Int
    let count: Int
}
