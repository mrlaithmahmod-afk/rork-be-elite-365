import Foundation
import AuthenticationServices

@Observable
class AuthService {
    var isAuthenticated: Bool = false
    var currentUserID: String?
    var userEmail: String?
    var userName: String?

    init() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        currentUserID = UserDefaults.standard.string(forKey: "currentUserID")
        userName = UserDefaults.standard.string(forKey: "userName")
        userEmail = UserDefaults.standard.string(forKey: "userEmail")
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userID = credential.user
                currentUserID = userID
                if let email = credential.email {
                    userEmail = email
                    UserDefaults.standard.set(email, forKey: "userEmail")
                }
                if let fullName = credential.fullName {
                    let name = [fullName.givenName, fullName.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    if !name.isEmpty {
                        userName = name
                        UserDefaults.standard.set(name, forKey: "userName")
                    }
                }
                isAuthenticated = true
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(userID, forKey: "currentUserID")
            }
        case .failure:
            break
        }
    }

    func signInWithEmail(email: String, password: String) {
        let storedID = UserDefaults.standard.string(forKey: "emailUserID_\(email.lowercased())")
        let userID = storedID ?? UUID().uuidString
        currentUserID = userID
        userEmail = email
        isAuthenticated = true
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(userID, forKey: "currentUserID")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(userID, forKey: "emailUserID_\(email.lowercased())")
    }

    func signOut() {
        isAuthenticated = false
        currentUserID = nil
        userEmail = nil
        userName = nil
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "currentUserID")
    }

    func requestAccountDeletion() {
        signOut()
    }
}
