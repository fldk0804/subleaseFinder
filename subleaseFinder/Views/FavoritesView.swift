import SwiftUI

struct FavoritesView: View {
    @State private var favoriteListings: [SubleaseListing] = []
    
    var body: some View {
        NavigationView {
            if favoriteListings.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Favorites Yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Save your favorite listings here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else {
                List(favoriteListings) { listing in
                    NavigationLink(destination: SubleaseDetailView(listing: listing)) {
                        ListingRowView(listing: listing)
                    }
                }
                .navigationTitle("Favorites")
            }
        }
    }
}

#Preview {
    FavoritesView()
} 