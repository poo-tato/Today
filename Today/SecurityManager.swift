import LocalAuthentication
import Combine 
class SecurityManager: ObservableObject {
    static let shared = SecurityManager()
    @Published var isUnlocked = false 

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "장부를 열기 위해 인증이 필요합니다."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        print("인증 실패")
                    }
                }
            }
        } else {
            self.isUnlocked = true
        }
    }
}
