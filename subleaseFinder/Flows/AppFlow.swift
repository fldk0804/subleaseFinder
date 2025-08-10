import SwiftUI
import Combine

// MARK: - App Flow Coordinator
class AppFlow: ObservableObject {
    @Published var selectedTab: Tab = .browse
    @Published var showAuthModal = false
    @Published var isLoading = true
    
    // Services
    let authService: AuthServiceProtocol
    let listingService: ListingServiceProtocol
    let uploadService: UploadServiceProtocol
    
    // Child flows
    @Published var browseFlow: BrowseFlow
    @Published var postFlow: PostFlow
    @Published var savedFlow: SavedFlow
    @Published var profileFlow: ProfileFlow
    
    // State
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize services
        let authService = AuthService() // Use real AuthService with Firebase fallback
        
        let apiClient = APIClient(
            baseURL: AppConfig.shared.apiBaseURL,
            authService: authService
        )
        
        let cache = ListingCache()
        let uploadService = UploadService(apiClient: apiClient)
        let listingService = ListingService(
            apiClient: apiClient,
            cache: cache,
            uploadService: uploadService
        )
        
        self.authService = authService
        self.listingService = listingService
        self.uploadService = uploadService
        
        // Initialize child flows
        self.browseFlow = BrowseFlow(listingService: listingService)
        self.postFlow = PostFlow(listingService: listingService, uploadService: uploadService)
        self.savedFlow = SavedFlow(listingService: listingService)
        self.profileFlow = ProfileFlow(authService: authService)
        
        // Initialize with sample data for demo
        Task {
            await browseFlow.refreshListings()
        }
        
        setupBindings()
        checkInitialAuthState()
    }
    
    private func setupBindings() {
        // Monitor auth state changes
        authService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                DispatchQueue.main.async {
                    self?.handleAuthStateChange(isAuthenticated: isAuthenticated)
                }
            }
            .store(in: &cancellables)
        
        // Monitor auth errors
        authService.$currentUser
            .sink { [weak self] user in
                DispatchQueue.main.async {
                    if user == nil && self?.authService.isAuthenticated == false {
                        self?.showAuthModal = true
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkInitialAuthState() {
        // Simulate initial loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.isLoading = false
            }
            
            if !self.authService.isAuthenticated {
                self.showAuthModal = true
            }
        }
    }
    
    private func handleAuthStateChange(isAuthenticated: Bool) {
        if isAuthenticated {
            showAuthModal = false
            // Refresh data when user signs in
            Task {
                await browseFlow.refreshListings()
                await savedFlow.refreshFavorites()
            }
        } else {
            // Clear sensitive data on sign out
            listingService.clearCache()
            browseFlow.clearState()
            postFlow.clearState()
            savedFlow.clearState()
        }
    }
    
    func signOut() {
        Task {
            do {
                try await authService.signOut()
            } catch {
                print("Error signing out: \(error)")
            }
        }
    }
}

// MARK: - Tab Enum
enum Tab: Int, CaseIterable {
    case browse = 0
    case post = 1
    case saved = 2
    case profile = 3
    
    var title: String {
        switch self {
        case .browse: return "Browse"
        case .post: return "Post"
        case .saved: return "Saved"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .browse: return "list.bullet"
        case .post: return "plus.circle"
        case .saved: return "heart"
        case .profile: return "person"
        }
    }
}

// MARK: - Browse Flow
class BrowseFlow: ObservableObject {
    @Published var searchText = ""
    @Published var selectedFilters = ListingFilters()
    @Published var viewMode: ViewMode = .map
    @Published var selectedListing: SubleaseListing?
    @Published var showListingDetail = false
    
    private let listingService: ListingServiceProtocol
    private var searchTask: Task<Void, Never>?
    
    enum ViewMode {
        case list, map
    }
    
    init(listingService: ListingServiceProtocol) {
        self.listingService = listingService
    }
    
    func refreshListings() async {
        let query = ListingQuery(
            bbox: nil,
            searchText: searchText.isEmpty ? nil : searchText,
            priceMin: selectedFilters.priceMin,
            priceMax: selectedFilters.priceMax,
            bedrooms: selectedFilters.bedrooms,
            propertyType: selectedFilters.propertyType,
            startDate: selectedFilters.startDate,
            endDate: selectedFilters.endDate,
            sortBy: selectedFilters.sortBy,
            sortOrder: selectedFilters.sortOrder,
            limit: 50,
            offset: 0
        )
        
        do {
            _ = try await listingService.fetchListings(query: query)
        } catch {
            print("Error fetching listings: \(error)")
        }
    }
    
    func searchListings() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
            if !Task.isCancelled {
                await refreshListings()
            }
        }
    }
    
    func selectListing(_ listing: SubleaseListing) {
        selectedListing = listing
        showListingDetail = true
    }
    
    func clearState() {
        searchText = ""
        selectedFilters = ListingFilters()
        selectedListing = nil
        showListingDetail = false
    }
}

// MARK: - Post Flow
class PostFlow: ObservableObject {
    @Published var currentStep = 0
    @Published var draft = ListingDraft()
    @Published var isPublishing = false
    @Published var showSuccess = false
    
    private let listingService: ListingServiceProtocol
    private let uploadService: UploadServiceProtocol
    
    init(listingService: ListingServiceProtocol, uploadService: UploadServiceProtocol) {
        self.listingService = listingService
        self.uploadService = uploadService
    }
    
    func nextStep() {
        if currentStep < 3 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func publishListing() async {
        isPublishing = true
        
        do {
            // Upload images first
            let imageUrls = try await uploadService.uploadImages(
                draft.selectedImages,
                contentType: "image/jpeg"
            )
            
            // Create listing request
            let request = CreateListingRequest(
                title: draft.title,
                description: draft.description,
                price: draft.price,
                currency: "USD",
                location: draft.location,
                latitude: draft.latitude,
                longitude: draft.longitude,
                startDate: draft.startDate,
                endDate: draft.endDate,
                numberOfBedrooms: draft.bedrooms,
                numberOfBathrooms: draft.bathrooms,
                squareFootage: draft.squareFootage,
                propertyType: draft.propertyType,
                amenities: draft.amenities,
                hasRoommates: draft.hasRoommates,
                images: imageUrls
            )
            
            _ = try await listingService.createListing(request)
            
            await MainActor.run {
                self.showSuccess = true
                self.isPublishing = false
            }
        } catch {
            await MainActor.run {
                self.isPublishing = false
            }
            print("Error publishing listing: \(error)")
        }
    }
    
    func clearState() {
        currentStep = 0
        draft = ListingDraft()
        isPublishing = false
        showSuccess = false
    }
}

// MARK: - Saved Flow
class SavedFlow: ObservableObject {
    @Published var favoriteListings: [SubleaseListing] = []
    @Published var isLoading = false
    
    private let listingService: ListingServiceProtocol
    
    init(listingService: ListingServiceProtocol) {
        self.listingService = listingService
    }
    
    func refreshFavorites() async {
        isLoading = true
        
        // In a real app, you'd fetch favorites from the API
        // For now, we'll use the main listings as favorites
        let query = ListingQuery(
            bbox: nil,
            searchText: nil,
            priceMin: nil,
            priceMax: nil,
            bedrooms: nil,
            propertyType: nil,
            startDate: nil,
            endDate: nil,
            sortBy: .createdAt,
            sortOrder: .descending,
            limit: 20,
            offset: 0
        )
        
        do {
            let response = try await listingService.fetchListings(query: query)
            await MainActor.run {
                self.favoriteListings = response.listings
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func clearState() {
        favoriteListings = []
        isLoading = false
    }
}

// MARK: - Profile Flow
class ProfileFlow: ObservableObject {
    @Published var showSettings = false
    @Published var showSignOutAlert = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func signOut() {
        showSignOutAlert = true
    }
    
    func confirmSignOut() {
        Task {
            do {
                try await authService.signOut()
            } catch {
                print("Error signing out: \(error)")
            }
        }
    }
}

// MARK: - Supporting Models
struct ListingFilters {
    var priceMin: Decimal?
    var priceMax: Decimal?
    var bedrooms: Int?
    var propertyType: SubleaseListing.PropertyType?
    var startDate: Date?
    var endDate: Date?
    var sortBy: ListingQuery.SortOption = .createdAt
    var sortOrder: ListingQuery.SortOrder = .descending
}

struct ListingDraft {
    var title = ""
    var description = ""
    var price: Decimal = 0
    var location = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var startDate = Date()
    var endDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
    var bedrooms = 1
    var bathrooms: Double = 1.0
    var squareFootage: Int?
    var propertyType: SubleaseListing.PropertyType = .apartment
    var amenities: [String] = []
    var hasRoommates = false
    var selectedImages: [Data] = []
}
