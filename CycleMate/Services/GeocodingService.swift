import Foundation

public enum GeocodingError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
}

public class GeocodingService {
    public static let shared = GeocodingService()
    
    private init() {}
    
    public func search(query: String, limit: Int = 5, locale: String = "en") async throws -> GeocodingResponse {
        guard var urlComponents = URLComponents(string: "\(Configuration.API.baseURL)/geocoding") else {
            throw GeocodingError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "locale", value: locale)
        ]
        
        guard let url = urlComponents.url else {
            throw GeocodingError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Configuration.API.bearerToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw GeocodingError.networkError(NSError(domain: "", code: -1))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error: \(httpResponse.statusCode)")
                throw GeocodingError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(GeocodingResponse.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw GeocodingError.decodingError(error)
            }
        } catch {
            throw GeocodingError.networkError(error)
        }
    }
}
