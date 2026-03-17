//
//  WeatherView.swift
//  Sunrise & Sunset
//

import SwiftUI
import Kingfisher
import lh_helpers

struct WeatherView: View {
    @ObservedObject var locationStore: LocationStore
    @State private var weather: WeatherResponse?
    @State private var selectedSegment = 0
    @State private var showLocationPicker = false

    private let c = ColorsConfig.self

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        locationPill
                        heroSection
                        segmentBar
                        if selectedSegment == 0 {
                            hourlySection
                        } else {
                            dailySection
                        }
                    }
                    .padding(.bottom, 24)
                }
                .frame(maxHeight: .infinity)

                BannerAdView(adUnitID: "ca-app-pub-8223005482588566/3396819721")
                    .frame(height: 50)
            }
        }
        .navigationTitle("Weather")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showLocationPicker = true } label: {
                    Image(systemName: "location.fill")
                }
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerHostingView(currentLocation: locationStore.currentLocation) { location in
                locationStore.currentLocation = location
                showLocationPicker = false
                fetchWeather()
            }
        }
        .onAppear { fetchWeather() }
        .onChange(of: locationStore.currentLocation?.latitude) { _ in fetchWeather() }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(uiColor: c.backgroundGradientTop),
                Color(uiColor: c.backgroundGradientBottom)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var locationPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: c.accent))
            Text(locationStore.currentLocation?.address ?? "Getting location…")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(uiColor: c.textPrimary))
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: c.surfaceBar))
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            if let w = weather {
                HStack(alignment: .top, spacing: 20) {
                    if let url = w.current.iconURL {
                        KFImage(url)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 88, height: 88)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(w.current.temperature.map { "\(Int(round($0)))°" } ?? "—")
                            .font(.system(size: 56, weight: .thin, design: .rounded))
                            .foregroundColor(Color(uiColor: c.textPrimary))
                        Text(w.current.summary.capitalized)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(uiColor: c.textSecondary))
                        Text("Chance of rain \(w.currentPrecipProbabilityString)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(uiColor: c.textSecondary).opacity(0.9))
                    }
                    Spacer(minLength: 0)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: c.surfaceBar))
                        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)
            } else {
                HStack(alignment: .top, spacing: 20) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: c.textSecondary).opacity(0.2))
                        .frame(width: 88, height: 88)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("—°")
                            .font(.system(size: 56, weight: .thin, design: .rounded))
                            .foregroundColor(Color(uiColor: c.textPrimary))
                        Text("Loading…")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(uiColor: c.textSecondary))
                    }
                    Spacer(minLength: 0)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: c.surfaceBar))
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .shimmering()
            }
        }
    }

    private var segmentBar: some View {
        HStack(spacing: 0) {
            segmentButton(title: "Hourly", tag: 0)
            segmentButton(title: "Week", tag: 1)
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: c.surfaceBar).opacity(0.8))
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private func segmentButton(title: String, tag: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedSegment = tag }
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(selectedSegment == tag ? .white : Color(uiColor: c.textPrimary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if selectedSegment == tag {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(uiColor: c.primary))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.clear)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    private var hourlySection: some View {
        let items = weather?.hourlyWeathers ?? []
        return VStack(alignment: .leading, spacing: 12) {
            Text("Hourly forecast")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(uiColor: c.textPrimary))
                .padding(.horizontal, 20)
                .padding(.top, 24)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(items.prefix(24).enumerated()), id: \.offset) { _, h in
                        VStack(spacing: 8) {
                            Text(h.time)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(uiColor: c.textSecondary))
                            if let url = h.iconURL {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            Text(h.temp.map { "\(Int(round($0)))°" } ?? "—")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(uiColor: c.textPrimary))
                        }
                        .frame(width: 76)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: c.cardBackground))
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
            .frame(height: 140)
        }
    }

    private var dailySection: some View {
        let items = weather?.dailyWeather ?? []
        return VStack(alignment: .leading, spacing: 12) {
            Text("7-day forecast")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(uiColor: c.textPrimary))
                .padding(.horizontal, 20)
                .padding(.top, 24)
            VStack(spacing: 8) {
                ForEach(Array(items.prefix(7).enumerated()), id: \.offset) { _, d in
                    HStack(spacing: 16) {
                        Text(d.dayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(uiColor: c.textPrimary))
                            .frame(width: 80, alignment: .leading)
                        if let url = d.iconURL {
                            KFImage(url)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                        }
                        Spacer(minLength: 8)
                        Text(d.tempHigh.map { "\(Int(round($0)))°" } ?? "—")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(uiColor: c.textPrimary))
                        Text(d.tempLow.map { "\(Int(round($0)))°" } ?? "—")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(uiColor: c.textSecondary))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(uiColor: c.cardBackground))
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func fetchWeather() {
        guard let loc = locationStore.currentLocation else { return }
        let request = WeatherRequest(latitude: loc.latitude, longitude: loc.longitude)
        request.makeRequest { response in
            switch response {
            case .failure: break
            case .success(let w): weather = w
            }
        }
    }
}
