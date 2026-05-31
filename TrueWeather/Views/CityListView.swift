import SwiftUI

struct CityListView: View {
    @Bindable var vm: WeatherViewModel
    @AppStorage("appLanguage") private var lang: AppLanguage = .chinese

    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                Spacer(); ProgressView(lang == .chinese ? "正在获取天气数据..." : "Fetching weather data..."); Spacer()
            } else {
                cityIndexedList
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var cityIndexedList: some View {
        let cities = vm.citiesForCountry(vm.selectedCountry ?? "")
        let sections = alphabetizedCities(cities)

        return ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sections, id: \.letter) { section in
                            Section {
                                ForEach(section.cities) { city in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) { vm.selectCity(city) }
                                        Task { await vm.fetchWeather() }
                                    } label: {
                                        HStack(spacing: 14) {
                                            Text(city.countryFlag).font(.system(size: 30))
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(city.displayName(lang))
                                                    .font(.system(size: 17, weight: .medium))
                                                Text(city.displayAdminArea(lang))
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
                                    .id(city.id)
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
                    .padding(.bottom, 20)
                }

                LetterIndexBar(letters: sections.map(\.letter)) { letter in
                    if let section = sections.first(where: { $0.letter == letter }),
                       let first = section.cities.first {
                        withAnimation { proxy.scrollTo(first.id, anchor: .top) }
                    }
                }
                .frame(width: 18)
                .padding(.trailing, 3)
            }
        }
    }

    private func alphabetizedCities(_ cities: [Location]) -> [(letter: String, cities: [Location])] {
        let dict = Dictionary(grouping: cities) { firstLetter($0.nameEN) }
        return dict.map { ($0.key, $0.value.sorted { $0.nameEN < $1.nameEN }) }
            .sorted { $0.0 < $1.0 }
    }
}
