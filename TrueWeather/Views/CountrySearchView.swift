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
                countryList
            }

            if let err = vm.errorMessage {
                Text(err).font(.system(size: 14)).foregroundColor(.red).padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var countryList: some View {
        let data = Dictionary(grouping: vm.allLocations) { $0.country }
        let countries = data.map { (code, cities) -> CountryGroup in
            let rep = cities.first!
            return CountryGroup(code: code, flag: rep.countryFlag, nameZH: rep.countryZH, nameEN: rep.country, cities: cities)
        }.sorted { $0.nameZH < $1.nameZH }

        return ScrollView {
            VStack(spacing: 0) {
                ForEach(countries) { c in
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
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
                        .padding(.horizontal, 16).padding(.vertical, 3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4).padding(.bottom, 20)
        }
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
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
            .padding(.vertical, 3)
        }
        .buttonStyle(.plain)
    }
}
