import WidgetKit
import SwiftUI

@main
struct TodayWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget() // 여기서 TodayWidget.swift에 있는 위젯을 호출합니다.
    }
}
