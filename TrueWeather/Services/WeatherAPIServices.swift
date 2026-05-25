import Foundation

// MARK: - Service Protocol

protocol WeatherAPIService { var source: WeatherSource { get }; func fetchWeather(for: Location) async throws -> RawWeatherData }

// MARK: - Services

struct HeFengService: WeatherAPIService {
    let source = WeatherSource.hefeng
    func fetchWeather(for loc: Location) async throws -> RawWeatherData {
        try await Task.sleep(nanoseconds: 200_000_000)
        return MockDataGenerator.generate(for: loc, bias: MockDataGenerator.Bias(temperatureOffset:0.5,humidityOffset:3,windSpeedOffset:-1,pressureOffset:2,conditionVariant:0), source: source)
    }
}
struct AppleWeatherService: WeatherAPIService {
    let source = WeatherSource.appleWeather
    func fetchWeather(for loc: Location) async throws -> RawWeatherData {
        try await Task.sleep(nanoseconds: 150_000_000)
        return MockDataGenerator.generate(for: loc, bias: MockDataGenerator.Bias(temperatureOffset:-0.3,humidityOffset:-2,windSpeedOffset:0.5,pressureOffset:-1,conditionVariant:1), source: source)
    }
}
struct WeatherChannelService: WeatherAPIService {
    let source = WeatherSource.weatherChannel
    func fetchWeather(for loc: Location) async throws -> RawWeatherData {
        try await Task.sleep(nanoseconds: 180_000_000)
        return MockDataGenerator.generate(for: loc, bias: MockDataGenerator.Bias(temperatureOffset:0.2,humidityOffset:-1,windSpeedOffset:1.5,pressureOffset:-0.5,conditionVariant:2), source: source)
    }
}
struct OpenMeteoService: WeatherAPIService {
    let source = WeatherSource.openMeteo
    func fetchWeather(for loc: Location) async throws -> RawWeatherData {
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(loc.latitude)&longitude=\(loc.longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,pressure_msl,weather_code,visibility&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&daily=temperature_2m_max,temperature_2m_min,wind_speed_10m_max,precipitation_probability_max,weather_code&timezone=auto"
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }
        var req = URLRequest(url: url); req.timeoutInterval = 10
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let j = try JSONSerialization.jsonObject(with: data) as? [String:Any], let c = j["current"] as? [String:Any] else { throw URLError(.cannotParseResponse) }
        let temp = c["temperature_2m"] as? Double ?? 0
        let fl = c["apparent_temperature"] as? Double ?? temp
        let hum = c["relative_humidity_2m"] as? Double ?? 50
        let ws = c["wind_speed_10m"] as? Double ?? 0
        let wd = c["wind_direction_10m"] as? Double ?? 0
        let pres = c["pressure_msl"] as? Double ?? 1013
        let code = c["weather_code"] as? Int ?? 0
        let vis = (c["visibility"] as? Double ?? 10000) / 1000
        let map: [Int] = [0,1,1,2,2,3,4,4,5,5,5,6,6,6,7,7,7,6,6,6,8,8]
        let cond = code < map.count ? conditionKeys[map[code]] : "多云转晴"
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd'T'HH:mm"
        var hf: [HourlyData] = []
        if let h = j["hourly"] as? [String:Any], let times = h["time"] as? [String],
           let temps = h["temperature_2m"] as? [Double], let hums = h["relative_humidity_2m"] as? [Double],
           let wss = h["wind_speed_10m"] as? [Double], let codes = h["weather_code"] as? [Int] {
            hf = zip(times, zip(temps, zip(hums, zip(wss, codes)))).prefix(24).map { t, rest in
                let (tp, (hm, (w, cd))) = rest
                return HourlyData(time: df.date(from: t) ?? Date(), temperature: tp,
                    condition: cd < map.count ? conditionKeys[map[cd]] : "多云转晴", humidity: hm, windSpeed: w)
            }
        }
        var dfc: [DailyData] = []
        if let d = j["daily"] as? [String:Any], let dates = d["time"] as? [String],
           let highs = d["temperature_2m_max"] as? [Double], let lows = d["temperature_2m_min"] as? [Double],
           let wss = d["wind_speed_10m_max"] as? [Double], let precip = d["precipitation_probability_max"] as? [Double],
           let codes = d["weather_code"] as? [Int] {
            let df2 = DateFormatter(); df2.dateFormat = "yyyy-MM-dd"
            dfc = zip(dates, zip(highs, zip(lows, zip(wss, zip(precip, codes))))).map { ds, rest in
                let (hi, (lo, (ws, (pp, cd)))) = rest
                return DailyData(date: df2.date(from: ds) ?? Date(), highTemperature: hi, lowTemperature: lo,
                    condition: cd < map.count ? conditionKeys[map[cd]] : "多云转晴", humidity: 60, windSpeed: ws, precipitationProbability: pp)
            }
        }
        return RawWeatherData(source: .openMeteo, temperature: temp, feelsLike: fl, condition: cond, conditionCode: code,
            humidity: hum, windSpeed: ws, windDirection: wd, pressure: pres, visibility: vis, uvIndex: 0,
            hourlyForecast: hf, dailyForecast: dfc)
    }
}
struct OpenWeatherMapService: WeatherAPIService {
    let source = WeatherSource.openWeatherMap
    func fetchWeather(for loc: Location) async throws -> RawWeatherData {
        try await Task.sleep(nanoseconds: 160_000_000)
        return MockDataGenerator.generate(for: loc, bias: MockDataGenerator.Bias(temperatureOffset:-0.1,humidityOffset:1,windSpeedOffset:-0.5,pressureOffset:1.5,conditionVariant:3), source: source)
    }
}
struct AccuWeatherService: WeatherAPIService {
    let source = WeatherSource.accuWeather
    func fetchWeather(for loc: Location) async throws -> RawWeatherData {
        try await Task.sleep(nanoseconds: 170_000_000)
        return MockDataGenerator.generate(for: loc, bias: MockDataGenerator.Bias(temperatureOffset:0.8,humidityOffset:-4,windSpeedOffset:2,pressureOffset:-2,conditionVariant:4), source: source)
    }
}
