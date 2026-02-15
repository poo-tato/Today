# 🍎 Today (투데이)
> **"매일의 기록이 모여 더 나은 일상을 만듭니다."**
> 복잡한 가계부 대신, 직관적인 소비 기록과 성취를 돕는 iOS 장부 앱입니다.

---

## 📱 Screenshots

| 메인 화면 | 가성비 분석 | 내 섬 (보상) | 설정 |
| :---: | :---: | :---: | :---: |
| <img src="https://media.discordapp.net/attachments/1471773620488638508/1472558673132785747/IMG_0301.png?ex=699302a2&is=6991b122&hm=689302dc02b89d9e35a7c830ca6104c099c1077736d329703cbf38ec0da5686c&=&format=webp&quality=lossless&width=636&height=1378" width="200"> | <img src="https://media.discordapp.net/attachments/1471773620488638508/1472558673481039913/IMG_0302.png?ex=699302a2&is=6991b122&hm=27b2aa767b1415e76c4d6f915c69a599dcdc28275906515fba8f78121ad3e04c&=&format=webp&quality=lossless&width=636&height=1378" width="200"> | <img src="https://media.discordapp.net/attachments/1471773620488638508/1472558673799811163/IMG_0303.png?ex=699302a2&is=6991b122&hm=112e26c1d6f688515de9eac47293f440db6c13a50369eed2532e2269dd6d8893&=&format=webp&quality=lossless&width=636&height=1378" width="200"> | <img src="https://media.discordapp.net/attachments/1471773620488638508/1472558674105864426/IMG_0304.png?ex=699302a2&is=6991b122&hm=2b134e0fc011e16d4d564e2e0b242ac62e4134a628ce88a942d24bdbf4b068f5&=&format=webp&quality=lossless&width=636&height=1378" width="200"> |

---

## 📝 Project Overview
* **이름**: Today (투데이)
* **개발 기간**: 2026.01 ~ 현재
* **목표**: 사용자가 자신의 소비 패턴을 직관적으로 파악하고, '가성비'라는 주관적 가치를 데이터화하여 관리할 수 있도록 돕는 시스템 구축
* **개발자**: **Potato (Jun-seong)**

---

## 🏗 Architecture
본 프로젝트는 유지보수성과 데이터 흐름의 명확성을 위해 **MVC (Model-View-Controller)** 패턴을 기반으로 설계되었습니다.

* **Model**: `Transaction` 데이터 구조 정의 및 `UserDefaults` 기반의 데이터 영속성(Persistence) 관리
* **View**: SwiftUI를 활용한 반응형 인터페이스 및 탭 기반 네비게이션 구현
* **Controller/Logic**: 지출 데이터 가공, 가성비 알고리즘 계산 및 화면 전환 로직 제어

---

## 🚀 Key Features
* **Efficient Data Management**: 지출 및 수입 내역의 CRUD(생성, 조회, 수정, 삭제) 기능을 안정적으로 구현
* **Cost-Efficiency Analysis**: 단순 금액 기록을 넘어, 소비의 만족도를 사용자가 직접 평가하고 분석할 수 있는 커스텀 로직 탭 제공
* **My Island (Gamification)**: 소비 기록의 성취도에 따라 시각적인 보상을 제공하는 '내 섬' 기능으로 사용자 동기부여
* **Local Persistence**: 앱 재설치나 재시작 시에도 데이터가 유실되지 않도록 로컬 저장 로직 최적화
* **SwiftUI Animation**: 사용자 경험을 높이기 위한 직관적인 화면 전환 및 인터랙티브 요소 적용

---

## 🛠 Tech Stack
* **Language**: Swift 5.10+
* **Framework**: SwiftUI
* **Architecture**: MVC
* **Storage**: UserDefaults / Codable
* **IDE**: Xcode 15.0+

---

## 🧑‍💻 Developer's Reflection
* **로직의 구체화**: 800줄 이상의 코드를 작성하며 복잡한 데이터 흐름을 효율적으로 관리하기 위한 조건문과 예외 처리 역량을 길렀습니다.
* **사용자 중심 기획**: 개발자로서의 관점뿐만 아니라, 실제 사용자가 '가성비'를 고민하는 지점을 포착하여 기능을 구현했습니다.
* **디버깅 경험**: 데이터 저장 및 불러오기 과정에서 발생한 런타임 에러를 직접 해결하며 데이터 정합성 유지의 중요성을 체감했습니다.
* **확장 가능성**: 현재의 안정적인 데이터를 바탕으로, 추후 로컬 알림(Push Notification) 및 통계 차트 기능을 추가하여 '갓생(God-Saeng)' 프로젝트로 고도화할 예정입니다.

---
© 2026 Potato Dev. (First Growth Project)
