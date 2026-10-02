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

    init() {
        loadSavedLocations()
    }

    func selectSaved(_ location: SunriseLocation) {
        // Avoid didSet remember path so chip order stays stable while switching.
        currentLocation = location
    }

    func removeSaved(_ location: SunriseLocation) {
        savedLocations.removeAll { samePlace($0, location) }
        persistSavedLocations()
    }

    /// Append newly picked places without reordering existing chips.
    private func rememberIfNeeded(_ location: SunriseLocation) {
        let address = location.address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else { return }
        if savedLocations.contains(where: { samePlace($0, location) }) { return }

        savedLocations.append(location)
        if savedLocations.count > maxSaved {
            savedLocations = Array(savedLocations.suffix(maxSaved))
        }
        persistSavedLocations()
    }

    private func samePlace(_ lhs: SunriseLocation, _ rhs: SunriseLocation) -> Bool {
        abs(lhs.latitude - rhs.latitude) < 0.0001 &&
        abs(lhs.longitude - rhs.longitude) < 0.0001
    }

    private func loadSavedLocations() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        // Matches legacy AddLocationTableViewController storage
        savedLocations = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [SunriseLocation]) ?? []
    }

    private func persistSavedLocations() {
        let data = NSKeyedArchiver.archivedData(withRootObject: savedLocations)
        defaults.set(data, forKey: storageKey)
    }
}
