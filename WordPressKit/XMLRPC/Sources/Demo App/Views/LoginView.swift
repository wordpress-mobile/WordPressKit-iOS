import SwiftUI

struct LoginView: View {

    @EnvironmentObject
    var login: LoginRepository

    var loginButtonIsDisabled: Bool {
        login.username.isEmpty || login.password.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            if let error = login.error {
                Text(error.localizedDescription).fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                TextField("", text: $login.username)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                TextField("", text: $login.password)
            }

            HStack(alignment: .center, spacing: 4) {
                Button("Login", action: login.tryLogin).disabled(loginButtonIsDisabled)
                if login.isAttemptingLogin {
                    ProgressView().controlSize(.small)
                }
            }
        }
        .padding(16)
        .frame(width: 240)
    }
}

