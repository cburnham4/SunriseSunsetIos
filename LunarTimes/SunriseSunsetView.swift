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
    @State private var snapshot: DaylightSnapshot?
    @State private var isLoading = false
    @State private var errorMessage: String?

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
                        savedLocationsBar
                        dateBar
                        if let errorMessage, !isLoading {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 4)
                        }
                        if let snapshot, !isLoading {
                            todayHero(snapshot)
                        }
                        VStack(spacing: 8) {
                            if isLoading {
                                ForEach(0..<9, id: \.self) { index in
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
                .refreshable { await refreshAsync() }
                .frame(maxHeight: .infinity)

                BannerAdView(adUnitID: "ca-app-pub-8223005482588566/7260467533")
                    .frame(height: 50)
            }
        }
        .navigationTitle("Sunrise & Sunset")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if let snapshot {
                    ShareLink(item: shareText(for: snapshot)) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
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
        .onChange(of: locationStore.currentLocation?.longitude) { _ in fetchSunriseSunset() }
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

    @ViewBuilder
    private var savedLocationsBar: some View {
        let saved = locationStore.savedLocations
        if !saved.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(saved.enumerated()), id: \.offset) { _, location in
                        let selected = isSelected(location)
                        Button {
                            locationStore.selectSaved(location)
                        } label: {
                            Text(shortLabel(for: location))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selected ? .white : Color(uiColor: c.textPrimary))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selected ? Color(uiColor: c.primary) : Color(uiColor: c.cardBackground))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(Color(uiColor: c.surfaceBar).opacity(0.55))
        }
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

    private func todayHero(_ snap: DaylightSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(snap.nextEventTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(uiColor: c.textSecondary))
                .textCase(.uppercase)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: snap.nextEventIsSunrise ? "sunrise.fill" : "sunset.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(uiColor: c.accent))
                Text(timeFormatter.string(from: snap.nextEventDate))
                    .font(.system(size: 40, weight: .thin, design: .rounded))
                    .foregroundColor(Color(uiColor: c.textPrimary))
                Spacer(minLength: 0)
            }

            HStack(spacing: 16) {
                heroStat(title: "Sunrise", value: timeFormatter.string(from: snap.sunrise))
                heroStat(title: "Sunset", value: timeFormatter.string(from: snap.sunset))
                heroStat(title: "Daylight", value: snap.dayLengthText)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(uiColor: c.surfaceBar))
                .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func heroStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(uiColor: c.textSecondary))
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Color(uiColor: c.textPrimary))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func shortLabel(for location: SunriseLocation) -> String {
        let address = location.address
        if address.isEmpty { return "Saved" }
        return address.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? address
    }

    private func isSelected(_ location: SunriseLocation) -> Bool {
        guard let current = locationStore.currentLocation else { return false }
        return abs(current.latitude - location.latitude) < 0.0001 &&
            abs(current.longitude - location.longitude) < 0.0001
    }

    private func shareText(for snap: DaylightSnapshot) -> String {
        let place = locationStore.currentLocation?.address ?? "Current location"
        return """
        Sunrise & Sunset — \(dateFormatter.string(from: date))
        \(place)
        Sunrise: \(timeFormatter.string(from: snap.sunrise))
        Sunset: \(timeFormatter.string(from: snap.sunset))
        Daylight: \(snap.dayLengthText)
        """
    }

    @MainActor
    private func refreshAsync() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            fetchSunriseSunset {
                continuation.resume()
            }
        }
    }

    private func fetchSunriseSunset(completion: (() -> Void)? = nil) {
        isLoading = true
        errorMessage = nil
        guard let loc = locationStore.currentLocation else {
            isLoading = false
            rows = []
            snapshot = nil
            errorMessage = "Unable to get your location. Please try again."
            completion?()
            return
        }
        let destFormat = DateFormatter()
        destFormat.locale = Locale(identifier: "en_US_POSIX")
        destFormat.dateFormat = "yyyy-MM-dd"
        destFormat.timeZone = TimeZone.current
        let dateString = destFormat.string(from: date)
        let request = SunriseSunsetRequest(lat: loc.latitude, long: loc.longitude, dateString: dateString)
        request.makeRequest { response in
            DispatchQueue.main.async {
                isLoading = false
                switch response {
                case .failure:
                    rows = []
                    snapshot = nil
                    errorMessage = "Couldn’t load sunrise/sunset right now. Please try again."
                case .success(let data):
                    parseResult(data)
                }
                completion?()
            }
        }
    }

    private func parseResult(_ response: SunriseSunsetResponse) {
        let result = response.results
        guard let sunriseDate = Self.parseAPIDate(result.sunriseString),
              let sunsetDate = Self.parseAPIDate(result.sunsetString),
              let dawnDate = Self.parseAPIDate(result.dawnString),
              let duskDate = Self.parseAPIDate(result.duskString),
              let nauticalDawnDate = Self.parseAPIDate(result.nauticalDawn),
              let nauticalDuskDate = Self.parseAPIDate(result.nauticalDusk),
              let astronomicalDawnDate = Self.parseAPIDate(result.astronomicalDawn),
              let astronomicalDuskDate = Self.parseAPIDate(result.astronomicalDusk) else {
            rows = []
            snapshot = nil
            errorMessage = "Sunrise/sunset data format was unexpected. Please try again."
            return
        }

        let dayLength = sunsetDate.timeIntervalSince(sunriseDate)
        let dayLengthText = stringFromTimeInterval(dayLength)

        snapshot = DaylightSnapshot(
            sunrise: sunriseDate,
            sunset: sunsetDate,
            dayLengthText: dayLengthText
        )

        rows = [
            SunriseRow(title: "Sunrise", value: timeFormatter.string(from: sunriseDate)),
            SunriseRow(title: "Sunset", value: timeFormatter.string(from: sunsetDate)),
            SunriseRow(title: "Daytime", value: dayLengthText),
            SunriseRow(title: "Astronomical Dusk", value: timeFormatter.string(from: astronomicalDuskDate)),
            SunriseRow(title: "Nautical Dusk", value: timeFormatter.string(from: nauticalDuskDate)),
            SunriseRow(title: "Dusk", value: timeFormatter.string(from: duskDate)),
            SunriseRow(title: "Astronomical Dawn", value: timeFormatter.string(from: astronomicalDawnDate)),
            SunriseRow(title: "Nautical Dawn", value: timeFormatter.string(from: nauticalDawnDate)),
            SunriseRow(title: "Civil Dawn", value: timeFormatter.string(from: dawnDate))
        ]
        errorMessage = nil
    }

    /// Parse sunrise-sunset.org ISO timestamps robustly across locales.
    private static func parseAPIDate(_ string: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: string) { return date }

        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: string) { return date }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = formatter.date(from: string) { return date }

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: string)
    }

    private func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval))
        let minutes = (total / 60) % 60
        let hours = total / 3600
        return String(format: "%dh %02dm", hours, minutes)
    }
}

struct DaylightSnapshot {
    let sunrise: Date
    let sunset: Date
    let dayLengthText: String

    var nextEventIsSunrise: Bool {
        let now = Date()
        if now < sunrise { return true }
        if now < sunset { return false }
        return true
    }

    var nextEventDate: Date {
        nextEventIsSunrise ? sunrise : sunset
    }

    var nextEventTitle: String {
        let calendar = Calendar.current
        let now = Date()
        if calendar.isDateInToday(sunrise) || calendar.isDateInToday(sunset) {
            if now < sunrise { return "Next up · Sunrise" }
            if now < sunset { return "Next up · Sunset" }
            return "Tomorrow’s first light · Sunrise"
        }
        return nextEventIsSunrise ? "Sunrise" : "Sunset"
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
                .multilineTextAlignment(.trailing)
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
