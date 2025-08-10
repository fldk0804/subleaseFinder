import SwiftUI
import MapKit

struct ListingDetailView: View {
    let listing: SubleaseListing
    @EnvironmentObject var listingService: ListingServiceProtocol
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex = 0
    @State private var showContactSheet = false
    @State private var isFavorite = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Image Gallery
                    ImageGalleryView(
                        images: listing.images,
                        selectedIndex: $selectedImageIndex
                    )
                    
                    VStack(spacing: 20) {
                        // Header Info
                        HeaderInfoView(listing: listing)
                        
                        // Property Details
                        PropertyDetailsView(listing: listing)
                        
                        // Amenities
                        if !listing.amenities.isEmpty {
                            AmenitiesView(amenities: listing.amenities)
                        }
                        
                        // Description
                        DescriptionView(description: listing.description)
                        
                        // Location Map
                        LocationMapView(listing: listing)
                        
                        // Lister Info
                        ListerInfoView(listing: listing)
                    }
                    .padding()
                }
            }
            .navigationTitle("Listing Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") { dismiss() },
                trailing: HStack {
                    Button(action: { toggleFavorite() }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .primary)
                    }
                    
                    Button(action: { showContactSheet = true }) {
                        Image(systemName: "envelope")
                    }
                }
            )
            .sheet(isPresented: $showContactSheet) {
                ContactSheetView(listing: listing)
            }
        }
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        Task {
            do {
                try await listingService.favoriteListing(listing.id)
            } catch {
                print("Error toggling favorite: \(error)")
            }
        }
    }
}

// MARK: - Image Gallery View
struct ImageGalleryView: View {
    let images: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        Group {
            if images.isEmpty {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: "house")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                    )
            } else {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 300)
                .overlay(
                    // Image counter
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(selectedIndex + 1) of \(images.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(12)
                                .padding()
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Header Info View
struct HeaderInfoView: View {
    let listing: SubleaseListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(listing.title)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Text(listing.formattedPrice)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(listing.numberOfBedrooms) bed, \(listing.numberOfBathrooms, specifier: "%.1f") bath")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let squareFootage = listing.squareFootage {
                        Text("\(squareFootage) sq ft")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(listing.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(listing.durationText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Property Details View
struct PropertyDetailsView: View {
    let listing: SubleaseListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Property Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                DetailRow(icon: "bed.double", title: "Bedrooms", value: "\(listing.numberOfBedrooms)")
                DetailRow(icon: "shower", title: "Bathrooms", value: String(format: "%.1f", listing.numberOfBathrooms))
                DetailRow(icon: "house", title: "Type", value: listing.propertyType.rawValue.capitalized)
                
                if let squareFootage = listing.squareFootage {
                    DetailRow(icon: "square", title: "Square Feet", value: "\(squareFootage)")
                }
                
                DetailRow(icon: "person.2", title: "Roommates", value: listing.hasRoommates ? "Yes" : "No")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

// MARK: - Amenities View
struct AmenitiesView: View {
    let amenities: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amenities")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(amenities, id: \.self) { amenity in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(amenity)
                            .font(.subheadline)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Description View
struct DescriptionView: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.body)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Location Map View
struct LocationMapView: View {
    let listing: SubleaseListing
    @State private var region: MKCoordinateRegion
    
    init(listing: SubleaseListing) {
        self.listing = listing
        self._region = State(initialValue: MKCoordinateRegion(
            center: listing.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .fontWeight(.semibold)
            
            Map(coordinateRegion: .constant(region), annotationItems: [listing]) { listing in
                MapMarker(coordinate: listing.coordinate, tint: .blue)
            }
            .frame(height: 200)
            .cornerRadius(12)
            
            Text(listing.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Lister Info View
struct ListerInfoView: View {
    let listing: SubleaseListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Listed by")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.listerName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Member since \(listing.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Contact Sheet View
struct ContactSheetView: View {
    let listing: SubleaseListing
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact \(listing.listerName)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Send a message about this listing")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Hi, I'm interested in your listing...", text: $message, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4...8)
                }
                
                Spacer()
                
                Button("Send Message") {
                    sendMessage()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(message.isEmpty || isLoading)
                
                if isLoading {
                    ProgressView()
                }
            }
            .padding()
            .navigationTitle("Contact")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private func sendMessage() {
        isLoading = true
        
        // In a real app, you'd send the message via API
        // For now, just simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            dismiss()
        }
    }
}

// MARK: - Preview
struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListingDetailView(listing: SubleaseListing(
            id: "1",
            title: "Cozy Studio in Downtown",
            description: "Beautiful studio apartment in the heart of downtown with amazing views and modern amenities.",
            price: 1500,
            currency: "USD",
            location: "Downtown, San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            startDate: Date(),
            endDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
            numberOfBedrooms: 0,
            numberOfBathrooms: 1.0,
            squareFootage: 500,
            propertyType: .studio,
            amenities: ["WiFi", "Gym", "Pool"],
            hasRoommates: false,
            images: [],
            coverImageIndex: 0,
            listerId: "user1",
            listerName: "John Doe",
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        ))
        .environmentObject(MockListingService())
    }
}
