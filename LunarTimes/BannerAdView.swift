//
//  BannerAdView.swift
//  Sunrise & Sunset
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    private var hideForScreenshots: Bool {
        ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "1"
    }

    func makeUIView(context: Context) -> UIView {
        if hideForScreenshots {
            let spacer = UIView()
            spacer.backgroundColor = .clear
            spacer.isUserInteractionEnabled = false
            return spacer
        }
        let banner = GADBannerView()
        banner.adUnitID = adUnitID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            banner.rootViewController = root
        }
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
