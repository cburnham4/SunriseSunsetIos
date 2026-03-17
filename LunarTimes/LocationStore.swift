//
//  LocationStore.swift
//  Sunrise & Sunset
//

import Foundation
import Combine

final class LocationStore: ObservableObject {
    @Published var currentLocation: SunriseLocation?
}
