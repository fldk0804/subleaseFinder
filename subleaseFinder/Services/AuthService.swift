import Foundation
import Combine

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol: ObservableObject {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    
    func signInAnonymously() async throws -> User
    func signInWithApple() async throws -> User
    func signInWithGoogle() async throws -> User
    func signInWithEmail(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func getIDToken() async throws -> String
    func deleteAccount() async throws
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let email: String?
    let displayName: String?
    let photoURL: String?
    let isAnonymous: Bool
    let createdAt: Date
    
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
        self.photoURL = firebaseUser.photoURL?.absoluteString
        self.isAnonymous = firebaseUser.isAnonymous
        self.createdAt = firebaseUser.metadata.creationDate ?? Date()
    }
    
    #if !canImport(FirebaseAuth)
    // Mock initializer for when Firebase is not available
    init(id: String, email: String?, displayName: String?, photoURL: String?, isAnonymous: Bool, createdAt: Date) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isAnonymous = isAnonymous
        self.createdAt = createdAt
    }
    #endif
}

// MARK: - Auth Service Implementation
class AuthService: AuthServiceProtocol {
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated: Bool = false
    
    #if canImport(FirebaseAuth)
    private var authStateListener: AuthStateDidChangeListenerHandle?
    #endif
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        #if canImport(FirebaseAuth)
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
        #endif
    }
    
    // MARK: - Auth State Management
    private func setupAuthStateListener() {
        #if canImport(FirebaseAuth)
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let firebaseUser = user {
                    self?.currentUser = User(firebaseUser: firebaseUser)
                    self?.isAuthenticated = true
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
        #else
        // Firebase not available - start as unauthenticated
        isAuthenticated = false
        #endif
    }
    
    // MARK: - Sign In Methods
    func signInAnonymously() async throws -> User {
        #if canImport(FirebaseAuth)
        let result = try await Auth.auth().signInAnonymously()
        return User(firebaseUser: result.user)
        #else
        // Fallback to mock authentication
        let user = User(
            id: "mock-user-id",
            email: nil,
            displayName: "Guest User",
            photoURL: nil,
            isAnonymous: true,
            createdAt: Date()
        )
        currentUser = user
        isAuthenticated = true
        return user
        #endif
    }
    
    func signInWithApple() async throws -> User {
        return try await signInAnonymously()
    }
    
    func signInWithGoogle() async throws -> User {
        return try await signInAnonymously()
    }
    
    func signInWithEmail(email: String, password: String) async throws -> User {
        #if canImport(FirebaseAuth)
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return User(firebaseUser: result.user)
        #else
        // Fallback to mock authentication
        let user = User(
            id: "mock-user-id",
            email: email,
            displayName: "Mock User",
            photoURL: nil,
            isAnonymous: false,
            createdAt: Date()
        )
        currentUser = user
        isAuthenticated = true
        return user
        #endif
    }
    
    func signUp(email: String, password: String) async throws -> User {
        return try await signInWithEmail(email: email, password: password)
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        #if canImport(FirebaseAuth)
        try Auth.auth().signOut()
        #else
        // Fallback to mock sign out
        currentUser = nil
        isAuthenticated = false
        #endif
    }
    
    // MARK: - Token Management
    func getIDToken() async throws -> String {
        #if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        return try await user.getIDTokenForcingRefresh(false)
        #else
        // Return mock token
        return "mock-token"
        #endif
    }
    
    // MARK: - Account Management
    func deleteAccount() async throws {
        #if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        try await user.delete()
        #else
        // Fallback to mock account deletion
        currentUser = nil
        isAuthenticated = false
        #endif
    }
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError {
    case userNotFound
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyInUse:
            return "Email is already in use"
        case .weakPassword:
            return "Password is too weak"
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

// MARK: - Mock Auth Service for Preview
class MockAuthService: AuthServiceProtocol {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    func signInAnonymously() async throws -> User {
        let user = User(
            id: "mock-user-id",
            email: nil,
            displayName: "Mock User",
            photoURL: nil,
            isAnonymous: true,
            createdAt: Date()
        )
        currentUser = user
        isAuthenticated = true
        return user
    }
    
    func signInWithApple() async throws -> User {
        return try await signInAnonymously()
    }
    
    func signInWithGoogle() async throws -> User {
        return try await signInAnonymously()
    }
    
    func signInWithEmail(email: String, password: String) async throws -> User {
        let user = User(
            id: "mock-user-id",
            email: email,
            displayName: "Mock User",
            photoURL: nil,
            isAnonymous: false,
            createdAt: Date()
        )
        currentUser = user
        isAuthenticated = true
        return user
    }
    
    func signUp(email: String, password: String) async throws -> User {
        return try await signInWithEmail(email: email, password: password)
    }
    
    func signOut() async throws {
        currentUser = nil
        isAuthenticated = false
    }
    
    func getIDToken() async throws -> String {
        return "mock-token"
    }
    
    func deleteAccount() async throws {
        currentUser = nil
        isAuthenticated = false
    }
}
