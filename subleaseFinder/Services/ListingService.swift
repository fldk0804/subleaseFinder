import Foundation
import Combine

// MARK: - Listing Service Protocol
protocol ListingServiceProtocol: ObservableObject {
    var listings: [SubleaseListing] { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    
    func fetchListings(query: ListingQuery) async throws -> ListingResponse
    func createListing(_ request: CreateListingRequest) async throws -> SubleaseListing
    func updateListing(id: String, request: CreateListingRequest) async throws -> SubleaseListing
    func favoriteListing(id: String) async throws
    func getPresignedUrl(contentType: String) async throws -> PresignedUrlResponse
    func clearCache()
}

// MARK: - Listing Service Implementation
class ListingService: ListingServiceProtocol {
    @Published private(set) var listings: [SubleaseListing] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    
    private let apiClient: APIClient
    private let cache: ListingCache
    private let uploadService: UploadServiceProtocol
    
    init(apiClient: APIClient, cache: ListingCache, uploadService: UploadServiceProtocol) {
        self.apiClient = apiClient
        self.cache = cache
        self.uploadService = uploadService
    }
    
    // MARK: - Fetch Listings
    func fetchListings(query: ListingQuery) async throws -> ListingResponse {
        await MainActor.run { isLoading = true; error = nil }
        
        do {
            // Check cache first
            if let cachedResponse = cache.getListings(for: query) {
                await MainActor.run {
                    self.listings = cachedResponse.listings
                    self.isLoading = false
                }
                return cachedResponse
            }
            
            // Fetch from API
            let response: ListingResponse = try await apiClient.request(
                endpoint: .listings(query: query)
            )
            
            // Cache the response
            cache.setListings(response, for: query)
            
            await MainActor.run {
                self.listings = response.listings
                self.isLoading = false
            }
            
            return response
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Create Listing
    func createListing(_ request: CreateListingRequest) async throws -> SubleaseListing {
        await MainActor.run { isLoading = true; error = nil }
        
        do {
            let listing: SubleaseListing = try await apiClient.request(
                endpoint: .createListing,
                method: .POST,
                body: request
            )
            
            await MainActor.run {
                self.listings.insert(listing, at: 0)
                self.isLoading = false
            }
            
            // Clear cache to refresh listings
            cache.clear()
            
            return listing
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Update Listing
    func updateListing(id: String, request: CreateListingRequest) async throws -> SubleaseListing {
        await MainActor.run { isLoading = true; error = nil }
        
        do {
            let listing: SubleaseListing = try await apiClient.request(
                endpoint: .updateListing(id: id),
                method: .PUT,
                body: request
            )
            
            await MainActor.run {
                if let index = self.listings.firstIndex(where: { $0.id == id }) {
                    self.listings[index] = listing
                }
                self.isLoading = false
            }
            
            // Clear cache to refresh listings
            cache.clear()
            
            return listing
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Favorite Listing
    func favoriteListing(id: String) async throws {
        do {
            let _: EmptyResponse = try await apiClient.request(
                endpoint: .favoriteListing(id: id),
                method: .POST
            )
            
            // Update local state if needed
            // This could trigger a refresh of favorites or update local state
        } catch {
            throw error
        }
    }
    
    // MARK: - Get Presigned URL
    func getPresignedUrl(contentType: String) async throws -> PresignedUrlResponse {
        return try await apiClient.request(
            endpoint: .presignedUrl(contentType: contentType)
        )
    }
    
    // MARK: - Cache Management
    func clearCache() {
        cache.clear()
    }
}

// MARK: - Upload Service Protocol
protocol UploadServiceProtocol {
    func uploadImage(_ imageData: Data, contentType: String) async throws -> String
    func uploadImages(_ imageDataArray: [Data], contentType: String) async throws -> [String]
}

// MARK: - Upload Service Implementation
class UploadService: UploadServiceProtocol {
    private let apiClient: APIClient
    private let session: URLSession
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    func uploadImage(_ imageData: Data, contentType: String) async throws -> String {
        // Get presigned URL
        let presignedResponse = try await apiClient.getPresignedUrl(contentType: contentType)
        
        // Upload to S3
        var request = URLRequest(url: URL(string: presignedResponse.uploadUrl)!)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.server(500)
        }
        
        return presignedResponse.fileUrl
    }
    
    func uploadImages(_ imageDataArray: [Data], contentType: String) async throws -> [String] {
        return try await withThrowingTaskGroup(of: String.self) { group in
            for imageData in imageDataArray {
                group.addTask {
                    try await self.uploadImage(imageData, contentType: contentType)
                }
            }
            
            var urls: [String] = []
            for try await url in group {
                urls.append(url)
            }
            
            return urls.sorted() // Maintain order if needed
        }
    }
}

// MARK: - Listing Cache
class ListingCache {
    private let cache = NSCache<NSString, CachedListingResponse>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("ListingCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func setListings(_ response: ListingResponse, for query: ListingQuery) {
        let key = cacheKey(for: query)
        let cachedResponse = CachedListingResponse(
            response: response,
            timestamp: Date(),
            query: query
        )
        
        cache.setObject(cachedResponse, forKey: key as NSString)
        
        // Persist to disk
        saveToDisk(cachedResponse, for: key)
    }
    
    func getListings(for query: ListingQuery) -> ListingResponse? {
        let key = cacheKey(for: query)
        
        // Check memory cache first
        if let cached = cache.object(forKey: key as NSString) {
            if isStale(cached) {
                cache.removeObject(forKey: key as NSString)
                return nil
            }
            return cached.response
        }
        
        // Check disk cache
        if let cached = loadFromDisk(for: key) {
            if isStale(cached) {
                removeFromDisk(for: key)
                return nil
            }
            cache.setObject(cached, forKey: key as NSString)
            return cached.response
        }
        
        return nil
    }
    
    func clear() {
        cache.removeAllObjects()
        
        // Clear disk cache
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Methods
    private func cacheKey(for query: ListingQuery) -> String {
        // Create a hash of the query parameters
        let queryString = "\(query.searchText ?? "")-\(query.priceMin ?? 0)-\(query.priceMax ?? 0)-\(query.bedrooms ?? 0)-\(query.propertyType?.rawValue ?? "")-\(query.sortBy.rawValue)-\(query.sortOrder.rawValue)"
        return queryString.data(using: .utf8)?.base64EncodedString() ?? queryString
    }
    
    private func isStale(_ cached: CachedListingResponse) -> Bool {
        let stalenessInterval: TimeInterval = 5 * 60 // 5 minutes for list
        return Date().timeIntervalSince(cached.timestamp) > stalenessInterval
    }
    
    private func saveToDisk(_ cached: CachedListingResponse, for key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        
        do {
            let data = try JSONEncoder().encode(cached)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save cache to disk: \(error)")
        }
    }
    
    private func loadFromDisk(for key: String) -> CachedListingResponse? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(CachedListingResponse.self, from: data)
        } catch {
            return nil
        }
    }
    
    private func removeFromDisk(for key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        try? fileManager.removeItem(at: fileURL)
    }
}

// MARK: - Supporting Types
struct CachedListingResponse: Codable {
    let response: ListingResponse
    let timestamp: Date
    let query: ListingQuery
}

struct EmptyResponse: Codable {}
