import Foundation
import Combine

// MARK: - API Error Types
enum APIError: Error, LocalizedError {
    case unauthorized
    case validation(String)
    case rateLimited
    case server(Int)
    case offline
    case decoding
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Please sign in to continue"
        case .validation(let message):
            return message
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .server(let code):
            return "Server error (\(code)). Please try again."
        case .offline:
            return "No internet connection. Please check your network."
        case .decoding:
            return "Unable to process response from server."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}

// MARK: - API Client
class APIClient: ObservableObject {
    private let session: URLSession
    private let baseURL: URL
    private let authService: AuthServiceProtocol
    private let requestQueue = DispatchQueue(label: "api.request", qos: .userInitiated)
    
    init(baseURL: URL, authService: AuthServiceProtocol) {
        self.baseURL = baseURL
        self.authService = authService
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Request Builder
    func request<T: Codable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        retries: Int = 2
    ) async throws -> T {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
        
        if case .GET = method, let queryItems = endpoint.queryItems {
            urlComponents.queryItems = queryItems
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add request ID for tracking
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        
        // Add auth header
        if let token = try? await authService.getIDToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body for non-GET requests
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return try await performRequest(request: request, retries: retries)
    }
    
    // MARK: - Request Execution
    private func performRequest<T: Codable>(
        request: URLRequest,
        retries: Int
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                return try JSONDecoder().decode(T.self, from: data)
            case 401:
                throw APIError.unauthorized
            case 422:
                if let errorResponse = try? JSONDecoder().decode(ValidationErrorResponse.self, from: data) {
                    throw APIError.validation(errorResponse.message)
                }
                throw APIError.validation("Invalid request")
            case 429:
                throw APIError.rateLimited
            case 500...599:
                throw APIError.server(httpResponse.statusCode)
            default:
                throw APIError.unknown
            }
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            }
            
            // Handle network errors
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw APIError.offline
            }
            
            // Retry logic
            if retries > 0 {
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(3 - retries))) * 1_000_000_000)
                return try await performRequest(request: request, retries: retries - 1)
            }
            
            throw APIError.unknown
        }
    }
}

// MARK: - Supporting Types
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

struct ValidationErrorResponse: Codable {
    let message: String
}

// MARK: - API Endpoints
enum APIEndpoint {
    case listings(query: ListingQuery?)
    case createListing
    case updateListing(id: String)
    case favoriteListing(id: String)
    case presignedUrl(contentType: String)
    
    var path: String {
        switch self {
        case .listings:
            return "/listings"
        case .createListing:
            return "/listings"
        case .updateListing(let id):
            return "/listings/\(id)"
        case .favoriteListing(let id):
            return "/favorites/\(id)"
        case .presignedUrl:
            return "/presign"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .listings(let query):
            guard let query = query else { return nil }
            var items: [URLQueryItem] = []
            
            if let bbox = query.bbox {
                items.append(URLQueryItem(name: "north", value: String(bbox.north)))
                items.append(URLQueryItem(name: "south", value: String(bbox.south)))
                items.append(URLQueryItem(name: "east", value: String(bbox.east)))
                items.append(URLQueryItem(name: "west", value: String(bbox.west)))
            }
            
            if let searchText = query.searchText {
                items.append(URLQueryItem(name: "q", value: searchText))
            }
            
            if let priceMin = query.priceMin {
                items.append(URLQueryItem(name: "priceMin", value: String(priceMin)))
            }
            
            if let priceMax = query.priceMax {
                items.append(URLQueryItem(name: "priceMax", value: String(priceMax)))
            }
            
            if let bedrooms = query.bedrooms {
                items.append(URLQueryItem(name: "bedrooms", value: String(bedrooms)))
            }
            
            if let propertyType = query.propertyType {
                items.append(URLQueryItem(name: "propertyType", value: propertyType.rawValue))
            }
            
            if let startDate = query.startDate {
                items.append(URLQueryItem(name: "startDate", value: ISO8601DateFormatter().string(from: startDate)))
            }
            
            if let endDate = query.endDate {
                items.append(URLQueryItem(name: "endDate", value: ISO8601DateFormatter().string(from: endDate)))
            }
            
            items.append(URLQueryItem(name: "sortBy", value: query.sortBy.rawValue))
            items.append(URLQueryItem(name: "sortOrder", value: query.sortOrder.rawValue))
            items.append(URLQueryItem(name: "limit", value: String(query.limit)))
            items.append(URLQueryItem(name: "offset", value: String(query.offset)))
            
            return items
            
        case .presignedUrl(let contentType):
            return [URLQueryItem(name: "contentType", value: contentType)]
            
        default:
            return nil
        }
    }
}
