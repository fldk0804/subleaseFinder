//
//  ContentView.swift
//  subleaseFinder
//
//  Created by Lya Mun on 6/4/25.
//

import SwiftUI
import MapKit
import Combine

// MARK: - Models
struct SubleaseListing: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let price: Decimal
    let currency: String
    let location: String
    let latitude: Double
    let longitude: Double
    let startDate: Date
    let endDate: Date
    let numberOfBedrooms: Int
    let numberOfBathrooms: Double
    let squareFootage: Int?
    let propertyType: PropertyType
    let amenities: [String]
    let hasRoommates: Bool
    let images: [String] // URLs
    let coverImageIndex: Int
    let listerId: String
    let listerName: String
    let createdAt: Date
    let updatedAt: Date
    let isActive: Bool
    
    enum PropertyType: String, Codable, CaseIterable {
        case apartment = "apartment"
        case house = "house"
        case condo = "condo"
        case studio = "studio"
        case shared = "shared"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: price as NSDecimalNumber) ?? "$\(price)"
    }
    
    var durationText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

struct User: Codable, Equatable {
    let id: String
    let email: String
    let name: String?
    let photoURL: String?
    
    init(id: String, email: String, name: String? = nil, photoURL: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.photoURL = photoURL
    }
}

// MARK: - Sample Data
struct SampleData {
    static let listings: [SubleaseListing] = [
        SubleaseListing(
            id: "1",
            title: "Modern 2BR Apartment in Downtown",
            description: "Beautiful modern apartment with stunning city views. Recently renovated with high-end appliances and amenities.",
            price: 2800,
            currency: "USD",
            location: "San Francisco, CA",
            latitude: 37.7749,
            longitude: -122.4194,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date(),
            numberOfBedrooms: 2,
            numberOfBathrooms: 2.0,
            squareFootage: 1200,
            propertyType: .apartment,
            amenities: ["Gym", "Pool", "Parking", "Balcony"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800",
                "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user1",
            listerName: "Sarah Johnson",
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        ),
        SubleaseListing(
            id: "2",
            title: "Cozy Studio Near UC Berkeley",
            description: "Perfect for students! Walking distance to campus with all utilities included.",
            price: 1800,
            currency: "USD",
            location: "Berkeley, CA",
            latitude: 37.8716,
            longitude: -122.2727,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date(),
            numberOfBedrooms: 0,
            numberOfBathrooms: 1.0,
            squareFootage: 500,
            propertyType: .studio,
            amenities: ["Utilities Included", "WiFi", "Laundry"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user2",
            listerName: "Mike Chen",
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        ),
        SubleaseListing(
            id: "3",
            title: "Luxury 3BR House in Palo Alto",
            description: "Spacious family home with backyard and garage. Perfect for professionals.",
            price: 4500,
            currency: "USD",
            location: "Palo Alto, CA",
            latitude: 37.4419,
            longitude: -122.1430,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()) ?? Date(),
            numberOfBedrooms: 3,
            numberOfBathrooms: 2.5,
            squareFootage: 2000,
            propertyType: .house,
            amenities: ["Backyard", "Garage", "Fireplace", "Hardwood Floors"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800",
                "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user3",
            listerName: "Emily Rodriguez",
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        ),
        SubleaseListing(
            id: "4",
            title: "Shared Room in Student Housing",
            description: "Friendly roommate wanted! Great location near Stanford campus.",
            price: 1200,
            currency: "USD",
            location: "Stanford, CA",
            latitude: 37.4275,
            longitude: -122.1697,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 5, to: Date()) ?? Date(),
            numberOfBedrooms: 1,
            numberOfBathrooms: 1.0,
            squareFootage: 800,
            propertyType: .shared,
            amenities: ["Kitchen", "Living Room", "WiFi", "Utilities"],
            hasRoommates: true,
            images: [
                "https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user4",
            listerName: "Alex Thompson",
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        ),
        SubleaseListing(
            id: "5",
            title: "Waterfront Condo in Sausalito",
            description: "Stunning waterfront views! Modern condo with marina access.",
            price: 3200,
            currency: "USD",
            location: "Sausalito, CA",
            latitude: 37.8591,
            longitude: -122.4853,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 7, to: Date()) ?? Date(),
            numberOfBedrooms: 2,
            numberOfBathrooms: 2.0,
            squareFootage: 1400,
            propertyType: .condo,
            amenities: ["Waterfront", "Marina Access", "Gym", "Pool"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user5",
            listerName: "David Kim",
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        ),
        SubleaseListing(
            id: "6",
            title: "Tech Hub Apartment in Mountain View",
            description: "Perfect for tech professionals! Walking distance to major companies.",
            price: 2600,
            currency: "USD",
            location: "Mountain View, CA",
            latitude: 37.3861,
            longitude: -122.0839,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date(),
            numberOfBedrooms: 1,
            numberOfBathrooms: 1.0,
            squareFootage: 900,
            propertyType: .apartment,
            amenities: ["Tech Hub", "Shuttle Service", "Gym", "Rooftop Deck"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user6",
            listerName: "Lisa Wang",
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        )
    ]
}

// MARK: - Services
protocol AuthServiceProtocol: ObservableObject {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
    func signInAnonymously() async throws -> User
    func signInWithEmail(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
}

class AuthService: AuthServiceProtocol {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    func signInAnonymously() async throws -> User {
        let user = User(id: "guest", email: "guest@example.com", name: "Guest User")
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
        }
        return user
    }
    
    func signInWithEmail(email: String, password: String) async throws -> User {
        let user = User(id: "user", email: email, name: email.components(separatedBy: "@").first)
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
        }
        return user
    }
    
    func signUp(email: String, password: String) async throws -> User {
        let user = User(id: "newuser", email: email, name: email.components(separatedBy: "@").first)
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
        }
        return user
    }
    
    func signOut() async throws {
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
}

protocol ListingServiceProtocol: ObservableObject {
    var listings: [SubleaseListing] { get }
    func fetchListings() async throws -> [SubleaseListing]
    func toggleFavorite(_ listing: SubleaseListing) async throws
}

class ListingService: ListingServiceProtocol {
    @Published var listings: [SubleaseListing] = []
    
    func fetchListings() async throws -> [SubleaseListing] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            self.listings = SampleData.listings
        }
        return SampleData.listings
    }
    
    func toggleFavorite(_ listing: SubleaseListing) async throws {
        // Mock implementation
        print("Toggled favorite for listing: \(listing.title)")
    }
}

// MARK: - App Flow
class AppFlow: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var showAuthModal = false
    @Published var isLoading = true
    
    let authService: AuthService
    let listingService: ListingService
    
    init() {
        self.authService = AuthService()
        self.listingService = ListingService()
        
        // Simulate initial loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.isLoading = false
            }
            
            if !self.authService.isAuthenticated {
                self.showAuthModal = true
            }
        }
        
        // Load sample data
        Task {
            do {
                _ = try await self.listingService.fetchListings()
            } catch {
                print("Error loading listings: \(error)")
            }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
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

// LoadingView is defined in Views/LoadingView.swift

// MARK: - Main Tab View
struct MainTabView: View {
    @ObservedObject var appFlow: AppFlow
    
    var body: some View {
        TabView(selection: $appFlow.selectedTab) {
            BrowseView()
                .environmentObject(appFlow.listingService)
                .tabItem {
                    Label("Browse", systemImage: "list.bullet")
                }
                .tag(0)
            
            PostView()
                .environmentObject(appFlow.authService)
                .tabItem {
                    Label("Post", systemImage: "plus.circle")
                }
                .tag(1)
            
            SavedView()
                .environmentObject(appFlow.listingService)
                .tabItem {
                    Label("Saved", systemImage: "heart")
                }
                .tag(2)
            
            ProfileView()
                .environmentObject(appFlow.authService)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

// MARK: - Browse View (Improved)
struct BrowseView: View {
    @EnvironmentObject var listingService: ListingService
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var viewMode: ViewMode = .list
    @State private var selectedFilters: [String: Any] = [:]
    
    enum ViewMode {
        case list, map
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Header with Search (Compact)
                VStack(spacing: 12) {
                    // Search Bar
                    HStack(spacing: 10) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .medium))
                            
                            TextField("Search listings...", text: $searchText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        Button(action: { showFilters = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // View Mode Toggle with Count
                    HStack {
                        // Enhanced Segmented Control
                        HStack(spacing: 0) {
                            Button(action: { viewMode = .list }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 12, weight: .medium))
                                    Text("List")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(viewMode == .list ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewMode == .list ? Color.blue : Color.clear)
                                .cornerRadius(6)
                            }
                            
                            Button(action: { viewMode = .map }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "map")
                                        .font(.system(size: 12, weight: .medium))
                                    Text("Map")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(viewMode == .map ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewMode == .map ? Color.blue : Color.clear)
                                .cornerRadius(6)
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        // Property Count
                        Text("\(listingService.listings.count) properties")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // Content
                if viewMode == .map {
                    MapView(listings: listingService.listings)
                } else {
                    ListView(listings: listingService.listings)
                }
            }
            .navigationTitle("Browse")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showFilters) {
                FilterView(filters: $selectedFilters)
            }
        }
    }
}

// MARK: - Enhanced List View
struct ListView: View {
    let listings: [SubleaseListing]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(listings) { listing in
                    EnhancedListingCard(listing: listing)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Enhanced Listing Card
struct EnhancedListingCard: View {
    let listing: SubleaseListing
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: listing.images[listing.coverImageIndex])) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "house.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        )
                }
                .frame(height: 120)
                .clipped()
                
                // Favorite Button
                Button(action: { isFavorite.toggle() }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(6)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            // Content Section
            VStack(alignment: .leading, spacing: 6) {
                // Price and Type
                HStack {
                    Text(listing.formattedPrice)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(listing.propertyType.rawValue.capitalized)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
                
                // Title
                Text(listing.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Details
                HStack(spacing: 8) {
                    Label("\(listing.numberOfBedrooms)", systemImage: "bed.double")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Label("\(listing.numberOfBathrooms)", systemImage: "shower")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if let squareFootage = listing.squareFootage {
                        Label("\(squareFootage)", systemImage: "square")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Location
                HStack {
                    Image(systemName: "location")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text(listing.location)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Amenities Preview (only show if space allows)
                if !listing.amenities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(Array(listing.amenities.prefix(2)), id: \.self) { amenity in
                                Text(amenity)
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(3)
                            }
                            
                            if listing.amenities.count > 2 {
                                Text("+\(listing.amenities.count - 2)")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(10)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Filter View
struct FilterView: View {
    @Binding var filters: [String: Any]
    @Environment(\.dismiss) private var dismiss
    
    @State private var minPrice = ""
    @State private var maxPrice = ""
    @State private var selectedBedrooms = 0
    @State private var selectedPropertyType = "All"
    
    let propertyTypes = ["All", "Apartment", "House", "Condo", "Studio", "Shared"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Price Range
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Range")
                        .font(.system(size: 18, weight: .semibold))
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Min")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TextField("$0", text: $minPrice)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Max")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TextField("$5000", text: $maxPrice)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                    }
                }
                
                // Bedrooms
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bedrooms")
                        .font(.system(size: 18, weight: .semibold))
                    
                    HStack(spacing: 8) {
                        ForEach(0...4, id: \.self) { count in
                            Button(action: { selectedBedrooms = count }) {
                                Text(count == 0 ? "Studio" : "\(count)+")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedBedrooms == count ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedBedrooms == count ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Property Type
                VStack(alignment: .leading, spacing: 12) {
                    Text("Property Type")
                        .font(.system(size: 18, weight: .semibold))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(propertyTypes, id: \.self) { type in
                            Button(action: { selectedPropertyType = type }) {
                                Text(type)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedPropertyType == type ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedPropertyType == type ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Apply Button
                Button("Apply Filters") {
                    // Apply filters logic here
                    dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Reset") {
                    minPrice = ""
                    maxPrice = ""
                    selectedBedrooms = 0
                    selectedPropertyType = "All"
                }
            )
        }
    }
}

// MARK: - Enhanced Map View
struct MapView: View {
    let listings: [SubleaseListing]
    @State private var selectedListing: SubleaseListing?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ZStack {
            Map {
                ForEach(listings) { listing in
                    Annotation(listing.title, coordinate: listing.coordinate) {
                        VStack(spacing: 0) {
                            // Custom Marker
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 32, height: 32)
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "house.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            // Price Tag
                            Text(listing.formattedPrice)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(6)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                        .onTapGesture {
                            selectedListing = listing
                        }
                    }
                }
            }
            .mapStyle(.standard)
            
            // Selected Property Card (Compact)
            if let listing = selectedListing {
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Image
                        AsyncImage(url: URL(string: listing.images[listing.coverImageIndex])) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(.systemGray5))
                        }
                        .frame(height: 80)
                        .clipped()
                        .cornerRadius(8)
                        
                        // Details
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(listing.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Button("×") {
                                    selectedListing = nil
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.secondary)
                            }
                            
                            Text(listing.formattedPrice)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                            
                            HStack(spacing: 8) {
                                Label("\(listing.numberOfBedrooms)", systemImage: "bed.double")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Label("\(listing.numberOfBathrooms)", systemImage: "shower")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button("Details") {
                                    // Navigate to details
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: selectedListing != nil)
            }
        }
    }
}

// MARK: - Post View
struct PostView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showAuthRequired = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Post a Sublease")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Create a new listing to find your perfect tenant")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Start Creating") {
                    if authService.isAuthenticated {
                        // Show post wizard
                    } else {
                        showAuthRequired = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.large)
            .alert("Authentication Required", isPresented: $showAuthRequired) {
                Button("OK") { }
            } message: {
                Text("Please sign in to post a listing.")
            }
        }
    }
}

// MARK: - Saved View
struct SavedView: View {
    @EnvironmentObject var listingService: ListingService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "heart")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Saved Listings")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your favorite listings will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showSignIn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if authService.isAuthenticated {
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(authService.currentUser?.name ?? "User")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(authService.currentUser?.email ?? "")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Sign Out") {
                            Task {
                                do {
                                    try await authService.signOut()
                                } catch {
                                    print("Error signing out: \(error)")
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Not Signed In")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Button("Sign In") {
                            showSignIn = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSignIn) {
                SignInView()
            }
        }
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
                                // Hide the auth modal after successful guest sign in
                                await MainActor.run {
                                    appFlow.showAuthModal = false
                                }
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
            SignInView()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
}

// MARK: - Sign In View
struct SignInView: View {
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
                _ = try await AuthService().signInWithEmail(email: email, password: password)
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
                _ = try await AuthService().signUp(email: email, password: password)
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
