import LocalAuthentication
import Combine // 👈 이게 반드시 있어야 ObservableObject를 인식합니다!
class SecurityManager: ObservableObject {
    static let shared = SecurityManager()
    @Published var isUnlocked = false // 인증 성공 여부

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // 생체 인증(FaceID/TouchID)이 가능한 기기인지 확인
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "장부를 열기 위해 인증이 필요합니다."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // 인증 실패 시 처리 (보통 아무것도 안 하거나 경고)
                        print("인증 실패")
                    }
                }
            }
        } else {
            // 생체 인증을 지원하지 않는 기기일 때 (예: 암호 입력으로 대체하거나 바로 통과)
            self.isUnlocked = true
        }
    }
}//
//  SecurityManager.swift
//  Today
//
//  Created by 준성핑 on 2/15/26.
//

