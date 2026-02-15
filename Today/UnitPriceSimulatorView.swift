import SwiftUI

struct UnitPriceSimulatorView: View {
    @EnvironmentObject var settings: SettingsManager
    let items: [LedgerItem]
    
    private var processedIncomes: [LedgerItem] {
        // let filtered = items.filter { !$0.isExpense } 
        let filtered = items 
        return filtered.sorted { $0.amount > $1.amount }
    }
    private var totalIncome: Int {
        processedIncomes.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            StarFieldView()

            TimelineView(.periodic(from: .now, by: 1/60)) { timeline in
                renderOrbitContent(at: timeline.date)
            }

            uiOverlayLayer
        }
    }
    
    @ViewBuilder
    private func renderOrbitContent(at date: Date) -> some View {
        let now = date.timeIntervalSinceReferenceDate
        let displayItems = Array(processedIncomes.prefix(12).enumerated())
        
        ZStack {
            CentralSunView(themeColor: settings.themeColor)

            ForEach(displayItems, id: \.offset) { index, item in
                let orbitRadius = CGFloat(90 + (index * 25))
                let rotationSpeed = Double(0.8 / (Double(index) + 1.5))
                let currentAngle = now * rotationSpeed + Double(index * 30)
                
                PlanetView(
                    item: item,
                    radius: orbitRadius,
                    angle: currentAngle,
                    color: settings.themeColor
                )
            }
        }
    }
    
    private var uiOverlayLayer: some View {
        VStack {
            VStack(spacing: 8) {
                Text("FINANCIAL UNIVERSE")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .tracking(5)
                    .foregroundColor(Color.white.opacity(0.6)) 
                
                Text("\(totalIncome)원")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white) 
            }
            .padding(.top, 60)
            
            Spacer()
            
            Text("궤도를 도는 행성들은 당신의 수익입니다.")
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.4)) 
                .padding(.bottom, 30)
        }
    }
}


struct StarFieldView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<50 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let starSize = CGFloat.random(in: 1...3)
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)), with: .color(Color.white.opacity(Double.random(in: 0.1...0.5))))
            }
        }
        .ignoresSafeArea()
    }
}

struct CentralSunView: View {
    var themeColor: Color
    @State private var pulse = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(themeColor.opacity(0.2))
                .frame(width: 100, height: 100)
                .blur(radius: 20)
                .scaleEffect(pulse)
            
            Circle()
                .fill(RadialGradient(colors: [Color.white, themeColor], center: .center, startRadius: 0, endRadius: 20))
                .frame(width: 45, height: 45)
                .shadow(color: themeColor, radius: 15)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulse = 1.3
            }
        }
    }
}

struct PlanetView: View {
    let item: LedgerItem
    let radius: CGFloat
    let angle: Double
    let color: Color
    
    var body: some View {
        let x = cos(angle) * Double(radius)
        let y = sin(angle) * Double(radius)
        let planetSize = min(max(CGFloat(item.amount) / 15000.0, 12), 35)
        
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                .frame(width: radius * 2, height: radius * 2)

            VStack(spacing: 5) {
                Circle()
                    .fill(LinearGradient(colors: [color, color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: planetSize, height: planetSize)
                    .shadow(color: color.opacity(0.6), radius: 5)
                
                Text("\(item.amount / 10000)만")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .offset(x: CGFloat(x), y: CGFloat(y))
        }
    }
}
