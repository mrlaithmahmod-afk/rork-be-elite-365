import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @State private var authService = AuthService()
    @AppStorage("isSignedIn") private var isSignedIn = false
    @State private var showEmailAuth = false
    @State private var showSignIn = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 52, weight: .thin))
                        .foregroundStyle(AppTheme.gold)

                    VStack(spacing: 6) {
                        Text("BE ELITE 365")
                            .font(.system(size: 28, weight: .black))
                            .tracking(4)

                        Rectangle()
                            .fill(AppTheme.gold)
                            .frame(width: 40, height: 2)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                VStack(spacing: 8) {
                    Text("Clarity. Control. Consistency.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.gold)

                    Text("Build unshakable confidence by learning to\nReset, Regroup, Refocus under pressure.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
            }

            Spacer()

            VStack(spacing: 12) {
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    authService.handleAppleSignIn(result: result)
                    if authService.isAuthenticated {
                        isSignedIn = true
                    }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 52)
                .clipShape(.rect(cornerRadius: 12))

                Button {
                    showEmailAuth = true
                } label: {
                    Text("Continue with Email")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                }

                Button {
                    showSignIn = true
                } label: {
                    Text("Sign In")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .padding(.horizontal, 24)

            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    Button("Terms") {}
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Button("Privacy") {}
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text("Mental performance training. Not medical advice.")
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.smooth(duration: 0.8).delay(0.2)) {
                appeared = true
            }
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView(isSignIn: false) {
                isSignedIn = true
            }
        }
        .sheet(isPresented: $showSignIn) {
            EmailAuthView(isSignIn: true) {
                isSignedIn = true
            }
        }
    }
}

struct EmailAuthView: View {
    @Environment(\.dismiss) private var dismiss
    let isSignIn: Bool
    let onComplete: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var authService = AuthService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("EMAIL")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("", text: $email, prompt: Text("your@email.com").foregroundStyle(.white.opacity(0.3)))
                            .font(.body)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("PASSWORD")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        SecureField("", text: $password, prompt: Text("Password").foregroundStyle(.white.opacity(0.3)))
                            .font(.body)
                            .textContentType(isSignIn ? .password : .newPassword)
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }

                Button {
                    authService.signInWithEmail(email: email, password: password)
                    onComplete()
                    dismiss()
                } label: {
                    Text(isSignIn ? "Sign In" : "Create Account")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSubmit ? AppTheme.gold : AppTheme.gold.opacity(0.3))
                        .clipShape(.rect(cornerRadius: 12))
                }
                .disabled(!canSubmit)

                if isSignIn {
                    Button("Forgot Password?") {}
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .background(Color(.systemBackground))
            .navigationTitle(isSignIn ? "Sign In" : "Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }
}
