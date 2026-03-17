//
//  LaunchLoadingView.swift
//  Sunrise & Sunset
//

import SwiftUI

struct LaunchLoadingView: View {
    private let c = ColorsConfig.self

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: c.backgroundGradientTop),
                    Color(uiColor: c.backgroundGradientBottom)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "sun.and.horizon.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        Color(uiColor: c.primary),
                        Color(uiColor: c.accent)
                    )

                Text("Sunrise & Sunset")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(uiColor: c.textPrimary))

                Text("Getting things ready…")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(uiColor: c.textSecondary))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 32)
        }
    }
}
