import Foundation
import CoreLocation

struct SubleaseListing: Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let price: String
    let imageName: String
    let description: String
    let listerEmail: String
    let latitude: Double
    let longitude: Double
} 