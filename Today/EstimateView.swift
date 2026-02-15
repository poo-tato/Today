import SwiftUI

struct EstimateView: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var clientName: String = ""
    @State private var projectName: String = ""
    @State private var features: [String] = [""]
    @State private var finalPrice: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    Text(settings.profileEmoji)
                        .font(.system(size: 40))
                        .padding(10)
                        .background(Color.mintBackground.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(settings.userName)님의 견적 생성기")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                        Text("iArch Studio Professional").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal).padding(.vertical, 10).background(Color.white)

                Form {
                    Section(header: Text("고객 및 프로젝트 정보").font(.caption.bold())) {
                        TextField("고객명 (예: 디스코드 홍길동)", text: $clientName)
                        TextField("프로젝트명 (예: 알림 봇 프로젝트)", text: $projectName)
                    }
                    Section(header: Text("포함 기능 리스트").font(.caption.bold())) {
                        ForEach(0..<features.count, id: \.self) { index in
                            HStack {
                                TextField("기능 입력", text: $features[index])
                                if features.count > 1 {
                                    Button(action: { features.remove(at: index) }) {
                                        Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        Button(action: { features.append("") }) {
                            Label("기능 추가", systemImage: "plus.circle.fill").foregroundColor(.mintBackground)
                        }
                    }
                    Section(header: Text("최종 합계 금액").font(.caption.bold())) {
                        HStack {
                            Text("총 금액").bold()
                            Spacer()
                            TextField("0", value: $finalPrice, format: .number).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 120).font(.headline)
                            Text("원")
                        }
                    }
                    Section {
                        Button(action: shareEstimateImage) {
                            HStack {
                                Spacer(); Image(systemName: "square.and.arrow.up"); Text("견적서 공유 및 저장하기").bold(); Spacer()
                            }
                        }.foregroundColor(.white).listRowBackground(Color.black)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    var estimateCard: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("QUOTATION").font(.system(size: 32, weight: .black, design: .rounded))
                    Text("iArch Studio | \(settings.userName)").font(.subheadline).bold().foregroundColor(.secondary)
                }
                Spacer()
                Text(settings.profileEmoji).font(.system(size: 40))
            }
            Rectangle().frame(height: 2).foregroundColor(.black)
            VStack(alignment: .leading, spacing: 10) {
                Text("To. \(clientName.isEmpty ? "고객님" : clientName)").font(.title3).bold()
                Text("Project: \(projectName.isEmpty ? "미정" : projectName)").font(.headline)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("[ 포함 기능 상세 ]").font(.caption.bold())
                ForEach(features.filter { !$0.isEmpty }, id: \.self) { feature in
                    Text("• \(feature)").font(.system(size: 16))
                }
            }
            .padding().frame(maxWidth: .infinity, alignment: .leading).background(Color.gray.opacity(0.1)).cornerRadius(10)
            HStack {
                Text("TOTAL").font(.headline)
                Spacer()
                Text("\(finalPrice) 원").font(.title2).bold().foregroundColor(.blue)
            }.padding().background(Color.gray.opacity(0.1)).cornerRadius(10)
        }
        .padding(40).frame(width: 500).background(Color.white)
    }

    func shareEstimateImage() {
        let renderer = ImageRenderer(content: estimateCard)
        renderer.scale = 3.0
        if let uiImage = renderer.uiImage {
            let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }
}
