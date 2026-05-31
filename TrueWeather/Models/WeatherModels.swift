import Foundation
import SwiftUI

// MARK: - Weather Source

enum WeatherSource: String, CaseIterable, Codable {
    case hefeng, appleWeather, weatherChannel, openMeteo, openWeatherMap, accuWeather
    case bom, breezometer, cma, dwd, eccc, eumetnet, ecmwf, imd, inmet, jma, meteofrance, noaa, smn, tmd, metoffice

    var name: String {
        switch self {
        case .hefeng: "和风天气"; case .appleWeather: "Apple Weather"
        case .weatherChannel: "The Weather Channel"; case .openMeteo: "Open-Meteo"
        case .openWeatherMap: "OpenWeatherMap"; case .accuWeather: "AccuWeather"
        case .bom: "BOM"; case .breezometer: "BreezoMeter"
        case .cma: "中国气象局"; case .dwd: "Deutscher Wetterdienst"
        case .eccc: "ECCC"; case .eumetnet: "EUMETNET"
        case .ecmwf: "ECMWF"; case .imd: "IMD"
        case .inmet: "INMET"; case .jma: "気象庁"
        case .meteofrance: "Météo-France"; case .noaa: "NOAA"
        case .smn: "SMN"; case .tmd: "TMD"
        case .metoffice: "Met Office"
        }
    }

    var shortName: String {
        switch self {
        case .hefeng: "和风"; case .appleWeather: "Apple"; case .weatherChannel: "TWC"
        case .openMeteo: "Meteo"; case .openWeatherMap: "OWM"; case .accuWeather: "Accu"
        case .bom: "BOM"; case .breezometer: "Breezo"; case .cma: "CMA"
        case .dwd: "DWD"; case .eccc: "ECCC"; case .eumetnet: "EUMETNET"
        case .ecmwf: "ECMWF"; case .imd: "IMD"; case .inmet: "INMET"
        case .jma: "JMA"; case .meteofrance: "Météo"; case .noaa: "NOAA"
        case .smn: "SMN"; case .tmd: "TMD"; case .metoffice: "MetOffice"
        }
    }

    var systemImage: String {
        switch self {
        case .hefeng: "leaf.circle.fill"; case .appleWeather: "apple.logo"
        case .weatherChannel: "tv.circle.fill"; case .openMeteo: "globe.europe.africa.fill"
        case .openWeatherMap: "map.circle.fill"; case .accuWeather: "sun.max.circle.fill"
        case .bom: "globe.asia.australia.fill"; case .breezometer: "wind"
        case .cma: "building.2.fill"; case .dwd: "flag.fill"
        case .eccc: "snowflake"; case .eumetnet: "antenna.radiowaves.left.and.right"
        case .ecmwf: "globe.europe.africa.fill"; case .imd: "sun.max.fill"
        case .inmet: "globe.americas.fill"; case .jma: "cloud.fill"
        case .meteofrance: "cloud.sun.fill"; case .noaa: "cloud.bolt.fill"
        case .smn: "sun.horizon.fill"; case .tmd: "cloud.sun.rain.fill"
        case .metoffice: "cloud.moon.fill"
        }
    }

    var color: Color {
        switch self {
        case .hefeng: Color(red: 0.898, green: 0.243, blue: 0.243)
        case .appleWeather: Color(red: 0, green: 0.478, blue: 1)
        case .weatherChannel: Color(red: 0.118, green: 0.533, blue: 0.898)
        case .openMeteo: Color(red: 0.263, green: 0.627, blue: 0.278)
        case .openWeatherMap: Color(red: 0.984, green: 0.549, blue: 0)
        case .accuWeather: Color(red: 0.957, green: 0.318, blue: 0.118)
        case .bom: Color(red: 0, green: 0.2, blue: 0.55)
        case .breezometer: Color(red: 0.2, green: 0.7, blue: 0.7)
        case .cma: Color(red: 0.7, green: 0.1, blue: 0.1)
        case .dwd: Color(red: 0.2, green: 0.2, blue: 0.25)
        case .eccc: Color(red: 0.8, green: 0.15, blue: 0.15)
        case .eumetnet: Color(red: 0.15, green: 0.2, blue: 0.6)
        case .ecmwf: Color(red: 0.45, green: 0.2, blue: 0.65)
        case .imd: Color(red: 0.9, green: 0.45, blue: 0.1)
        case .inmet: Color(red: 0.1, green: 0.55, blue: 0.2)
        case .jma: Color(red: 0.25, green: 0.25, blue: 0.55)
        case .meteofrance: Color(red: 0, green: 0.3, blue: 0.65)
        case .noaa: Color(red: 0, green: 0.15, blue: 0.4)
        case .smn: Color(red: 0.15, green: 0.45, blue: 0.3)
        case .tmd: Color(red: 0.75, green: 0.55, blue: 0.1)
        case .metoffice: Color(red: 0.05, green: 0.3, blue: 0.2)
        }
    }
}

// MARK: - Weather Data

struct HourlyData: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let condition: String
    let humidity: Double
    let windSpeed: Double
}

struct DailyData: Identifiable {
    let id = UUID()
    let date: Date
    let highTemperature: Double
    let lowTemperature: Double
    let condition: String
    let humidity: Double
    let windSpeed: Double
    let precipitationProbability: Double
}

struct RawWeatherData {
    let source: WeatherSource
    let temperature, feelsLike: Double
    let condition: String
    let conditionCode: Int
    let humidity, windSpeed, windDirection, pressure, visibility: Double
    let uvIndex: Int
    let hourlyForecast: [HourlyData]
    let dailyForecast: [DailyData]
}

struct SourceContribution: Identifiable {
    let id = UUID()
    let source: WeatherSource
    let weight, effectiveWeight: Double
    let data: RawWeatherData?
    let isAvailable: Bool
    var contributionPercent: Double { isAvailable ? effectiveWeight * 100 : 0 }
}

struct UnifiedWeather {
    let temperature, feelsLike, humidity, windSpeed, windDirection, pressure, visibility: Double
    let condition: String
    let uvIndex: Int
    let hourlyForecast: [HourlyData]
    let dailyForecast: [DailyData]
    let sourceContributions: [SourceContribution]
    let effectiveWeights: [WeatherSource: Double]
    let fetchTimestamp: Date
    var availableSourceCount: Int { sourceContributions.filter(\.isAvailable).count }
    var totalSourceCount: Int { sourceContributions.count }
}

// MARK: - Condition Helpers

let conditionKeys = ["晴","多云转晴","多云","阴天","雨","雷暴","小雨","雾","大风","霾","雪"]

func conditionEN(_ c: String) -> String {
    switch c {
    case "晴": "Sunny"; case "多云转晴": "Partly Cloudy"; case "多云": "Cloudy"; case "阴天": "Overcast"
    case "雨": "Rain"; case "雷暴": "Thunderstorm"; case "小雨": "Drizzle"; case "雾": "Fog"
    case "大风": "Windy"; case "霾": "Haze"; case "雪": "Snow"; default: c
    }
}

func conditionIcon(_ c: String) -> String {
    switch c {
    case "晴": "sun.max.fill"; case "多云转晴": "cloud.sun.fill"; case "多云": "cloud.fill"
    case "阴天": "smoke.fill"; case "雨": "cloud.rain.fill"; case "雷暴": "cloud.bolt.rain.fill"
    case "小雨": "cloud.drizzle.fill"; case "雾": "cloud.fog.fill"; case "大风": "wind"
    case "霾": "sun.haze.fill"; case "雪": "cloud.snow.fill"; default: "sun.max.fill"
    }
}

func conditionDisplay(_ c: String, _ lang: AppLanguage) -> String { lang == .chinese ? c : conditionEN(c) }

extension Double { func rounded(_ p: Int) -> Double { let m = pow(10, Double(p)); return (self * m).rounded() / m } }

func fmtTemp(_ t: Double, _ unit: TemperatureUnit = .celsius) -> String { String(format: "%.0f°", unit.convert(t)) }
func fmtHour(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: d) }
func fmtDay(_ d: Date, _ lang: AppLanguage) -> String {
    let f = DateFormatter(); f.locale = Locale(identifier: lang == .chinese ? "zh_CN" : "en_US"); f.dateFormat = "EEE"
    return f.string(from: d)
}
func fmtTime(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "HH:mm:ss"; return f.string(from: d) }

func isDaytime(lat: Double, lon: Double, date: Date = Date()) -> Bool {
    let cal = Calendar.current
    let doy = Double(cal.ordinality(of: .day, in: .year, for: date) ?? 180)
    let h = Double(cal.component(.hour, from: date))
    let m = Double(cal.component(.minute, from: date))
    let dec = 23.45 * sin(2 * .pi / 365 * (doy - 81)) * .pi / 180
    let latR = lat * .pi / 180
    let cosHA = -tan(latR) * tan(dec)
    if cosHA >= 1 { return true }
    if cosHA <= -1 { return false }
    let ha = acos(cosHA) * 180 / .pi / 15
    let b = 2 * .pi / 365 * (doy - 81)
    let eot = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b)
    let noon = 12.0 - lon / 15.0 - eot / 60.0
    let now = h + m / 60.0
    return now >= noon - ha && now <= noon + ha
}
