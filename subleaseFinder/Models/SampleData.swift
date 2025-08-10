import Foundation
import CoreLocation

// MARK: - Sample Data
struct SampleData {
    static let sampleListings: [SubleaseListing] = [
        SubleaseListing(
            id: "1",
            title: "Cozy Studio in Downtown SF",
            description: "Beautiful studio apartment in the heart of San Francisco. Walking distance to BART, restaurants, and shopping. Perfect for students or young professionals. Fully furnished with modern amenities.",
            price: 2200,
            currency: "USD",
            location: "Downtown, San Francisco",
            latitude: 37.7749,
            longitude: -122.4194,
            startDate: Date(),
            endDate: Date().addingTimeInterval(90 * 24 * 60 * 60), // 90 days
            numberOfBedrooms: 0,
            numberOfBathrooms: 1.0,
            squareFootage: 450,
            propertyType: .studio,
            amenities: ["WiFi", "Gym", "Laundry", "Furnished", "Air Conditioning"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800",
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user1",
            listerName: "Sarah Chen",
            createdAt: Date().addingTimeInterval(-7 * 24 * 60 * 60),
            updatedAt: Date().addingTimeInterval(-1 * 24 * 60 * 60),
            isActive: true
        ),
        
        SubleaseListing(
            id: "2",
            title: "Spacious 2BR Near UC Berkeley",
            description: "Large 2-bedroom apartment just 10 minutes from UC Berkeley campus. Great for students or young professionals. Includes parking spot and access to building amenities.",
            price: 3200,
            currency: "USD",
            location: "Berkeley, CA",
            latitude: 37.8716,
            longitude: -122.2727,
            startDate: Date().addingTimeInterval(7 * 24 * 60 * 60), // 1 week from now
            endDate: Date().addingTimeInterval(120 * 24 * 60 * 60), // 120 days
            numberOfBedrooms: 2,
            numberOfBathrooms: 1.5,
            squareFootage: 850,
            propertyType: .apartment,
            amenities: ["WiFi", "Parking", "Gym", "Pool", "Dishwasher"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1560448075-bb485b067938?w=800",
                "https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user2",
            listerName: "Mike Rodriguez",
            createdAt: Date().addingTimeInterval(-3 * 24 * 60 * 60),
            updatedAt: Date(),
            isActive: true
        ),
        
        SubleaseListing(
            id: "3",
            title: "Modern 1BR in Palo Alto",
            description: "Recently renovated 1-bedroom apartment in Palo Alto. Close to Stanford University and tech companies. High-end finishes and appliances included.",
            price: 2800,
            currency: "USD",
            location: "Palo Alto, CA",
            latitude: 37.4419,
            longitude: -122.1430,
            startDate: Date().addingTimeInterval(14 * 24 * 60 * 60), // 2 weeks from now
            endDate: Date().addingTimeInterval(180 * 24 * 60 * 60), // 180 days
            numberOfBedrooms: 1,
            numberOfBathrooms: 1.0,
            squareFootage: 650,
            propertyType: .apartment,
            amenities: ["WiFi", "Gym", "Pool", "Furnished", "Air Conditioning", "Balcony"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=800",
                "https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user3",
            listerName: "Emily Johnson",
            createdAt: Date().addingTimeInterval(-1 * 24 * 60 * 60),
            updatedAt: Date(),
            isActive: true
        ),
        
        SubleaseListing(
            id: "4",
            title: "Shared Room in Student House",
            description: "Private room in a 4-bedroom house shared with 3 other students. Great location near campus with backyard and parking. Perfect for students on a budget.",
            price: 1200,
            currency: "USD",
            location: "Oakland, CA",
            latitude: 37.8044,
            longitude: -122.2711,
            startDate: Date(),
            endDate: Date().addingTimeInterval(60 * 24 * 60 * 60), // 60 days
            numberOfBedrooms: 1,
            numberOfBathrooms: 2.0,
            squareFootage: 200,
            propertyType: .shared,
            amenities: ["WiFi", "Laundry", "Backyard", "Parking"],
            hasRoommates: true,
            images: [
                "https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800",
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user4",
            listerName: "Alex Thompson",
            createdAt: Date().addingTimeInterval(-5 * 24 * 60 * 60),
            updatedAt: Date().addingTimeInterval(-2 * 24 * 60 * 60),
            isActive: true
        ),
        
        SubleaseListing(
            id: "5",
            title: "Luxury Condo in San Jose",
            description: "High-end 2-bedroom condo in downtown San Jose. Walking distance to restaurants, shopping, and public transit. Includes access to rooftop deck and fitness center.",
            price: 3800,
            currency: "USD",
            location: "San Jose, CA",
            latitude: 37.3382,
            longitude: -121.8863,
            startDate: Date().addingTimeInterval(21 * 24 * 60 * 60), // 3 weeks from now
            endDate: Date().addingTimeInterval(150 * 24 * 60 * 60), // 150 days
            numberOfBedrooms: 2,
            numberOfBathrooms: 2.0,
            squareFootage: 1100,
            propertyType: .condo,
            amenities: ["WiFi", "Gym", "Pool", "Rooftop Deck", "Concierge", "Furnished"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800",
                "https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user5",
            listerName: "David Kim",
            createdAt: Date().addingTimeInterval(-2 * 24 * 60 * 60),
            updatedAt: Date(),
            isActive: true
        ),
        
        SubleaseListing(
            id: "6",
            title: "Charming House in Mountain View",
            description: "Beautiful 3-bedroom house with garden in quiet neighborhood. Perfect for families or roommates. Close to Google campus and downtown Mountain View.",
            price: 4500,
            currency: "USD",
            location: "Mountain View, CA",
            latitude: 37.3861,
            longitude: -122.0839,
            startDate: Date().addingTimeInterval(30 * 24 * 60 * 60), // 1 month from now
            endDate: Date().addingTimeInterval(200 * 24 * 60 * 60), // 200 days
            numberOfBedrooms: 3,
            numberOfBathrooms: 2.5,
            squareFootage: 1800,
            propertyType: .house,
            amenities: ["WiFi", "Garden", "Parking", "Dishwasher", "Air Conditioning", "Furnished"],
            hasRoommates: false,
            images: [
                "https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800",
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800"
            ],
            coverImageIndex: 0,
            listerId: "user6",
            listerName: "Lisa Wang",
            createdAt: Date().addingTimeInterval(-10 * 24 * 60 * 60),
            updatedAt: Date().addingTimeInterval(-1 * 24 * 60 * 60),
            isActive: true
        )
    ]
    
    static let popularAmenities = [
        "WiFi", "Gym", "Pool", "Parking", "Laundry", "Dishwasher",
        "Air Conditioning", "Balcony", "Furnished", "Pet Friendly",
        "Concierge", "Rooftop Deck", "Garden", "Backyard"
    ]
    
    static let propertyTypes = SubleaseListing.PropertyType.allCases
    
    static let sampleFilters = ListingFilters(
        priceMin: 1000,
        priceMax: 4000,
        bedrooms: 1,
        propertyType: .apartment,
        sortBy: .price,
        sortOrder: .ascending
    )
}
