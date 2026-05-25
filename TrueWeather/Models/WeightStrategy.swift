import Foundation

// MARK: - Weight Strategy

struct WeightStrategy {
    static func weights(for region: Region) -> [WeatherSource: Double] {
        switch region {
        case .mainlandChina: [.hefeng:0.45, .appleWeather:0.15, .weatherChannel:0.05, .openMeteo:0.10, .openWeatherMap:0.15, .accuWeather:0.10]
        case .japanKorea: [.hefeng:0.30, .appleWeather:0.20, .weatherChannel:0.10, .openMeteo:0.15, .openWeatherMap:0.15, .accuWeather:0.10]
        case .southeastAsia: [.hefeng:0.35, .appleWeather:0.15, .weatherChannel:0.10, .openMeteo:0.15, .openWeatherMap:0.15, .accuWeather:0.10]
        case .southAsia: [.hefeng:0.20, .appleWeather:0.15, .weatherChannel:0.15, .openMeteo:0.20, .openWeatherMap:0.20, .accuWeather:0.10]
        case .northAmerica: [.hefeng:0.05, .appleWeather:0.35, .weatherChannel:0.20, .openMeteo:0.15, .openWeatherMap:0.15, .accuWeather:0.10]
        case .europe: [.hefeng:0.05, .appleWeather:0.20, .weatherChannel:0.15, .openMeteo:0.25, .openWeatherMap:0.20, .accuWeather:0.15]
        case .oceania: [.hefeng:0.05, .appleWeather:0.30, .weatherChannel:0.15, .openMeteo:0.20, .openWeatherMap:0.20, .accuWeather:0.10]
        case .southAmerica: [.hefeng:0.05, .appleWeather:0.20, .weatherChannel:0.20, .openMeteo:0.25, .openWeatherMap:0.20, .accuWeather:0.10]
        case .africa: [.hefeng:0.05, .appleWeather:0.15, .weatherChannel:0.20, .openMeteo:0.30, .openWeatherMap:0.20, .accuWeather:0.10]
        case .middleEast: [.hefeng:0.05, .appleWeather:0.20, .weatherChannel:0.20, .openMeteo:0.25, .openWeatherMap:0.20, .accuWeather:0.10]
        case .global: [.hefeng:0.17, .appleWeather:0.17, .weatherChannel:0.17, .openMeteo:0.17, .openWeatherMap:0.16, .accuWeather:0.16]
        }
    }

    static func normalizedWeights(for region: Region, availableSources: Set<WeatherSource>) -> [WeatherSource: Double] {
        let raw = weights(for: region)
        let available = raw.filter { availableSources.contains($0.key) }
        let total = available.values.reduce(0, +)
        guard total > 0 else { return [:] }
        return available.mapValues { $0 / total }
    }
}
