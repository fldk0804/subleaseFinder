import Foundation

// MARK: - App Configuration
struct AppConfig {
    static let shared = AppConfig()
    
    // MARK: - Environment
    enum Environment: String, CaseIterable {
        case development = "development"
        case staging = "staging"
        case production = "production"
    }
    
    let environment: Environment
    
    // MARK: - API Configuration
    var apiBaseURL: URL {
        switch environment {
        case .development:
            return URL(string: "https://dev-api.subleasefinder.com")!
        case .staging:
            return URL(string: "https://staging-api.subleasefinder.com")!
        case .production:
            return URL(string: "https://api.subleasefinder.com")!
        }
    }
    
    // MARK: - Firebase Configuration
    var firebaseConfig: FirebaseConfig {
        switch environment {
        case .development:
            return FirebaseConfig(
                projectId: "subleasefinder-dev",
                apiKey: "dev-api-key",
                appId: "dev-app-id"
            )
        case .staging:
            return FirebaseConfig(
                projectId: "subleasefinder-staging",
                apiKey: "staging-api-key",
                appId: "staging-app-id"
            )
        case .production:
            return FirebaseConfig(
                projectId: "subleasefinder-prod",
                apiKey: "prod-api-key",
                appId: "prod-app-id"
            )
        }
    }
    
    // MARK: - Feature Flags
    var featureFlags: FeatureFlags {
        FeatureFlags(
            enableAppleSignIn: true,
            enableGoogleSignIn: true,
            enableAnonymousSignIn: true,
            enableImageCompression: true,
            enableOfflineMode: true,
            enablePushNotifications: true
        )
    }
    
    // MARK: - Cache Configuration
    var cacheConfig: CacheConfig {
        CacheConfig(
            listingCacheTimeout: 5 * 60, // 5 minutes
            detailCacheTimeout: 30 * 60, // 30 minutes
            imageCacheTimeout: 24 * 60 * 60, // 24 hours
            maxCacheSize: 100 * 1024 * 1024 // 100 MB
        )
    }
    
    // MARK: - Network Configuration
    var networkConfig: NetworkConfig {
        NetworkConfig(
            requestTimeout: 30,
            resourceTimeout: 60,
            maxRetries: 3,
            retryDelay: 1.0
        )
    }
    
    // MARK: - Initialization
    private init() {
        // Determine environment from build configuration or environment variable
        #if DEBUG
        self.environment = .development
        #else
        if let envString = ProcessInfo.processInfo.environment["APP_ENVIRONMENT"],
           let env = Environment(rawValue: envString) {
            self.environment = env
        } else {
            self.environment = .production
        }
        #endif
    }
}

// MARK: - Supporting Types
struct FirebaseConfig {
    let projectId: String
    let apiKey: String
    let appId: String
}

struct FeatureFlags {
    let enableAppleSignIn: Bool
    let enableGoogleSignIn: Bool
    let enableAnonymousSignIn: Bool
    let enableImageCompression: Bool
    let enableOfflineMode: Bool
    let enablePushNotifications: Bool
}

struct CacheConfig {
    let listingCacheTimeout: TimeInterval
    let detailCacheTimeout: TimeInterval
    let imageCacheTimeout: TimeInterval
    let maxCacheSize: Int
}

struct NetworkConfig {
    let requestTimeout: TimeInterval
    let resourceTimeout: TimeInterval
    let maxRetries: Int
    let retryDelay: TimeInterval
}

// MARK: - Analytics Events
enum AnalyticsEvent: String {
    case appLaunch = "app_launch"
    case userSignIn = "user_sign_in"
    case userSignUp = "user_sign_up"
    case listingView = "listing_view"
    case listingSearch = "listing_search"
    case listingFilter = "listing_filter"
    case listingFavorite = "listing_favorite"
    case listingContact = "listing_contact"
    case listingCreate = "listing_create"
    case imageUpload = "image_upload"
    case mapView = "map_view"
    case errorOccurred = "error_occurred"
}

// MARK: - Error Tracking
enum ErrorType: String {
    case networkError = "network_error"
    case authenticationError = "authentication_error"
    case validationError = "validation_error"
    case uploadError = "upload_error"
    case cacheError = "cache_error"
    case unknownError = "unknown_error"
}

// MARK: - Constants
struct AppConstants {
    static let appName = "SubleaseFinder"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // UI Constants
    static let cornerRadius: CGFloat = 12
    static let buttonHeight: CGFloat = 44
    static let spacing: CGFloat = 16
    
    // Image Constants
    static let maxImageSize: Int = 10 * 1024 * 1024 // 10 MB
    static let imageCompressionQuality: CGFloat = 0.8
    static let maxImagesPerListing = 10
    
    // Search Constants
    static let searchDebounceTime: TimeInterval = 0.5
    static let maxSearchResults = 50
    
    // Map Constants
    static let defaultMapSpan: Double = 0.1
    static let maxMapAnnotations = 100
}
