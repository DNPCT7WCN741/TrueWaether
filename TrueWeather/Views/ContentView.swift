import SwiftUI

struct ContentView: View {
    @State private var vm = WeatherViewModel()
    @AppStorage("appLanguage") private var lang: AppLanguage = .chinese
    @AppStorage("themeMode") private var theme: ThemeMode = .system

    var body: some View {
        NavigationStack {
            if let w = vm.unifiedWeather, let loc = vm.selectedLocation {
                WeatherMainView(weather: w, location: loc, vm: vm)
                    .navigationTitle("")
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) { vm.goToCitySelection() }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text(lang == .chinese ? "切换城市" : "Change City")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            Text(loc.displayName(lang))
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button { lang = lang.next } label: {
                                Text(lang.label)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                    }
            } else if vm.selectedCountry != nil {
                CityListView(vm: vm)
                    .navigationTitle("")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button { vm.selectedCountry = nil } label: {
                                HStack(spacing: 4) { Image(systemName: "chevron.left"); Text(lang == .chinese ? "返回" : "Back") }
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            let name = vm.allLocations.first(where: { $0.country == vm.selectedCountry }).map { $0.displayCountry(lang) } ?? ""
                            Text(name).font(.headline)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 12) {
                                Button { theme = theme.next } label: { Text(theme.label).font(.system(size: 15)) }
                                Button { lang = lang.next } label: { Text(lang.label).font(.system(size: 15, weight: .bold)) }
                            }
                        }
                    }
            } else if vm.locationStatus == .determining {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text(lang == .chinese ? "正在获取位置..." : "Getting location...")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                    Button {
                        vm.locationStatus = .denied
                    } label: {
                        Text(lang == .chinese ? "手动选择城市" : "Choose city manually")
                            .font(.system(size: 15))
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 12) {
                            Button { theme = theme.next } label: { Text(theme.label).font(.system(size: 15)) }
                            Button { lang = lang.next } label: { Text(lang.label).font(.system(size: 15, weight: .bold)) }
                        }
                    }
                }
            } else {
                CountrySearchView(vm: vm)
                    .navigationTitle(lang == .chinese ? "选择城市" : "Select City")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 12) {
                                Button { theme = theme.next } label: { Text(theme.label).font(.system(size: 15)) }
                                Button { lang = lang.next } label: { Text(lang.label).font(.system(size: 15, weight: .bold)) }
                            }
                        }
                    }
            }
        }
        .preferredColorScheme(theme.colorScheme)
        .onAppear { vm.requestLocation() }
    }
}
