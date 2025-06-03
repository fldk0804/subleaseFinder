import SwiftUI
import MapKit

struct MapListingsView: View {
    let listings: [SubleaseListing]
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(listings) { listing in
                Annotation("$\(listing.price)", coordinate: listing.coordinates) {
                    VStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text(listing.price)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
}

#Preview {
    MapListingsView(listings: sampleListings)
} 