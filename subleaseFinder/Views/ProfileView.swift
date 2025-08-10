import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileFlow: ProfileFlow
    @EnvironmentObject var authService: AuthServiceProtocol
    
    var body: some View {
        NavigationView {
            Group {
                if authService.isAuthenticated {
                    AuthenticatedProfileView()
                        .environmentObject(profileFlow)
                        .environmentObject(authService)
                } else {
                    UnauthenticatedProfileView()
                        .environmentObject(authService)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Authenticated Profile View
struct AuthenticatedProfileView: View {
    @EnvironmentObject var profileFlow: ProfileFlow
    @EnvironmentObject var authService: AuthServiceProtocol
    
    var body: some View {
        List {
            // User Info Section
            Section {
                UserInfoRow(user: authService.currentUser)
            }
            
            // Account Section
            Section("Account") {
                Button(action: { profileFlow.showSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
                
                Button(action: { profileFlow.showSignOutAlert = true }) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
            
            // Support Section
            Section("Support") {
                Button(action: {}) {
                    Label("Help & FAQ", systemImage: "questionmark.circle")
                }
                
                Button(action: {}) {
                    Label("Contact Support", systemImage: "envelope")
                }
                
                Button(action: {}) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                
                Button(action: {}) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            }
            
            // App Info Section
            Section("App") {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(isPresented: $profileFlow.showSettings) {
            SettingsView()
        }
        .alert("Sign Out", isPresented: $profileFlow.showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                profileFlow.confirmSignOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Unauthenticated Profile View
struct UnauthenticatedProfileView: View {
    @EnvironmentObject var authService: AuthServiceProtocol
    @State private var showSignIn = false
    @State private var showSignUp = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Logo/Title
            VStack(spacing: 16) {
                Image(systemName: "person.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Welcome to SubleaseFinder")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Sign in to manage your account and listings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Auth Buttons
            VStack(spacing: 16) {
                Button("Sign In") {
                    showSignIn = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                Button("Create Account") {
                    showSignUp = true
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                
                Button("Continue as Guest") {
                    Task {
                        do {
                            _ = try await authService.signInAnonymously()
                        } catch {
                            print("Error signing in anonymously: \(error)")
                        }
                    }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .sheet(isPresented: $showSignIn) {
            SignInSheetView()
                .environmentObject(authService)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpSheetView()
                .environmentObject(authService)
        }
    }
}

// MARK: - User Info Row
struct UserInfoRow: View {
    let user: User?
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let photoURL = user?.photoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.secondary)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
            }
            
            // User Details
            VStack(alignment: .leading, spacing: 4) {
                Text(user?.displayName ?? "Guest User")
                    .font(.headline)
                
                if let email = user?.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if user?.isAnonymous == true {
                    Text("Guest Account")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("locationServicesEnabled") private var locationServicesEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("New Listing Alerts", isOn: $notificationsEnabled)
                    Toggle("Message Notifications", isOn: $notificationsEnabled)
                }
                
                Section("Location") {
                    Toggle("Location Services", isOn: $locationServicesEnabled)
                    Text("Used to show nearby listings and provide location-based search")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("Data & Privacy") {
                    Button("Clear Cache") {
                        // Clear app cache
                    }
                    
                    Button("Export Data") {
                        // Export user data
                    }
                    
                    Button("Delete Account") {
                        // Show delete account confirmation
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") { dismiss() }
            )
        }
    }
}

// MARK: - Sign In Sheet View
struct SignInSheetView: View {
    @EnvironmentObject var authService: AuthServiceProtocol
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
                _ = try await authService.signInWithEmail(email: email, password: password)
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

// MARK: - Sign Up Sheet View
struct SignUpSheetView: View {
    @EnvironmentObject var authService: AuthServiceProtocol
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
                _ = try await authService.signUp(email: email, password: password)
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
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ProfileFlow(authService: MockAuthService()))
            .environmentObject(MockAuthService())
    }
}
