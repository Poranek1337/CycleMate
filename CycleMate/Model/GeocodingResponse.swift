import Foundation

public struct GeocodingResponse: Codable {
    public let hits: [GeocodingHit]
    
    public init(hits: [GeocodingHit]) {
        self.hits = hits
    }
}

public struct GeocodingHit: Codable, Identifiable, Equatable {
    public var id: String { "\(osmId)-\(osmType)" }
    
    public let osmId: Int
    public let osmType: String
    public let country: String?
    public let osmKey: String
    public let city: String?
    public let osmValue: String
    public let postcode: String?
    public let name: String
    public let point: Point
    public let extent: [Double]?
    public let housenumber: String?
    public let street: String?
    
    public init(osmId: Int, osmType: String, country: String?, osmKey: String, city: String?, osmValue: String, postcode: String?, name: String, point: Point, extent: [Double]?, housenumber: String?, street: String?) {
        self.osmId = osmId
        self.osmType = osmType
        self.country = country
        self.osmKey = osmKey
        self.city = city
        self.osmValue = osmValue
        self.postcode = postcode
        self.name = name
        self.point = point
        self.extent = extent
        self.housenumber = housenumber
        self.street = street
    }
    
    enum CodingKeys: String, CodingKey {
        case osmId = "osm_id"
        case osmType = "osm_type"
        case country
        case osmKey = "osm_key"
        case city
        case osmValue = "osm_value"
        case postcode
        case name
        case point
        case extent
        case housenumber
        case street
    }
    
    public static func == (lhs: GeocodingHit, rhs: GeocodingHit) -> Bool {
        return lhs.id == rhs.id
        && lhs.osmId == rhs.osmId
        && lhs.osmType == rhs.osmType
        && lhs.country == rhs.country
        && lhs.osmKey == rhs.osmKey
        && lhs.city == rhs.city
        && lhs.osmValue == rhs.osmValue
        && lhs.postcode == rhs.postcode
        && lhs.name == rhs.name
        && lhs.point == rhs.point
        && lhs.extent == rhs.extent
        && lhs.housenumber == rhs.housenumber
        && lhs.street == rhs.street
    }
}

public struct Point: Codable, Equatable {
    public let lng: Double
    public let lat: Double
    
    public init(lng: Double, lat: Double) {
        self.lng = lng
        self.lat = lat
    }
    
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.lng == rhs.lng && lhs.lat == rhs.lat
    }
}
