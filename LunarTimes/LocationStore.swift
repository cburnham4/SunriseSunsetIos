//
//  LocationStore.swift
//  Sunrise & Sunset
//

import Foundation
import Combine
import CoreLocation

final class LocationStore: ObservableObject {
    @Published var currentLocation: SunriseLocation? {
        didSet {
            guard let currentLocation else { return }
            rememberIfNeeded(currentLocation)
        }
    }

    @Published private(set) var savedLocations: [SunriseLocation] = []

    private let defaults = UserDefaults.standard
    private let storageKey = "sunriseLocations"
    private let maxSaved = 8
    /// ~1.1 km — treats GPS jitter / nearby pins as the same place.
    private let coordinateEpsilon = 0.01

    init() {
        loadSavedLocations()
    }

    func selectSaved(_ location: SunriseLocation) {
        currentLocation = location
    }

    func removeSaved(_ location: SunriseLocation) {
        savedLocations.removeAll { samePlace($0, location) }
        persistSavedLocations()
    }

    /// Append newly picked places without reordering existing chips.
    private func rememberIfNeeded(_ location: SunriseLocation) {
        let address = normalizedAddress(location.address)
        guard !address.isEmpty else { return }
        if savedLocations.contains(where: { samePlace($0, location) }) { return }

        savedLocations.append(location)
        savedLocations = Array(deduplicated(savedLocations).suffix(maxSaved))
        persistSavedLocations()
    }

    private func samePlace(_ lhs: SunriseLocation, _ rhs: SunriseLocation) -> Bool {
        let leftAddress = normalizedAddress(lhs.address)
        let rightAddress = normalizedAddress(rhs.address)
        if !leftAddress.isEmpty, leftAddress == rightAddress {
            return true
        }
        return abs(lhs.latitude - rhs.latitude) < coordinateEpsilon &&
            abs(lhs.longitude - rhs.longitude) < coordinateEpsilon
    }

    private func normalizedAddress(_ address: String) -> String {
        address
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func deduplicated(_ locations: [SunriseLocation]) -> [SunriseLocation] {
        var unique: [SunriseLocation] = []
        for location in locations {
            if unique.contains(where: { samePlace($0, location) }) { continue }
            unique.append(location)
        }
        return unique
    }

    private func loadSavedLocations() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        // Matches legacy AddLocationTableViewController storage
        let loaded = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [SunriseLocation]) ?? []
        let cleaned = Array(deduplicated(loaded).prefix(maxSaved))
        savedLocations = cleaned
        if cleaned.count != loaded.count {
            persistSavedLocations()
        }
    }

    private func persistSavedLocations() {
        let data = NSKeyedArchiver.archivedData(withRootObject: savedLocations)
        defaults.set(data, forKey: storageKey)
    }
}
