//
//  LocationSearchCompletionsView.swift
//  CycleMate
//

import SwiftUI

struct LocationSearchCompletionsView: View {
    let searchResults: [GeocodingHit]
    let onSelect: (GeocodingHit) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if searchResults.isEmpty {
                    VStack {
                        Spacer().frame(height: 32)
                        Text("No results")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer().frame(height: 32)
                    }
                } else {
                    ForEach(searchResults, id: \.id) { result in
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                         to: nil, from: nil, for: nil)
                            onSelect(result)
                        }) {
                            HStack {
                                Image(systemName: getIconName(for: result.osmValue))
                                    .foregroundColor(.accentColor)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.name)
                                        .font(.headline)
                                    if let address = formatAddress(result) {
                                        Text(address)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
        }
        .scrollDisabled(searchResults.isEmpty)
    }

    private func formatAddress(_ hit: GeocodingHit) -> String? {
        var components: [String] = []
        if let street = hit.street {
            if let housenumber = hit.housenumber {
                components.append("\(street) \(housenumber)")
            } else {
                components.append(street)
            }
        }
        if let city = hit.city { components.append(city) }
        if let postcode = hit.postcode { components.append(postcode) }
        if let country = hit.country { components.append(country) }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }

    private func getIconName(for osmValue: String) -> String {
        switch osmValue.lowercased() {
        case "city": return "building.2"
        case "station": return "train.side.front.car"
        case "hospital": return "cross.circle"
        case "university": return "book"
        case "library": return "books.vertical"
        case "stadium": return "sportscourt"
        case "battlefield": return "flag"
        case "government": return "building.columns"
        default: return "mappin"
        }
    }
}
