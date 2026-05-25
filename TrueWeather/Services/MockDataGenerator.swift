import Foundation

// MARK: - Mock Data Generator

struct MockDataGenerator {
    struct Bias { let temperatureOffset, humidityOffset, windSpeedOffset, pressureOffset: Double; let conditionVariant: Int }

    static func generate(for location: Location, bias: Bias, source: WeatherSource) -> RawWeatherData {
        let now = Date(); let cal = Calendar.current
        let doy = cal.ordinality(of: .day, in: .year, for: now) ?? 180
        let hour = cal.component(.hour, from: now)
        let lat = location.latitude.magnitude; let isSouth = location.latitude < 0
        let peakDay = isSouth ? 355 : 172
        let daysFromPeak = Double((doy - peakDay + 365) % 365)
        let seasonal = 15.0 * cos(daysFromPeak / 365.0 * 2 * .pi)
        let latBase = 36.0 - lat * 0.65
        let baseTemp = latBase + seasonal + bias.temperatureOffset
        let temp = (baseTemp + Double.random(in: -1.5...1.5)).rounded(1)
        let fl = (baseTemp - 1.5 + Double.random(in: -1...1) + bias.temperatureOffset * 0.7).rounded(1)
        let baseHum: Double = lat < 10 ? 75 : lat < 30 ? 55 + abs(seasonal)*0.5 : lat < 50 ? 65 : 70
        let hum = min(100, max(5, baseHum + bias.humidityOffset + Double.random(in: -8...8))).rounded()
        let baseWind: Double = lat < 15 ? 8 : lat < 35 ? 12 : lat < 50 ? 15 : 18
        let ws = max(0, baseWind + bias.windSpeedOffset + Double.random(in: -3...3) + (hour >= 12 && hour <= 18 ? 5 : 0)).rounded(1)
        let pres = (1013.0 - lat * 0.8 + Double.random(in: -5...5) + bias.pressureOffset).rounded(1)
        let vis = max(1, (15 - hum * 0.12 + Double.random(in: -2...2)).rounded(1))
        let baseUV: Double = lat < 15 ? 9 : lat < 35 ? 7 : lat < 50 ? 5 : 3
        let df = 1 - 0.5 * abs(cos((Double(doy)-172)/365 * 2 * .pi))
        let hf: Double = (hour >= 10 && hour <= 16) ? 1 : (hour >= 8 && hour <= 18) ? 0.5 : 0.1
        let uv = max(0, Int((baseUV * df * hf).rounded()))
        let rng = (doy * 7 + bias.conditionVariant * 13) % 100
        let cc: Int
        if lat > 55 && seasonal < -5 { cc = rng < 40 ? 10 : rng < 70 ? 3 : 0 }
        else if lat < 20 && hum > 70 { cc = rng < 35 ? 5 : rng < 60 ? 3 : 0 }
        else if lat < 35 && seasonal > 8 { cc = rng < 30 ? 0 : rng < 50 ? 1 : 3 }
        else if hum > 80 { cc = rng < 45 ? 5 : rng < 65 ? 3 : 2 }
        else { cc = rng < 15 ? 3 : rng < 35 ? 1 : rng < 55 ? 2 : 0 }
        let conds = conditionKeys
        let sod = cal.startOfDay(for: now)
        let hourly = (0..<24).map { h in
            let time = cal.date(byAdding: .hour, value: h, to: sod) ?? now
            let hh: Double = (h >= 6 && h <= 18) ? 0 : -5
            return HourlyData(time: time, temperature: (latBase + seasonal + hh + bias.temperatureOffset + Double.random(in: -1...1)).rounded(1),
                condition: conds[(h*3+bias.conditionVariant)%11], humidity: min(100,max(5,(60+Double.random(in:-10...10)+bias.humidityOffset).rounded())),
                windSpeed: max(0, (8+Double.random(in:-3...3)+bias.windSpeedOffset).rounded(1)))
        }
        let daily = (0..<7).map { d in
            let dd = cal.date(byAdding: .day, value: d, to: sod) ?? now
            let adj = (doy + d - 1 + 365) % 365; let fs = 15*cos(Double(adj-peakDay)/365 * 2 * .pi)
            return DailyData(date: dd, highTemperature: (latBase+fs+bias.temperatureOffset+Double.random(in:0...3)).rounded(1),
                lowTemperature: (latBase+fs+bias.temperatureOffset-Double.random(in:5...10)).rounded(1),
                condition: conds[(d*7+bias.conditionVariant+13)%11], humidity: min(100,max(5,(60+Double.random(in:-10...10)+bias.humidityOffset).rounded())),
                windSpeed: max(0,(8+Double.random(in:-3...3)+bias.windSpeedOffset).rounded(1)), precipitationProbability: Double.random(in:0...60).rounded())
        }
        return RawWeatherData(source: source, temperature: temp, feelsLike: fl, condition: conds[cc%11], conditionCode: cc,
            humidity: hum, windSpeed: ws, windDirection: Double.random(in:0...360).rounded(), pressure: pres, visibility: vis,
            uvIndex: uv, hourlyForecast: hourly, dailyForecast: daily)
    }
}
