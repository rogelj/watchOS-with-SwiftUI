import SwiftUI
import AuthenticationServices

struct SignInView: View {
  @AppStorage("userName") private var storedUserName = ""
  @Environment(\.dismiss) private var dismiss

  let onSignedIn: (String) -> Void
  
  var body: some View {
    ScrollView {
      Text("This action requires you to be signed in.")
        .font(.body)

      SignInWithAppleButton(onRequest: onRequest, onCompletion: siwaCompletion)
        .signInWithAppleButtonStyle(.white)

      Divider()
        .padding()
      
      PasswordView(
        userName: storedUserName,
        completionHandler: userPasswordCompletion
      )
    }
  }

  private func userPasswordCompletion(userName: String, password: String) {
    storedUserName = userName

    var request = URLRequest(url: URL(string: "https://your.site.com/login")!)
    request.httpMethod = "POST"
    // request.httpBody = ...

    DispatchQueue.main.async {
      onSignedIn("some token here")
      dismiss()
    }
  }

  private func onRequest(request: ASAuthorizationAppleIDRequest) {

  }

  private func siwaCompletion(result: Result<ASAuthorization, Error>) {

  }
}

struct SignInView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView { _ in }
  }
}
