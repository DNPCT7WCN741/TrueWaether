import Foundation

// MARK: - Weight Strategy

struct WeightStrategy {
    static func weights(for region: Region) -> [WeatherSource: Double] {
        switch region {
        case .mainlandChina:
            [.hefeng:0.22, .cma:0.18, .appleWeather:0.08, .weatherChannel:0.04, .openMeteo:0.06, .openWeatherMap:0.08, .accuWeather:0.05,
             .bom:0.02, .breezometer:0.02, .dwd:0.01, .eccc:0.01, .eumetnet:0.01, .ecmwf:0.02, .imd:0.01, .inmet:0.01,
             .jma:0.05, .meteofrance:0.01, .noaa:0.03, .smn:0.01, .tmd:0.02, .metoffice:0.02]
        case .japanKorea:
            [.jma:0.22, .hefeng:0.15, .appleWeather:0.10, .weatherChannel:0.05, .openMeteo:0.08, .openWeatherMap:0.08, .accuWeather:0.05,
             .bom:0.03, .breezometer:0.02, .cma:0.04, .dwd:0.01, .eccc:0.01, .eumetnet:0.01, .ecmwf:0.02, .imd:0.01, .inmet:0.01,
             .meteofrance:0.01, .noaa:0.04, .smn:0.01, .tmd:0.02, .metoffice:0.01]
        case .southeastAsia:
            [.tmd:0.15, .hefeng:0.14, .appleWeather:0.08, .weatherChannel:0.05, .openMeteo:0.10, .openWeatherMap:0.08, .accuWeather:0.05,
             .bom:0.05, .breezometer:0.02, .cma:0.04, .dwd:0.01, .eccc:0.01, .eumetnet:0.01, .ecmwf:0.02, .imd:0.02, .inmet:0.01,
             .jma:0.04, .meteofrance:0.01, .noaa:0.04, .smn:0.01, .metoffice:0.02]
        case .southAsia:
            [.imd:0.22, .hefeng:0.08, .appleWeather:0.08, .weatherChannel:0.07, .openMeteo:0.10, .openWeatherMap:0.10, .accuWeather:0.05,
             .bom:0.03, .breezometer:0.02, .cma:0.02, .dwd:0.01, .eccc:0.01, .eumetnet:0.01, .ecmwf:0.02, .inmet:0.01,
             .jma:0.02, .meteofrance:0.01, .noaa:0.05, .smn:0.01, .tmd:0.03, .metoffice:0.03]
        case .northAmerica:
            [.noaa:0.20, .eccc:0.10, .appleWeather:0.12, .weatherChannel:0.08, .openMeteo:0.07, .openWeatherMap:0.07, .accuWeather:0.05,
             .smn:0.06, .bom:0.01, .breezometer:0.02, .cma:0.01, .dwd:0.01, .eumetnet:0.01, .ecmwf:0.02, .imd:0.01, .inmet:0.01,
             .jma:0.02, .meteofrance:0.01, .hefeng:0.02, .tmd:0.01, .metoffice:0.03]
        case .europe:
            [.ecmwf:0.14, .dwd:0.08, .meteofrance:0.08, .metoffice:0.08, .openMeteo:0.08, .eumetnet:0.06,
             .appleWeather:0.06, .weatherChannel:0.05, .openWeatherMap:0.06, .accuWeather:0.05,
             .bom:0.01, .breezometer:0.02, .cma:0.01, .eccc:0.01, .hefeng:0.02, .imd:0.01, .inmet:0.01,
             .jma:0.02, .noaa:0.04, .smn:0.01, .tmd:0.01]
        case .oceania:
            [.bom:0.22, .appleWeather:0.12, .weatherChannel:0.06, .openMeteo:0.08, .openWeatherMap:0.08, .accuWeather:0.05,
             .breezometer:0.02, .cma:0.01, .dwd:0.01, .eccc:0.01, .eumetnet:0.01, .ecmwf:0.02, .hefeng:0.03, .imd:0.01, .inmet:0.01,
             .jma:0.05, .meteofrance:0.01, .noaa:0.06, .smn:0.01, .tmd:0.03, .metoffice:0.04]
        case .southAmerica:
            [.inmet:0.18, .smn:0.10, .appleWeather:0.08, .weatherChannel:0.06, .openMeteo:0.10, .openWeatherMap:0.08, .accuWeather:0.05,
             .bom:0.02, .breezometer:0.02, .cma:0.01, .dwd:0.01, .eccc:0.01, .eumetnet:0.01, .ecmwf:0.02, .imd:0.01, .hefeng:0.02,
             .jma:0.02, .meteofrance:0.01, .noaa:0.08, .tmd:0.01, .metoffice:0.02]
        case .africa:
            [.openMeteo:0.14, .metoffice:0.10, .ecmwf:0.10, .appleWeather:0.08, .weatherChannel:0.07, .openWeatherMap:0.08, .accuWeather:0.06,
             .bom:0.02, .breezometer:0.02, .cma:0.01, .dwd:0.02, .eccc:0.01, .eumetnet:0.02, .hefeng:0.02, .imd:0.02, .inmet:0.02,
             .jma:0.02, .meteofrance:0.06, .noaa:0.06, .smn:0.01, .tmd:0.01]
        case .middleEast:
            [.ecmwf:0.12, .openMeteo:0.12, .metoffice:0.08, .appleWeather:0.08, .weatherChannel:0.07, .openWeatherMap:0.08, .accuWeather:0.06,
             .bom:0.02, .breezometer:0.02, .cma:0.01, .dwd:0.02, .eccc:0.01, .eumetnet:0.02, .hefeng:0.02, .imd:0.03, .inmet:0.01,
             .jma:0.02, .meteofrance:0.03, .noaa:0.06, .smn:0.01, .tmd:0.02]
        case .global:
            [.openMeteo:0.08, .appleWeather:0.08, .weatherChannel:0.06, .openWeatherMap:0.06, .accuWeather:0.05, .ecmwf:0.06,
             .hefeng:0.04, .cma:0.03, .jma:0.04, .bom:0.04, .dwd:0.04, .meteofrance:0.04, .metoffice:0.04, .noaa:0.05, .eccc:0.03,
             .eumetnet:0.03, .imd:0.03, .inmet:0.03, .smn:0.03, .tmd:0.03, .breezometer:0.03]
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
