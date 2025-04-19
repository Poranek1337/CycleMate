//
//  LocationSearchViewModel.swift
//  CycleMate
//

import Foundation

class LocationCompletion: Identifiable {
    init(title: String, subtitle: String, distance: Double, duration: Double) {
        self.title = title
        self.subtitle = subtitle
        self.distance = distance
        self.duration = duration
    }
    
    let id = UUID()
    let title: String
    let subtitle: String
    let distance: Double
    let duration: Double
}


class LocationSearchViewModel: ObservableObject {
    @Published var completions: [LocationCompletion] = []
    @Published var searchTextField: String = ""
    @Published var showCompletions: Bool = false
    @Published var results: [GeocodingHit] = []
    @Published var selectedResult: GeocodingHit?
    
    var onResultsUpdated: (([GeocodingHit]) -> Void)?

    func selectResult(_ hit: GeocodingHit) {
        selectedResult = hit
        if !results.contains(where: { $0.id == hit.id }) {
            results = [hit]
        }
        onResultsUpdated?([hit])
    }
    
    func clearResults() {
        if selectedResult == nil {
            results = []
            onResultsUpdated?([])
        }
    }
    
    func clearSearch() {
        searchTextField = ""
        if selectedResult == nil {
            results = []
            onResultsUpdated?([])
        }
    }

    @MainActor
    func submitSearch(text: String) async {
        self.searchTextField = text
        self.showCompletions = true

        guard !text.isEmpty else {
            if selectedResult == nil {
                self.results = []
                onResultsUpdated?(results)
            }
            return
        }

        do {
            let response = try await GeocodingService.shared.search(query: text)
            self.results = response.hits
            onResultsUpdated?(self.results)
        } catch {
            if selectedResult == nil {
                self.results = []
                onResultsUpdated?(self.results)
            }
        }
    }
}
