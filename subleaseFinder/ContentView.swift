//
//  ContentView.swift
//  subleaseFinder
//
//  Created by Lya Mun on 6/4/25.
//

import SwiftUI
import Foundation
import MapKit
import PhotosUI

enum UserIntent {
    case lookingForSublease, lookingToSublease
}

// MARK: - Models
struct SubleaseListing: Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let price: String
    let description: String
    let listerEmail: String
    let imageName: String
    let coordinates: CLLocationCoordinate2D
    let startDate: Date
    let endDate: Date
    let amenities: [String]
    let squareFootage: Int
    let numberOfBedrooms: Int
    let numberOfBathrooms: Double
    let propertyType: String
    let hasRoommates: Bool
}

// MARK: - Main View
struct ContentView: View {
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var isAuthenticated = false
    @State private var showAuthModal = true
    @State private var isPosting = false
    @State private var userIntent: UserIntent? = nil
    @State private var showProfileMenu = false
    
    enum FilterOption {
        case all, available, priceLowToHigh, priceHighToLow
    }
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if showAuthModal {
                UserIntentModal(userIntent: $userIntent, showModal: $showAuthModal)
            } else {
                MainTabView(searchText: $searchText, selectedFilter: $selectedFilter, isPosting: $isPosting, userIntent: userIntent, isAuthenticated: $isAuthenticated, showProfileMenu: $showProfileMenu)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                isLoading = false
                }
            }
        }
    }
}

struct MainTabView: View {
    @Binding var searchText: String
    @Binding var selectedFilter: ContentView.FilterOption
    @Binding var isPosting: Bool
    var userIntent: UserIntent?
    @Binding var isAuthenticated: Bool
    @Binding var showProfileMenu: Bool
    @State private var selectedTab = 0
    @State private var favoriteListings: Set<UUID> = []
    @State private var showFavorites = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ListingsFeedView(
                listings: sampleListings,
                searchText: $searchText,
                selectedFilter: $selectedFilter,
                isAuthenticated: $isAuthenticated,
                isPosting: $isPosting,
                showProfileMenu: $showProfileMenu,
                favoriteListings: $favoriteListings
            )
            .tabItem {
                Label("Listings", systemImage: "list.bullet")
            }
            .tag(0)
            
            MapListingsView(listings: sampleListings)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)
            
            ProfileMenu(
                isAuthenticated: $isAuthenticated,
                showProfileMenu: $showProfileMenu,
                selectedTab: $selectedTab,
                showFavorites: $showFavorites
            )
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(2)
        }
        .sheet(isPresented: $showFavorites) {
            NavigationView {
                if favoriteListings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Favorites Yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Swipe left on listings to add them to favorites")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List(sampleListings.filter { favoriteListings.contains($0.id) }) { listing in
                        NavigationLink(destination: SubleaseDetailView(listing: listing)) {
                            ListingRowView(listing: listing)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                favoriteListings.remove(listing.id)
                            } label: {
                                Label("Remove", systemImage: "heart.slash.fill")
                            }
                        }
                    }
                    .navigationTitle("Favorites")
                }
            }
        }
        .onChange(of: showProfileMenu) { newValue in
            if newValue {
                selectedTab = 2 // Switch to profile tab
            }
        }
    }
}

// MARK: - Listings Feed View
struct ListingsFeedView: View {
    let listings: [SubleaseListing]
    @Binding var searchText: String
    @Binding var selectedFilter: ContentView.FilterOption
    @Binding var isAuthenticated: Bool
    @Binding var isPosting: Bool
    @Binding var showProfileMenu: Bool
    @Binding var favoriteListings: Set<UUID>
    
    var filteredListings: [SubleaseListing] {
        listings.filter { listing in
            let matchesSearch = searchText.isEmpty ||
                listing.title.localizedCaseInsensitiveContains(searchText) ||
                listing.location.localizedCaseInsensitiveContains(searchText)
            
            switch selectedFilter {
            case .all:
                return matchesSearch
            case .available:
                return matchesSearch && listing.startDate > Date()
            case .priceLowToHigh:
                return matchesSearch
            case .priceHighToLow:
                return matchesSearch
            }
        }
        .sorted { first, second in
            switch selectedFilter {
            case .priceLowToHigh:
                return first.price < second.price
            case .priceHighToLow:
                return first.price > second.price
            default:
                return true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search listings...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Menu {
                        Button("All", action: { selectedFilter = .all })
                        Button("Available Now", action: { selectedFilter = .available })
                        Button("Price: Low to High", action: { selectedFilter = .priceLowToHigh })
                        Button("Price: High to Low", action: { selectedFilter = .priceHighToLow })
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                if filteredListings.isEmpty {
                    VStack(spacing: 12) {
                        Text("No listings found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        Section {
                            Text(isAuthenticated ? "Swipe left to add to favorites" : "Log in to save your favorite listings")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 4)
                        }
                        
                        ForEach(filteredListings) { listing in
                NavigationLink(destination: SubleaseDetailView(listing: listing)) {
                                ListingRowView(listing: listing)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    if isAuthenticated {
                                        if favoriteListings.contains(listing.id) {
                                            favoriteListings.remove(listing.id)
                                        } else {
                                            favoriteListings.insert(listing.id)
                                        }
                                    } else {
                                        showProfileMenu = true
                                    }
                                } label: {
                                    Label(
                                        favoriteListings.contains(listing.id) ? "Remove" : "Favorite",
                                        systemImage: favoriteListings.contains(listing.id) ? "heart.slash.fill" : "heart.fill"
                                    )
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isAuthenticated {
                            isPosting = true
                        } else {
                            showProfileMenu = true
                        }
                    }) {
                    HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Post")
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .sheet(isPresented: $isPosting) {
                PostSubleaseView(isPresented: $isPosting)
            }
        }
    }
}

// MARK: - Listing Row View
struct ListingRowView: View {
    let listing: SubleaseListing
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: listing.imageName)
                            .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.headline)
                    .lineLimit(1)
                
                // Split location into two lines
                let locationComponents = listing.location.components(separatedBy: ", ")
                if locationComponents.count >= 2 {
                    Text(locationComponents[0])
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(locationComponents[1...].joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text(listing.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(listing.price)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .bold()
                    
                    Spacer()
                    
                    Text("\(listing.numberOfBedrooms) bed • \(Int(listing.numberOfBathrooms)) bath")
                        .font(.caption)
                        .foregroundColor(.secondary)
        }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Detail View
struct SubleaseDetailView: View {
    let listing: SubleaseListing
    @State private var showingContactSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image
            Image(systemName: listing.imageName)
                .resizable()
                .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                // Basic Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(listing.title)
                        .font(.title2)
                        .bold()
                    
                    Text(listing.location)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(listing.price)
                        .font(.title3)
                        .foregroundColor(.blue)
                        .bold()
                }
                
                // Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "Available", value: "\(listing.startDate.formatted(date: .abbreviated, time: .omitted)) - \(listing.endDate.formatted(date: .abbreviated, time: .omitted))")
                    AvailabilityBar(startDate: listing.startDate, endDate: listing.endDate)
                    DetailRow(title: "Bedrooms", value: "\(listing.numberOfBedrooms)")
                    DetailRow(title: "Bathrooms", value: "\(listing.numberOfBathrooms)")
                    DetailRow(title: "Square Footage", value: "\(listing.squareFootage) sq ft")
                }
                
                // Amenities
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amenities")
                        .font(.headline)
                    HStack {
                        Spacer()
                        FlowLayout(spacing: 8) {
                            ForEach(listing.amenities, id: \.self) { amenity in
                                Text(amenity)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
            Spacer()
                    }
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(listing.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Contact Button
            Button(action: {
                    showingContactSheet = true
            }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Contact Lister")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        }
        .navigationTitle("Details")
        .sheet(isPresented: $showingContactSheet) {
            ContactSheet(email: listing.listerEmail)
        }
    }
}

// MARK: - Supporting Views
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, proposal: proposal).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let positions = layout(sizes: sizes, proposal: proposal).positions
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: positions[index], proposal: .unspecified)
        }
    }
    
    private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var currentPosition = CGPoint.zero
        var maxHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for size in sizes {
            if currentPosition.x + size.width > maxWidth {
                currentPosition.x = 0
                currentPosition.y += maxHeight + spacing
                maxHeight = 0
            }
            
            positions.append(currentPosition)
            currentPosition.x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        
        return (positions, CGSize(width: maxWidth, height: currentPosition.y + maxHeight))
    }
}

struct ContactSheet: View {
    let email: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Contact the lister")
                    .font(.title2)
                    .bold()
                
                Text("Email: \(email)")
                    .font(.body)
                
                Button(action: {
                    if let url = URL(string: "mailto:\(email)?subject=Sublease%20Inquiry") {
            UIApplication.shared.open(url)
        }
                }) {
                    Text("Open Email")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct AuthView: View {
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    var body: some View {
        VStack(spacing: 24) {
            Text(isLogin ? "Login" : "Sign Up")
                .font(.largeTitle).bold()
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(isLogin ? "Login" : "Sign Up") {
                // Simulate authentication
                if !email.isEmpty && !password.isEmpty {
                    isAuthenticated = true
                }
            }
            .buttonStyle(.borderedProminent)
            Button(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login") {
                isLogin.toggle()
            }
            .font(.footnote)
        }
        .padding()
    }
}

struct UserIntentModal: View {
    @Binding var userIntent: UserIntent?
    @Binding var showModal: Bool
    var body: some View {
        VStack(spacing: 24) {
            Text("What are you looking for?")
                .font(.title2).bold()
            Button("Looking for a sublease") {
                userIntent = .lookingForSublease
                showModal = false
            }
            .buttonStyle(.borderedProminent)
            Button("Looking to sublease my room") {
                userIntent = .lookingToSublease
                showModal = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct PostSubleaseView: View {
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var location = ""
    @State private var price = ""
    @State private var description = ""
    @State private var listerEmail = ""
    @State private var image: UIImage? = nil
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60*60*24*30)
    @State private var amenities = ""
    @State private var squareFootage = ""
    @State private var numberOfBedrooms = ""
    @State private var numberOfBathrooms = ""
    @State private var negotiable = false
    @State private var showImagePicker = false
    @State private var propertyType = ""
    @State private var hasRoommates = false
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    TextField("Price (e.g. $1200/month)", text: $price)
                    Toggle("Negotiable", isOn: $negotiable)
                }
                Section(header: Text("Details")) {
                    TextField("Bedrooms", text: $numberOfBedrooms)
                        .keyboardType(.numberPad)
                    TextField("Bathrooms", text: $numberOfBathrooms)
                        .keyboardType(.decimalPad)
                    TextField("Square Footage", text: $squareFootage)
                        .keyboardType(.numberPad)
                    TextField("Amenities (comma separated)", text: $amenities)
                }
                Section(header: Text("Availability")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                }
                Section(header: Text("Image")) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                    }
                    Button("Select Image") {
                        showImagePicker = true
                    }
                }
                Section(header: Text("Property Type")) {
                    TextField("Property Type", text: $propertyType)
                }
                Section(header: Text("Roommates")) {
                    Toggle("Has Roommates", isOn: $hasRoommates)
                }
            }
            .navigationTitle("Post Sublease")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        // Here you would save the post
                        isPresented = false
                    }.disabled(title.isEmpty || location.isEmpty || price.isEmpty || numberOfBedrooms.isEmpty || numberOfBathrooms.isEmpty)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

// MARK: - Sample Data
let sampleListings = [
    SubleaseListing(
        title: "Sunny 1BR in Mission District",
        location: "789 Valencia St, San Francisco, CA",
        price: "$2,300/month",
        description: "Bright, spacious 1-bedroom apartment with hardwood floors and a private balcony. Close to BART and great restaurants.",
        listerEmail: "alice@example.com",
        imageName: "house.fill",
        coordinates: CLLocationCoordinate2D(latitude: 37.7599, longitude: -122.4212),
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
        amenities: ["WiFi", "Balcony", "Dishwasher", "Pet Friendly"],
        squareFootage: 650,
        numberOfBedrooms: 1,
        numberOfBathrooms: 1,
        propertyType: "Apartment",
        hasRoommates: false
    ),
    SubleaseListing(
        title: "Modern 2BR Loft near Campus",
        location: "101 College Ave, Berkeley, CA",
        price: "$3,100/month",
        description: "Modern loft with 2 bedrooms, 2 baths, in-unit laundry, and secure parking. 10 min walk to campus.",
        listerEmail: "bob@example.com",
        imageName: "building.2.fill",
        coordinates: CLLocationCoordinate2D(latitude: 37.8715, longitude: -122.2600),
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())!,
        amenities: ["Laundry", "Parking", "Gym", "Rooftop"],
        squareFootage: 900,
        numberOfBedrooms: 2,
        numberOfBathrooms: 2,
        propertyType: "Loft",
        hasRoommates: true
    )
]

struct AvailabilityBar: View {
    let startDate: Date
    let endDate: Date
    var body: some View {
        let totalDays = max(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1, 1)
        let now = Date()
        let elapsedDays = min(max(Calendar.current.dateComponents([.day], from: startDate, to: now).day ?? 0, 0), totalDays)
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(height: 10)
                        .foregroundColor(Color.gray.opacity(0.2))
                    Capsule()
                        .frame(width: geo.size.width * CGFloat(elapsedDays) / CGFloat(totalDays), height: 10)
                        .foregroundColor(.blue)
                }
            }
            .frame(height: 10)
            Text("\(startDate.formatted(date: .abbreviated, time: .omitted)) - \(endDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ProfileMenu: View {
    @Binding var isAuthenticated: Bool
    @Binding var showProfileMenu: Bool
    @Binding var selectedTab: Int
    @Binding var showFavorites: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if isAuthenticated {
                    VStack(spacing: 20) {
                        // Profile Image
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        // Profile Info
                        Text("John Doe")
                            .font(.title2)
                            .bold()
                        Text("john.doe@example.com")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Menu Items
                        VStack(spacing: 15) {
                            MenuItemRow(icon: "person.fill", title: "Personal Information")
                            Button(action: {
                                showFavorites = true
                            }) {
                                MenuItemRow(icon: "heart.fill", title: "Favorites")
                            }
                            MenuItemRow(icon: "bell.fill", title: "Notifications")
                            MenuItemRow(icon: "gear", title: "Settings")
                            MenuItemRow(icon: "questionmark.circle.fill", title: "Help & Support")
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Logout Button
                        Button(action: {
                            isAuthenticated = false
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Logout")
                            }
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(isLogin ? "Login" : "Sign Up")
                             .font(.title2).bold()
                             .foregroundColor(.gray)
                        Text("Create an account to save favorites and post your listing.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(isLogin ? "Login" : "Sign Up") {
                            if !email.isEmpty && !password.isEmpty {
                                isAuthenticated = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login") {
                            isLogin.toggle()
                        }
                        .font(.footnote)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .padding()
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct MenuItemRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(title)
                .font(.body)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}
