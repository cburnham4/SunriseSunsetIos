//
//  LocationPickerHostingView.swift
//  Sunrise & Sunset
//

import SwiftUI
import UIKit
import lh_helpers

struct LocationPickerHostingView: UIViewControllerRepresentable {
    let currentLocation: SunriseLocation?
    let onLocationSelected: (SunriseLocation) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewModel = AddLocationViewModel(sunriseLocation: currentLocation)
        let tableVC = AddLocationTableViewController.viewController(viewModel: viewModel)
        viewModel.delegate = context.coordinator
        return UINavigationController(rootViewController: tableVC)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onLocationSelected)
    }

    final class Coordinator: NSObject, LocationSelectedDelegate {
        let onSelect: (SunriseLocation) -> Void
        init(onSelect: @escaping (SunriseLocation) -> Void) { self.onSelect = onSelect }
        func locationSelected(selectedLocation: SunriseLocation) { onSelect(selectedLocation) }
    }
}
