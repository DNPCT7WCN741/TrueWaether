import SwiftUI

struct CityListView: View {
    @Bindable var vm: WeatherViewModel
    @AppStorage("appLanguage") private var lang: AppLanguage = .chinese

    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                Spacer(); ProgressView(lang == .chinese ? "正在获取天气数据..." : "Fetching weather data..."); Spacer()
            } else {
                let cities = vm.citiesForCountry(vm.selectedCountry ?? "")
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(cities) { city in
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
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
                                .padding(.horizontal, 16).padding(.vertical, 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
