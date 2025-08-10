import Foundation
import CoreLocation

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
        return formatter.string(from: price as NSDecimalNumber) ?? "\(price)"
    }
    
    var durationText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - API Models
struct ListingQuery: Codable {
    let bbox: BoundingBox?
    let searchText: String?
    let priceMin: Decimal?
    let priceMax: Decimal?
    let bedrooms: Int?
    let propertyType: SubleaseListing.PropertyType?
    let startDate: Date?
    let endDate: Date?
    let sortBy: SortOption
    let sortOrder: SortOrder
    let limit: Int
    let offset: Int
    
    enum SortOption: String, Codable, CaseIterable {
        case price = "price"
        case createdAt = "createdAt"
        case distance = "distance"
    }
    
    enum SortOrder: String, Codable, CaseIterable {
        case ascending = "asc"
        case descending = "desc"
    }
}

struct BoundingBox: Codable {
    let north: Double
    let south: Double
    let east: Double
    let west: Double
}

struct ListingResponse: Codable {
    let listings: [SubleaseListing]
    let total: Int
    let hasMore: Bool
    let nextCursor: String?
}

struct CreateListingRequest: Codable {
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
    let propertyType: SubleaseListing.PropertyType
    let amenities: [String]
    let hasRoommates: Bool
    let images: [String] // URLs after upload
}

struct PresignedUrlResponse: Codable {
    let uploadUrl: String
    let fileUrl: String
    let key: String
} 