import SwiftUI
import Combine
import WidgetKit

struct LedgerItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var channel: String
    var amount: Int
    var date: Date
    var category: String?    
        var workHours: Double?
    var isExpense: Bool 
}


import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    let sharedSuite = UserDefaults(suiteName: "group.com.junseong.today")
    @Published var themeColor: Color = Color.mintBackground
    @Published var userName: String {
        didSet { sharedSuite?.set(userName, forKey: "user_name") }
    }
    @Published var myAccount: String {
        didSet { sharedSuite?.set(myAccount, forKey: "my_account") }
    }
    @Published var monthlyGoal: String {
        didSet { sharedSuite?.set(monthlyGoal, forKey: "monthly_goal") }
    }
    @Published var profileEmoji: String {
        didSet { sharedSuite?.set(profileEmoji, forKey: "profile_emoji") }
    }

    @Published var selectedMonth: Date = Date()

    @Published var animationType: Int {
        didSet { sharedSuite?.set(animationType, forKey: "animation_type") }
    }

    init() {
        self.userName = sharedSuite?.string(forKey: "user_name") ?? "준성"
        self.myAccount = sharedSuite?.string(forKey: "my_account") ?? "케이뱅크 100229055612"
        self.monthlyGoal = sharedSuite?.string(forKey: "monthly_goal") ?? "3000000"
        self.profileEmoji = sharedSuite?.string(forKey: "profile_emoji") ?? "💰"
        self.animationType = sharedSuite?.integer(forKey: "animation_type") ?? 0
    }

    var currentAnimation: Animation {
        switch animationType {
        case 1:
            return .spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)
        case 2:
            return .easeInOut(duration: 0.5)
        default:
            return .default
        }
    }

    func saveUserName(_ name: String) { self.userName = name }
    func saveAccount(_ account: String) { self.myAccount = account }
    func saveGoal(_ goal: String) { self.monthlyGoal = goal }
    func saveAnimation(_ type: Int) { self.animationType = type }
    func saveEmoji(_ emoji: String) { self.profileEmoji = emoji }
}
extension Color {
    static let mintBackground = Color(red: 0.73, green: 0.89, blue: 0.86)
    static let softGray = Color(white: 0.95)
}

func formatCurrency(_ value: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return (formatter.string(from: NSNumber(value: value)) ?? "\(value)") + "원"
}

@main
struct TodayLedgerApp: App {
    @StateObject private var settings = SettingsManager.shared
    var body: some Scene {
        WindowGroup {
            MainTabView().environmentObject(settings)
        }
    }
}

struct MainTabView: View {
    @StateObject private var security = SecurityManager.shared // 추가
    @State private var items: [LedgerItem] = []
    
    var body: some View {
        Group {
            if security.isUnlocked {
                TabView {
                    LedgerView()
                        .tabItem { Label("장부", systemImage: "dollarsign.circle.fill") }
                    IslandView()
                        .tabItem { Label("내 섬", systemImage: "beach.umbrella.fill") }
                    ProfileView()
                        .tabItem { Label("설정", systemImage: "person.crop.circle.fill") }
                }
                .accentColor(.black)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.mintBackground)
                    Text("장부가 잠겨있습니다")
                        .font(.headline)
                    Button("인증하기") {
                        security.authenticate()
                    }
                    .padding()
                    .background(Color.mintBackground)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .onAppear {
                    security.authenticate()
                }
            }
        }
    }
}

struct GoalProgressBar: View {
    @EnvironmentObject var settings: SettingsManager
    let totalIncome: Int   
    let totalExpense: Int  
    let goal: Int
    
    var netProfit: Int {
        totalIncome - totalExpense
    }
    
    var percentage: Double {
        guard goal > 0 else { return 0 }
        return Double(netProfit) / Double(goal)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(percentage >= 1.0 ? "목표 달성 완료! 🔥" : "목표까지 \(max(0, Int((1.0 - percentage) * 100)))% 남았어요")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 13, weight: .black, design: .rounded))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.05)).frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(netProfit < 0 ? Color.red : settings.themeColor) 
                        .frame(width: min(max(0, geo.size.width * CGFloat(percentage)), geo.size.width), height: 12)
                        .animation(.spring(), value: percentage)
                }
            }
            .frame(height: 12)
            
            Divider().opacity(0.5)
            
            HStack(spacing: 0) {
                summaryColumn(title: "총 수입", value: totalIncome, color: settings.themeColor, prefix: "+")
                summaryColumn(title: "총 지출", value: totalExpense, color: .red, prefix: "-")
                summaryColumn(title: "순수익", value: netProfit, color: netProfit < 0 ? .red : .primary, prefix: "", isBold: true)
            }
        }
        .padding(18).background(Color.white).cornerRadius(22)
    }
    
    func summaryColumn(title: String, value: Int, color: Color, prefix: String, isBold: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.system(size: 9, weight: .bold)).foregroundColor(.secondary)
            Text("\(prefix)\(formatCurrency(abs(value)))") 
                .font(.system(size: isBold ? 12 : 11, weight: isBold ? .black : .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: title == "총 수입" ? .leading : (title == "순수익" ? .trailing : .center))
    }

    func formatCurrency(_ v: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return (f.string(from: NSNumber(value: v)) ?? "\(v)") + "원"
    }
}

struct NotionCalendarView: View {
    @EnvironmentObject var settings: SettingsManager
    let items: [LedgerItem]
    
    func totalForDay(date: Date) -> Int {
        items.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
             .reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(formatMonth(settings.selectedMonth))
                    .font(.system(size: 18, weight: .black, design: .rounded))
                Spacer()
                HStack(spacing: 15) {
                    Button(action: { moveMonth(by: -1) }) {
                        Image(systemName: "chevron.left").font(.footnote).bold().foregroundColor(.gray)
                    }
                    Button(action: { moveMonth(by: 1) }) {
                        Image(systemName: "chevron.right").font(.footnote).bold().foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 5)

            let days = generateDaysInMonth(for: settings.selectedMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day).font(.system(size: 10, weight: .heavy)).foregroundColor(.secondary)
                }
                ForEach(0..<days.count, id: \.self) { index in
                    ZStack {
                        if let date = days[index] {
                            let dayTotal = totalForDay(date: date)
                            let isToday = Calendar.current.isDateInToday(date)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isToday ? settings.themeColor : Color.softGray.opacity(0.5)) 
                            
                            VStack(spacing: 2) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(isToday ? .white : .primary)
                                
                                if dayTotal != 0 {
                                    Text(formatCurrency(abs(dayTotal))) 
                                        .font(.system(size: 6, weight: .black))
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                        .foregroundColor(isToday ? .white : (dayTotal > 0 ? settings.themeColor : .red))
                                }
                            }
                        }
                    }.frame(height: 38)
                }
            }
        }
        .padding(12)
        .background(Color.white).cornerRadius(18)
    }

    func moveMonth(by v: Int) { if let n = Calendar.current.date(byAdding: .month, value: v, to: settings.selectedMonth) { settings.selectedMonth = n } }
    func formatMonth(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "yyyy년 M월"; return f.string(from: d) }
    func generateDaysInMonth(for d: Date) -> [Date?] {
        guard let r = Calendar.current.range(of: .day, in: .month, for: d), let f = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: d)) else { return [] }
        let w = Calendar.current.component(.weekday, from: f)
        var days: [Date?] = Array(repeating: nil, count: w - 1)
        for d in r { if let dt = Calendar.current.date(byAdding: .day, value: d - 1, to: f) { days.append(dt) } }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
}


struct LedgerView: View {
    @State private var items: [LedgerItem] = []
    @State private var showingAdd = false
    @State private var editingItem: LedgerItem? = nil 
    @State private var viewMode = 0
    @EnvironmentObject var settings: SettingsManager

    var currentMonthTotal: Int {
        items.filter { Calendar.current.isDate($0.date, equalTo: settings.selectedMonth, toGranularity: .month) }
             .reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
    }

    var filteredItems: [LedgerItem] {
        items.filter { Calendar.current.isDate($0.date, equalTo: settings.selectedMonth, toGranularity: .month) }
             .sorted(by: { $0.date > $1.date })
    }

    var totalIncome: Int {
        items.filter { Calendar.current.isDate($0.date, equalTo: settings.selectedMonth, toGranularity: .month) && !$0.isExpense }
             .reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Int {
        items.filter { Calendar.current.isDate($0.date, equalTo: settings.selectedMonth, toGranularity: .month) && $0.isExpense }
             .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.softGray.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Text(settings.profileEmoji)
                            .font(.system(size: 30))
                            .padding(8)
                            .background(settings.themeColor.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("\(settings.userName)님의 장부")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                        
                        Spacer()
                        
                        Picker("모드", selection: $viewMode.animation(settings.currentAnimation)) {
                            Text("내역").tag(0)
                            Text("가성비").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                    .padding(.horizontal).padding(.top, 10)

                    if viewMode == 0 {
                        VStack(spacing: 12) {
                            GoalProgressBar(
                                totalIncome: totalIncome,
                                totalExpense: totalExpense,
                                goal: Int(settings.monthlyGoal) ?? 0
                            )
                            NotionCalendarView(items: items)
                        }.padding(.horizontal)

                        List {
                            Section(header: Text("내역 리스트 (탭해서 수정)").font(.caption.bold())) {
                                if filteredItems.isEmpty {
                                    Text("기록이 없습니다.").font(.caption).foregroundColor(.secondary)
                                } else {
                                    ForEach(filteredItems) { item in
                                        Button(action: { editingItem = item }) {
                                            HStack {
                                                Image(systemName: channelIcon(channel: item.channel, isExpense: item.isExpense))
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(item.isExpense ? .red : settings.themeColor)
                                                    .frame(width: 35, height: 35)
                                                    .background(item.isExpense ? Color.red.opacity(0.1) : settings.themeColor.opacity(0.1))
                                                    .cornerRadius(8)
                                                
                                                VStack(alignment: .leading) {
                                                    Text(item.title).font(.system(size: 14, weight: .bold))
                                                    Text(formatTime(item.date)).font(.system(size: 10)).foregroundColor(.secondary)
                                                }
                                                
                                                Spacer()
                                                
                                                Text("\(item.isExpense ? "-" : "+")\(formatCurrency(item.amount))")
                                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                                    .foregroundColor(item.isExpense ? .red : settings.themeColor)
                                            }
                                        }
                                    }.onDelete(perform: deleteItems)
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .scrollContentBackground(.hidden)
                    } else {
                        WorkAnalysisContentView(items: items)
                    }
                }

                VStack {
                    Spacer()
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 55, height: 55)
                            .background(settings.themeColor)
                            .clipShape(Circle())
                            .shadow(color: settings.themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.bottom, 15)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAdd) {
                AddLedgerSheet(items: $items, save: saveToStorage)
            }
            .sheet(item: $editingItem) { item in
                AddLedgerSheet(items: $items, editingItem: item, save: saveToStorage)
            }
            .onAppear(perform: loadData)
        }
    }

    func channelIcon(channel: String, isExpense: Bool) -> String {
        if isExpense {
            return "dollarsign.circle.fill"
        }
        
        switch channel {
        case "디스코드": return "person.2.wave.2.fill"
        case "텔레그램": return "paperplane.fill"
        case "오픈카톡": return "bubble.left.and.bubble.right.fill"
        default: return "dollarsign.circle.fill"
        }
    }
    func formatTime(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "M월 d일"; return f.string(from: d) }
    func formatCurrency(_ v: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return (f.string(from: NSNumber(value: v)) ?? "\(v)") + "원"
    }
    func loadData() {
        let sharedSuite = UserDefaults(suiteName: "group.com.junseong.today")
        if let d = sharedSuite?.data(forKey: "l_db"), let i = try? JSONDecoder().decode([LedgerItem].self, from: d) { items = i }
    }
    func deleteItems(at offsets: IndexSet) {
        offsets.forEach { index in
            let target = filteredItems[index]
            items.removeAll { $0.id == target.id }
        }
        saveToStorage()
    }
    func saveToStorage() {
        let sharedSuite = UserDefaults(suiteName: "group.com.junseong.today")
        if let d = try? JSONEncoder().encode(items) { sharedSuite?.set(d, forKey: "l_db") }
    }
}





struct WorkAnalysisContentView: View {
    @EnvironmentObject var settings: SettingsManager
    let items: [LedgerItem]
    
    var incomeItems: [LedgerItem] {
        items.filter { !$0.isExpense }
    }
    
    var categoryStats: [CategoryStat] {
        let grouped = Dictionary(grouping: incomeItems) { $0.channel }
        
        return grouped.map { (key, value) in
            let totalAmount = value.reduce(0) { $0 + $1.amount }
            
            let totalHours = value.reduce(0.0) { $0 + ($1.workHours ?? 0.0) }
            
            let avgRate = totalHours > 0 ? Int(Double(totalAmount) / totalHours) : 0
            
            return CategoryStat(
                name: key,
                totalAmount: totalAmount,
                avgHourlyRate: avgRate,
                count: value.count
            )
        }.sorted { $0.avgHourlyRate > $1.avgHourlyRate } 
    }

    var overallAvgRate: Int {
        let totalAmount = incomeItems.reduce(0) { $0 + $1.amount }
        let totalHours = incomeItems.reduce(0.0) { $0 + ($1.workHours ?? 0.0) }
        return totalHours > 0 ? Int(Double(totalAmount) / totalHours) : 0
    }

    var strategyComment: String {
        guard let best = categoryStats.first, let worst = categoryStats.last, categoryStats.count > 1 else {
            return "데이터가 더 쌓이면 \(settings.userName)님만을 위한 가성비 전략을 제안해드릴게요! 📈"
        }
        return "현재 [\(best.name)] 작업이 시간 대비 수익이 가장 높습니다. [\(worst.name)] 작업은 단가를 인상하거나 작업 시간을 단축하여 효율을 높여보세요! 🚀"
    }

    var body: some View {
        List {
            Section(header: Text("전체 효율 리포트").font(.caption.bold())) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("평균 시급").font(.caption).foregroundColor(.secondary)
                        Text("\(overallAvgRate)원")
                            .font(.title2).bold()
                            .foregroundColor(settings.themeColor)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("최고 가성비").font(.caption).foregroundColor(.secondary)
                        Text(categoryStats.first?.name ?? "-").font(.title2).bold()
                    }
                }
                .padding(.vertical, 10)
            }

            Section(header: Text("작업 종류별 가성비 순위").font(.caption.bold())) {
                if categoryStats.isEmpty {
                    Text("수입 기록이 부족합니다.").font(.caption).foregroundColor(.secondary)
                } else {
                    ForEach(categoryStats, id: \.name) { stat in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(colorForRate(stat.avgHourlyRate))
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stat.name).font(.system(size: 15, weight: .bold))
                                Text("\(stat.count)건 완료").font(.system(size: 11)).foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(stat.avgHourlyRate)원 / h").font(.system(size: 14, weight: .bold, design: .rounded))
                                Text("총 \(formatCurrency(stat.totalAmount))").font(.system(size: 10)).foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section(header: Text("AI 전략 제안").font(.caption.bold())) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("수익성 분석 리포트", systemImage: "lightbulb.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text(strategyComment)
                        .font(.system(size: 13))
                        .foregroundColor(.primary.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .scrollContentBackground(.hidden)
    }

    func colorForRate(_ rate: Int) -> Color {
        if rate >= 50000 { return .green }      
        if rate >= 25000 { return settings.themeColor } 
        if rate >= 10000 { return .orange }    
        return .red                            
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: amount)) ?? "\(amount)") + "원"
    }
}





struct AddLedgerSheet: View {
    @Binding var items: [LedgerItem]
    var editingItem: LedgerItem? = nil 
    var save: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsManager

    @State private var title = ""
    @State private var amount = ""
    @State private var channel = "디스코드"
    @State private var date = Date()
    @State private var isExpense = false
    @State private var workHours = "" 

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("유형 선택")) {
                    Picker("거래 유형", selection: $isExpense) {
                        Text("수입 💰").tag(false)
                        Text("지출 💸").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("내용")) {
                    TextField(isExpense ? "지출 내역 (예: 서버비)" : "작업명 (예: 외주 작업)", text: $title)
                    TextField("금액 (원)", text: $amount)
                        .keyboardType(.numberPad)
                    
                    if !isExpense {
                        // 수입일 때만 시간과 채널을 입력받음
                        TextField("작업 시간 (예: 2.5)", text: $workHours)
                            .keyboardType(.decimalPad)
                        
                        Picker("유입 채널", selection: $channel) {
                            Text("디스코드").tag("디스코드")
                            Text("텔레그램").tag("텔레그램")
                            Text("오픈카톡").tag("오픈카톡")
                            Text("기타").tag("기타")
                        }
                    }
                    
                    DatePicker("날짜", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(editingItem == nil ? (isExpense ? "지출 추가" : "수입 추가") : "내역 수정")
            .navigationBarItems(
                leading: Button("취소") { dismiss() },
                trailing: Button("저장") {
                    if let amt = Int(amount) {
                        // 옵셔널 에러 해결: Double?을 안전하게 Double로 변환
                        let hours = Double(workHours) ?? 0.0
                        
                        if let itemToEdit = editingItem {
                            // --- [수정 모드] ---
                            if let index = items.firstIndex(where: { $0.id == itemToEdit.id }) {
                                items[index].title = title
                                items[index].amount = amt
                                items[index].channel = channel
                                items[index].date = date
                                items[index].workHours = hours
                                items[index].isExpense = isExpense
                            }
                        } else {

                            let newItem = LedgerItem(
                                title: title,
                                channel: channel,
                                amount: amt,
                                date: date,
                                workHours: hours,
                                isExpense: isExpense
                            )
                            items.append(newItem)
                        }
                        save()
                        WidgetCenter.shared.reloadAllTimelines()
                        dismiss()
                    }
                }
                .foregroundColor(isExpense ? .red : settings.themeColor)
                .disabled(title.isEmpty || amount.isEmpty)
            )
            .onAppear {
                if let item = editingItem {
                    title = item.title
                    amount = String(item.amount)
                    channel = item.channel
                    date = item.date
                    isExpense = item.isExpense
                    if let h = item.workHours, h > 0 {
                        workHours = String(h)
                    } else {
                        workHours = ""
                    }
                }
            }
        }
    }
}



struct ProfileView: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var showingResetAlert = false
    @State private var showCopyToast = false
    @FocusState private var focusedField: Field?
    
    // ✨ 준성님이 고를 수 있는 이모지 리스트 (원하는 걸로 더 추가 가능!)
    let emojis = ["💰", "😎", "🚀", "🔥", "💎", "👻", "🐧", "🐶", "💸", "🤑", "🐵", "🐙", "🐷"]

    enum Field { case name, account, goal }

    var goalAmount: Double { Double(settings.monthlyGoal) ?? 0 }

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                    .onTapGesture { focusedField = nil }

                Form {
                    Section {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.mintBackground.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Text(settings.profileEmoji)
                                    .font(.system(size: 60))
                            }
                            .padding(.top, 10)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(emojis, id: \.self) { emoji in
                                        Button(action: {
                                            settings.saveEmoji(emoji)
                                            UISelectionFeedbackGenerator().selectionChanged()
                                        }) {
                                            Text(emoji)
                                                .font(.system(size: 30))
                                                .padding(10)
                                                .background(settings.profileEmoji == emoji ? Color.mintBackground.opacity(0.3) : Color.clear)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        .padding(.vertical, 15)
                        .listRowBackground(Color.clear)
                    }

                    Section(header: Text("수익 목표")) {
                        VStack(spacing: 15) {
                            Text("이번 달 목표 수익").font(.subheadline).foregroundColor(.secondary)
                            Text(formatCurrency(Int(goalAmount)))
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.mintBackground)
                            
                            Slider(value: Binding(
                                get: { goalAmount },
                                set: { settings.saveGoal(String(Int($0))) }
                            ), in: 0...10000000, step: 100000)
                            .accentColor(.mintBackground)
                        }
                        .padding(.vertical, 10)
                    }

                    Section(header: Text("상세 정보").font(.caption.bold())) {
                        HStack {
                            Label("이름", systemImage: "person.fill").foregroundColor(.secondary)
                            Spacer()
                            TextField("이름 입력", text: Binding(
                                get: { settings.userName },
                                set: { settings.saveUserName($0) }
                            ))
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .name)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Label("내 계좌 (정산용)", systemImage: "creditcard.fill").font(.caption.bold()).foregroundColor(.secondary)
                            HStack(spacing: 8) {
                                TextField("계좌 정보 입력", text: Binding(
                                    get: { settings.myAccount },
                                    set: { settings.saveAccount($0) }
                                ))
                                .focused($focusedField, equals: .account)
                                .padding(12)
                                .background(Color.softGray)
                                .cornerRadius(10)
                                
                                Button(action: {
                                    UIPasteboard.general.string = settings.myAccount
                                    withAnimation(.spring()) { showCopyToast = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        withAnimation { showCopyToast = false }
                                    }
                                }) {
                                    VStack(spacing: 2) {
                                        Image(systemName: "doc.on.doc.fill")
                                        Text("복사").font(.system(size: 10, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 45)
                                    .background(Color.mintBackground)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("앱 동작 설정").font(.caption.bold())) {
                        Picker("애니메이션", selection: Binding(
                            get: { settings.animationType },
                            set: { settings.saveAnimation($0) }
                        )) {
                            Text("기본").tag(0)
                            Text("쫀득하게").tag(1)
                            Text("부드럽게").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .navigationTitle("내 프로필")

                if showCopyToast {
                    toastOverlay
                }
            }
        }
    }

    var toastOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("계좌가 복사되었습니다!")
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .padding(.vertical, 12).padding(.horizontal, 24)
            .background(Color.black.opacity(0.8)).cornerRadius(25)
            .padding(.bottom, 50)
        }
    }

    func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: value)) ?? "\(value)") + "원"
    }
}
