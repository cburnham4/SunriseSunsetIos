//
//  SunriseSunsetView.swift
//  Sunrise & Sunset
//

import SwiftUI
import lh_helpers

struct SunriseSunsetView: View {
    @ObservedObject var locationStore: LocationStore
    @State private var date = Date()
    @State private var showDatePicker = false
    @State private var showLocationPicker = false
    @State private var rows: [SunriseRow] = []
    @State private var isLoading = false

    private let c = ColorsConfig.self
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        f.timeZone = TimeZone.current
        return f
    }()
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = TimeZone.current
        return f
    }()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: c.backgroundGradientTop),
                    Color(uiColor: c.backgroundGradientBottom)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        locationPill
                        dateBar
                        VStack(spacing: 8) {
                            if isLoading {
                                ForEach(0..<9) { index in
                                    SunriseRowView(
                                        title: "Loading",
                                        value: "00:00",
                                        isAlt: index % 2 == 1
                                    )
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                                    if (index + 1) % 3 == 0 && index + 1 != 9 {
                                        Spacer().frame(height: 20)
                                    }
                                }
                            } else {
                                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                                    SunriseRowView(
                                        title: row.title,
                                        value: row.value,
                                        isAlt: index % 2 == 1
                                    )
                                    if (index + 1) % 3 == 0 && index + 1 != rows.count {
                                        Spacer().frame(height: 20)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
                .frame(maxHeight: .infinity)

                BannerAdView(adUnitID: "ca-app-pub-8223005482588566/7260467533")
                    .frame(height: 50)
            }
        }
        .navigationTitle("Sunrise & Sunset")
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
                fetchSunriseSunset()
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationStack {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                Button("Done") {
                    showDatePicker = false
                    fetchSunriseSunset()
                }
                .padding()
            }
        }
        .onAppear { fetchSunriseSunset() }
        .onChange(of: locationStore.currentLocation?.latitude) { _ in fetchSunriseSunset() }
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

    private var dateBar: some View {
        HStack(spacing: 16) {
            Button {
                date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
                fetchSunriseSunset()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(uiColor: c.primary))
                    .frame(width: 44, height: 44)
            }
            Button { showDatePicker = true } label: {
                Text(dateFormatter.string(from: date))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(uiColor: c.textPrimary))
            }
            .frame(maxWidth: .infinity)
            Button {
                date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
                fetchSunriseSunset()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(uiColor: c.primary))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func fetchSunriseSunset() {
        isLoading = true
        guard let loc = locationStore.currentLocation else { return }
        let destFormat = DateFormatter()
        destFormat.dateFormat = "yyyy-MM-dd"
        destFormat.timeZone = TimeZone.current
        let dateString = destFormat.string(from: date)
        let request = SunriseSunsetRequest(lat: loc.latitude, long: loc.longitude, dateString: dateString)
        request.makeRequest { response in
            DispatchQueue.main.async {
                isLoading = false
                switch response {
                case .failure: break
                case .success(let data): parseResult(data)
                }
            }
        }
    }

    private func parseResult(_ response: SunriseSunsetResponse) {
        let result = response.results
        let sourceFormat = DateFormatter()
        sourceFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        sourceFormat.timeZone = TimeZone(identifier: "UTC")
        guard let sunriseDate = sourceFormat.date(from: result.sunriseString),
              let sunsetDate = sourceFormat.date(from: result.sunsetString),
              let dawnDate = sourceFormat.date(from: result.dawnString),
              let duskDate = sourceFormat.date(from: result.duskString),
              let nauticalDawnDate = sourceFormat.date(from: result.nauticalDawn),
              let nauticalDuskDate = sourceFormat.date(from: result.nauticalDusk),
              let astronomicalDawnDate = sourceFormat.date(from: result.astronomicalDawn),
              let astronomicalDuskDate = sourceFormat.date(from: result.astronomicalDusk) else { return }
        let diff = sunsetDate.timeIntervalSince(sunriseDate)
        let timeDiff = stringFromTimeInterval(diff)
        rows = [
            SunriseRow(title: "Sunrise", value: timeFormatter.string(from: sunriseDate)),
            SunriseRow(title: "Sunset", value: timeFormatter.string(from: sunsetDate)),
            SunriseRow(title: "Daytime", value: timeDiff),
            SunriseRow(title: "Astronomical Dusk", value: timeFormatter.string(from: astronomicalDuskDate)),
            SunriseRow(title: "Nautical Dusk", value: timeFormatter.string(from: nauticalDuskDate)),
            SunriseRow(title: "Dusk", value: timeFormatter.string(from: duskDate)),
            SunriseRow(title: "Astronomical Dawn", value: timeFormatter.string(from: astronomicalDawnDate)),
            SunriseRow(title: "Nautical Dawn", value: timeFormatter.string(from: nauticalDawnDate)),
            SunriseRow(title: "Civil Dawn", value: timeFormatter.string(from: dawnDate))
        ]
    }

    private func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let minutes = (total / 60) % 60
        let hours = total / 3600
        return String(format: "%dh %02dm", hours, minutes)
    }
}

struct SunriseRow {
    let title: String
    let value: String
}

struct SunriseRowView: View {
    let title: String
    let value: String
    let isAlt: Bool
    private let c = ColorsConfig.self

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(uiColor: c.textPrimary))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(uiColor: c.textPrimary))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isAlt ? Color(uiColor: c.cardBackgroundAlt) : Color(uiColor: c.cardBackground))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -0.6

    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .overlay(
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let gradient = LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    Rectangle()
                        .fill(gradient)
                        .rotationEffect(.degrees(20))
                        .offset(x: phase * width)
                }
                .clipped()
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 0.6
                }
            }
    }
}

extension View {
    @ViewBuilder
    func shimmering(_ active: Bool = true) -> some View {
        if active {
            modifier(ShimmerModifier())
        } else {
            self
        }
    }
}
