import SwiftUI

struct AppShellView: View {
    @StateObject private var appFlow = AppFlow()
    
    var body: some View {
        Group {
            if appFlow.isLoading {
                LoadingView()
            } else if appFlow.showAuthModal {
                AuthModalView(appFlow: appFlow)
            } else {
                MainTabView(appFlow: appFlow)
            }
        }
        .environmentObject(appFlow)
    }
}

struct MainTabView: View {
    @ObservedObject var appFlow: AppFlow
    
    var body: some View {
        TabView(selection: $appFlow.selectedTab) {
            BrowseView()
                .environmentObject(appFlow.browseFlow)
                .environmentObject(appFlow.listingService)
                .tabItem {
                    Label(Tab.browse.title, systemImage: Tab.browse.icon)
                }
                .tag(Tab.browse)
            
            PostView()
                .environmentObject(appFlow.postFlow)
                .environmentObject(appFlow.authService)
                .tabItem {
                    Label(Tab.post.title, systemImage: Tab.post.icon)
                }
                .tag(Tab.post)
            
            SavedView()
                .environmentObject(appFlow.savedFlow)
                .environmentObject(appFlow.listingService)
                .tabItem {
                    Label(Tab.saved.title, systemImage: Tab.saved.icon)
                }
                .tag(Tab.saved)
            
            ProfileView()
                .environmentObject(appFlow.profileFlow)
                .environmentObject(appFlow.authService)
                .tabItem {
                    Label(Tab.profile.title, systemImage: Tab.profile.icon)
                }
                .tag(Tab.profile)
        }
        .accentColor(.blue)
    }
}

// MARK: - Auth Modal View
struct AuthModalView: View {
    @ObservedObject var appFlow: AppFlow
    @State private var showSignIn = false
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo/Title
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("SubleaseFinder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Find your perfect sublease")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Auth Options
                VStack(spacing: 16) {
                    Button("Continue as Guest") {
                        Task {
                            do {
                                _ = try await appFlow.authService.signInAnonymously()
                            } catch {
                                print("Error signing in anonymously: \(error)")
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button("Sign In") {
                        showSignIn = true
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Create Account") {
                        showSignUp = true
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSignIn) {
            SignInView(appFlow: appFlow)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(appFlow: appFlow)
        }
    }
}

// MARK: - Sign In View
struct SignInView: View {
    @ObservedObject var appFlow: AppFlow
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button("Sign In") {
                    signIn()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                
                if isLoading {
                    ProgressView()
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private func signIn() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                _ = try await appFlow.authService.signInWithEmail(email: email, password: password)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Sign Up View
struct SignUpView: View {
    @ObservedObject var appFlow: AppFlow
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button("Create Account") {
                    signUp()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword || isLoading)
                
                if isLoading {
                    ProgressView()
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                _ = try await appFlow.authService.signUp(email: email, password: password)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview
struct AppShellView_Previews: PreviewProvider {
    static var previews: some View {
        AppShellView()
    }
}
