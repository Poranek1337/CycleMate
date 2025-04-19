import Foundation
import CoreLocation

@MainActor
class LocationSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [GeocodingHit] = []
    @Published var isLoading = false
    @Published var error: GeocodingError?
    @Published var selectedLocation: GeocodingHit?
    
    private var searchTask: Task<Void, Never>?
    
    func searchLocations() {
        searchTask?.cancel()
        
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            isLoading = true
            error = nil
            
            do {
                let response = try await GeocodingService.shared.search(query: searchText)
                searchResults = response.hits
            } catch let geocodingError as GeocodingError {
                error = geocodingError
            } catch {
                self.error = .networkError(error)
            }
            
            isLoading = false
        }
    }
    
    func selectLocation(_ location: GeocodingHit) {
        selectedLocation = location
        searchText = location.name
        searchResults = []
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        selectedLocation = nil
    }
}