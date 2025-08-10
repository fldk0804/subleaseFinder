import SwiftUI
import MapKit

struct BrowseView: View {
    @EnvironmentObject var browseFlow: BrowseFlow
    @EnvironmentObject var listingService: ListingServiceProtocol
    @State private var showFilters = false
    @State private var showSearch = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                SearchFilterBar(
                    searchText: $browseFlow.searchText,
                    showFilters: $showFilters,
                    onSearch: { browseFlow.searchListings() }
                )
                
                // View Mode Toggle
                ViewModeToggle(viewMode: $browseFlow.viewMode)
                
                // Content
                if browseFlow.viewMode == .map {
                    MapBrowseView()
                        .environmentObject(browseFlow)
                        .environmentObject(listingService)
                } else {
                    ListBrowseView()
                        .environmentObject(browseFlow)
                        .environmentObject(listingService)
                }
            }
            .navigationTitle("Browse")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showFilters) {
                FilterView(filters: $browseFlow.selectedFilters)
            }
            .sheet(isPresented: $browseFlow.showListingDetail) {
                if let listing = browseFlow.selectedListing {
                    ListingDetailView(listing: listing)
                        .environmentObject(listingService)
                }
            }
            .onAppear {
                Task {
                    await browseFlow.refreshListings()
                }
            }
        }
    }
}

// MARK: - Search and Filter Bar
struct SearchFilterBar: View {
    @Binding var searchText: String
    @Binding var showFilters: Bool
    let onSearch: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search listings...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit(onSearch)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        onSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Filter Button
            Button(action: { showFilters = true }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - View Mode Toggle
struct ViewModeToggle: View {
    @Binding var viewMode: BrowseFlow.ViewMode
    
    var body: some View {
        HStack {
            Spacer()
            
            Picker("View Mode", selection: $viewMode) {
                Image(systemName: "map")
                    .tag(BrowseFlow.ViewMode.map)
                
                Image(systemName: "list.bullet")
                    .tag(BrowseFlow.ViewMode.list)
            }
            .pickerStyle(.segmented)
            .frame(width: 120)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - Map Browse View
struct MapBrowseView: View {
    @EnvironmentObject var browseFlow: BrowseFlow
    @EnvironmentObject var listingService: ListingServiceProtocol
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: listingService.listings) { listing in
                MapAnnotation(coordinate: listing.coordinate) {
                    ListingMapAnnotation(listing: listing) {
                        browseFlow.selectListing(listing)
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            
            // Refresh Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await browseFlow.refreshListings()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - List Browse View
struct ListBrowseView: View {
    @EnvironmentObject var browseFlow: BrowseFlow
    @EnvironmentObject var listingService: ListingServiceProtocol
    
    var body: some View {
        Group {
            if listingService.isLoading {
                LoadingView()
            } else if listingService.listings.isEmpty {
                EmptyStateView()
            } else {
                List(listingService.listings) { listing in
                    ListingRowView(listing: listing) {
                        browseFlow.selectListing(listing)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await browseFlow.refreshListings()
                }
            }
        }
    }
}

// MARK: - Listing Map Annotation
struct ListingMapAnnotation: View {
    let listing: SubleaseListing
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Text(listing.formattedPrice)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(8)
                
                Image(systemName: "house.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .offset(y: -2)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Listing Row View
struct ListingRowView: View {
    let listing: SubleaseListing
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Image
                if let firstImage = listing.images.first {
                    AsyncImage(url: URL(string: firstImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "house")
                                    .foregroundColor(.secondary)
                            )
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "house")
                                .foregroundColor(.secondary)
                        )
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(listing.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(listing.formattedPrice)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("\(listing.numberOfBedrooms) bed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(listing.durationText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No listings found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Filter View
struct FilterView: View {
    @Binding var filters: ListingFilters
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Price Range") {
                    HStack {
                        TextField("Min", value: $filters.priceMin, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                        
                        Text("-")
                            .foregroundColor(.secondary)
                        
                        TextField("Max", value: $filters.priceMax, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Property Details") {
                    Picker("Bedrooms", selection: $filters.bedrooms) {
                        Text("Any").tag(nil as Int?)
                        ForEach(1...5, id: \.self) { count in
                            Text("\(count)+").tag(count as Int?)
                        }
                    }
                    
                    Picker("Property Type", selection: $filters.propertyType) {
                        Text("Any").tag(nil as SubleaseListing.PropertyType?)
                        ForEach(SubleaseListing.PropertyType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type as SubleaseListing.PropertyType?)
                        }
                    }
                }
                
                Section("Sort By") {
                    Picker("Sort", selection: $filters.sortBy) {
                        ForEach(ListingQuery.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue.capitalized).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Order", selection: $filters.sortOrder) {
                        Text("Ascending").tag(ListingQuery.SortOrder.ascending)
                        Text("Descending").tag(ListingQuery.SortOrder.descending)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Reset") {
                    filters = ListingFilters()
                },
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Preview
struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
            .environmentObject(BrowseFlow(listingService: MockListingService()))
            .environmentObject(MockListingService())
    }
}

// MARK: - Mock Services for Preview
class MockListingService: ListingServiceProtocol {
    @Published var listings: [SubleaseListing] = SampleData.sampleListings
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    func fetchListings(query: ListingQuery) async throws -> ListingResponse {
        // Return sample data
        return ListingResponse(
            listings: SampleData.sampleListings,
            total: SampleData.sampleListings.count,
            hasMore: false,
            nextCursor: nil
        )
    }
    
    func createListing(_ request: CreateListingRequest) async throws -> SubleaseListing {
        fatalError("Not implemented")
    }
    
    func updateListing(id: String, request: CreateListingRequest) async throws -> SubleaseListing {
        fatalError("Not implemented")
    }
    
    func favoriteListing(id: String) async throws {
        fatalError("Not implemented")
    }
    
    func getPresignedUrl(contentType: String) async throws -> PresignedUrlResponse {
        fatalError("Not implemented")
    }
    
    func clearCache() {
        listings = []
    }
}
