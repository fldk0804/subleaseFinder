import SwiftUI

struct SavedView: View {
    @EnvironmentObject var savedFlow: SavedFlow
    @EnvironmentObject var listingService: ListingServiceProtocol
    
    var body: some View {
        NavigationView {
            Group {
                if savedFlow.isLoading {
                    LoadingView()
                } else if savedFlow.favoriteListings.isEmpty {
                    EmptySavedView()
                } else {
                    SavedListingsList()
                        .environmentObject(savedFlow)
                        .environmentObject(listingService)
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await savedFlow.refreshFavorites()
            }
            .onAppear {
                Task {
                    await savedFlow.refreshFavorites()
                }
            }
        }
    }
}

// MARK: - Saved Listings List
struct SavedListingsList: View {
    @EnvironmentObject var savedFlow: SavedFlow
    @EnvironmentObject var listingService: ListingServiceProtocol
    @State private var selectedListing: SubleaseListing?
    @State private var showListingDetail = false
    
    var body: some View {
        List {
            ForEach(savedFlow.favoriteListings) { listing in
                SavedListingRow(listing: listing) {
                    selectedListing = listing
                    showListingDetail = true
                }
            }
            .onDelete(perform: removeFromFavorites)
        }
        .listStyle(.plain)
        .sheet(isPresented: $showListingDetail) {
            if let listing = selectedListing {
                ListingDetailView(listing: listing)
                    .environmentObject(listingService)
            }
        }
    }
    
    private func removeFromFavorites(offsets: IndexSet) {
        // In a real app, you'd call the API to remove from favorites
        // For now, just remove from local state
        for index in offsets {
            let listing = savedFlow.favoriteListings[index]
            Task {
                do {
                    try await listingService.favoriteListing(listing.id)
                } catch {
                    print("Error removing from favorites: \(error)")
                }
            }
        }
    }
}

// MARK: - Saved Listing Row
struct SavedListingRow: View {
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
                
                // Favorite Icon
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty Saved View
struct EmptySavedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Saved Listings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start browsing and save listings you're interested in")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Browse Listings") {
                // Navigate to browse tab
                // This would be handled by the parent view
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview
struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedView()
            .environmentObject(SavedFlow(listingService: MockListingService()))
            .environmentObject(MockListingService())
    }
}
