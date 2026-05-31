import SwiftUI

struct CountrySearchView: View {
    @Bindable var vm: WeatherViewModel
    @AppStorage("appLanguage") private var lang: AppLanguage = .chinese

    var body: some View {
        VStack(spacing: 0) {
            if let userLoc = vm.userLocationCity {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { vm.selectCity(userLoc) }
                    Task { await vm.fetchWeather() }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.blue)
                            .symbolEffect(.pulse, options: .repeating)
                        Text(userLoc.displayName(lang))
                            .font(.system(size: 17, weight: .medium))
                        Spacer()
                        Text(lang == .chinese ? "当前位置" : "Current Location")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16).padding(.top, 12)
            }

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))
                TextField(lang == .chinese ? "搜索城市..." : "Search cities...", text: $vm.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                if !vm.searchQuery.isEmpty {
                    Button { withAnimation { vm.searchQuery = "" } } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            .padding(.horizontal, 16).padding(.vertical, 10)

            if vm.isLoading {
                Spacer()
                ProgressView(lang == .chinese ? "正在获取天气数据..." : "Fetching weather data...")
                Spacer()
            } else if !vm.searchQuery.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.filteredLocations) { city in
                            cityButton(city)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                countryIndexedList
            }

            if let err = vm.errorMessage {
                Text(err).font(.system(size: 14)).foregroundColor(.red).padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var countryIndexedList: some View {
        let sections = alphabetizedCountries

        return ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sections, id: \.letter) { section in
                            Section {
                                ForEach(section.countries) { c in
                                    Button {
                                        withAnimation { vm.selectedCountry = c.code }
                                    } label: {
                                        HStack(spacing: 14) {
                                            Text(c.flag).font(.system(size: 30))
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(lang == .chinese ? c.nameZH : c.nameEN)
                                                    .font(.system(size: 17, weight: .medium))
                                                Text("\(c.cities.count) \(lang == .chinese ? "个城市" : "cities")")
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(.secondary.opacity(0.5))
                                        }
                                        .padding(.horizontal, 16).padding(.vertical, 12)
                                        .padding(.trailing, -30)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
                                        .padding(.horizontal, 16).padding(.vertical, 3)
                                    }
                                    .buttonStyle(.plain)
                                    .id(c.code)
                                }
                            } header: {
                                HStack {
                                    Text(section.letter)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 24).padding(.vertical, 8)
                                .padding(.trailing, -30)
                                .background(Color(.systemGroupedBackground))
                            }
                        }
                    }
                    .padding(.top, 4).padding(.bottom, 20)
                }

                LetterIndexBar(letters: sections.map(\.letter)) { letter in
                    if let section = sections.first(where: { $0.letter == letter }),
                       let first = section.countries.first {
                        withAnimation { proxy.scrollTo(first.code, anchor: .top) }
                    }
                }
                .frame(width: 18)
                .padding(.trailing, 3)
            }
        }
    }

    private var alphabetizedCountries: [(letter: String, countries: [CountryGroup])] {
        let data = Dictionary(grouping: vm.allLocations) { $0.country }
        let groups = data.map { (code, cities) -> CountryGroup in
            let rep = cities.first!
            return CountryGroup(code: code, flag: rep.countryFlag, nameZH: rep.countryZH, nameEN: countryDisplayName(code), cities: cities)
        }
        let dict = Dictionary(grouping: groups) { firstLetter($0.nameEN) }
        return dict.map { ($0.key, $0.value.sorted { $0.nameEN < $1.nameEN }) }
            .sorted { $0.0 < $1.0 }
    }

    private func cityButton(_ city: Location) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) { vm.selectCity(city) }
            Task { await vm.fetchWeather() }
        } label: {
            HStack(spacing: 14) {
                Text(city.countryFlag).font(.system(size: 30))
                VStack(alignment: .leading, spacing: 3) {
                    Text(city.displayName(lang))
                        .font(.system(size: 17, weight: .medium))
                    Text(city.subtitle(lang))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
                                        .padding(.trailing, -30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
            .padding(.vertical, 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Letter Index Bar

struct LetterIndexBar: View {
    let letters: [String]
    let onSelect: (String) -> Void

    @State private var activeLetter: String?

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ForEach(letters, id: \.self) { letter in
                    Text(letter)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(activeLetter == letter ? .blue : .blue.opacity(0.6))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.vertical, 2)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let idx = min(max(0, Int(value.location.y / (geo.size.height / CGFloat(max(1, letters.count))))), letters.count - 1)
                        let letter = letters[idx]
                        if activeLetter != letter {
                            activeLetter = letter
                            onSelect(letter)
                        }
                    }
                    .onEnded { _ in activeLetter = nil }
            )
            .sensoryFeedback(.selection, trigger: activeLetter)
        }
    }
}

func firstLetter(_ s: String) -> String {
    let c = s.prefix(1).uppercased()
    return (c >= "A" && c <= "Z") ? c : "#"
}
