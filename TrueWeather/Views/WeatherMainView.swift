import SwiftUI

struct WeatherMainView: View {
    let weather: UnifiedWeather; let location: Location; let vm: WeatherViewModel
    @AppStorage("appLanguage") private var lang: AppLanguage = .chinese
    @AppStorage("tempUnit") private var tempUnit: TemperatureUnit = .celsius

    private var isNight: Bool { !isDaytime(lat: location.latitude, lon: location.longitude) }

    private var cardBg: Color {
        isNight ? Color.white.opacity(0.10) : Color.black.opacity(0.20)
    }

    private var bgGradient: LinearGradient {
        if isNight {
            return LinearGradient(colors: [Color(red:0.05,green:0.08,blue:0.18), Color(red:0.08,green:0.12,blue:0.25), Color(red:0.12,green:0.18,blue:0.35)], startPoint: .top, endPoint: .bottom)
        }
        switch weather.condition {
        case "晴", "多云转晴":
            return LinearGradient(colors: [Color(red:0.25,green:0.55,blue:0.95), Color(red:0.45,green:0.75,blue:1.0), Color(red:0.78,green:0.90,blue:1.0)], startPoint: .top, endPoint: .bottom)
        case "多云", "阴天":
            return LinearGradient(colors: [Color(red:0.35,green:0.40,blue:0.45), Color(red:0.50,green:0.55,blue:0.60), Color(red:0.65,green:0.70,blue:0.75)], startPoint: .top, endPoint: .bottom)
        case "雨", "小雨", "雷暴":
            return LinearGradient(colors: [Color(red:0.20,green:0.30,blue:0.45), Color(red:0.30,green:0.40,blue:0.55), Color(red:0.45,green:0.55,blue:0.70)], startPoint: .top, endPoint: .bottom)
        case "雪":
            return LinearGradient(colors: [Color(red:0.75,green:0.85,blue:0.95), Color(red:0.85,green:0.90,blue:0.98), Color(red:0.92,green:0.95,blue:1.0)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [Color(red:0.30,green:0.50,blue:0.80), Color(red:0.50,green:0.70,blue:0.95), Color(red:0.70,green:0.85,blue:1.0)], startPoint: .top, endPoint: .bottom)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                metrics
                hourly
                daily
                sourceBar
                refreshFooter
            }.padding(.vertical, 12)
        }
        .background(bgGradient.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .refreshable { await vm.fetchWeather() }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: isNight ? "moon.stars.fill" : conditionIcon(weather.condition))
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(isNight ? .yellow.opacity(0.9) : .white)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            Text(fmtTemp(weather.temperature, tempUnit))
                .font(.system(size: 96, weight: .thin, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            Text(conditionDisplay(weather.condition, lang))
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
            Text(lang == .chinese ? "体感温度 \(fmtTemp(weather.feelsLike, tempUnit))" : "Feels like \(fmtTemp(weather.feelsLike, tempUnit))")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.7))
            Text(lang == .chinese ? "数据来自 \(weather.availableSourceCount)/\(weather.totalSourceCount) 个数据源" : "Data from \(weather.availableSourceCount)/\(weather.totalSourceCount) sources")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            MetricCard(icon:"humidity.fill", label: lang == .chinese ? "湿度" : "Humidity", value:"\(Int(weather.humidity))%", color:.blue, bg: cardBg)
            MetricCard(icon:"wind", label: lang == .chinese ? "风速" : "Wind", value:"\(String(format:"%.1f",weather.windSpeed)) km/h", color:.teal, bg: cardBg)
            MetricCard(icon:"gauge.with.dots.needle.33percent", label: lang == .chinese ? "气压" : "Pressure", value:"\(String(format:"%.0f",weather.pressure)) hPa", color:.orange, bg: cardBg)
            MetricCard(icon:"eye.fill", label: lang == .chinese ? "能见度" : "Visibility", value:"\(String(format:"%.1f",weather.visibility)) km", color:.indigo, bg: cardBg)
        }.padding(.horizontal, 16)
    }

    private var hourly: some View {
        let now = Date(); let cal = Calendar.current; let ch = cal.component(.hour, from: now)
        let reordered = Array(weather.hourlyForecast[ch...] + weather.hourlyForecast[..<ch])

        return VStack(alignment: .leading, spacing: 12) {
            Text(lang == .chinese ? "逐小时预报" : "Hourly Forecast")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
            if weather.hourlyForecast.isEmpty {
                Text(lang == .chinese ? "暂无数据" : "No data")
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(reordered.enumerated()), id: \.element.id) { idx, h in
                            let isNow = idx == 0
                            VStack(spacing: 6) {
                                Text(isNow ? (lang == .chinese ? "现在" : "Now") : fmtHour(h.time))
                                    .font(.system(size: 11, weight: isNow ? .bold : .medium))
                                    .foregroundStyle(isNow ? .white : .white.opacity(0.7))
                                Image(systemName: conditionIcon(h.condition))
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                                Text(fmtTemp(h.temperature, tempUnit))
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 10)
                            .background(isNow ? Color.white.opacity(0.25) : cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                        }
                    }.padding(.horizontal, 16)
                }
            }
        }
    }

    private var daily: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lang == .chinese ? "七日预报" : "7-Day Forecast")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
            VStack(spacing: 0) {
                ForEach(Array(weather.dailyForecast.enumerated()), id: \.element.id) { idx, day in
                    HStack(spacing: 12) {
                        Text(idx == 0 ? (lang == .chinese ? "今天" : "Today") : fmtDay(day.date, lang))
                            .font(.system(size: 15, weight: idx == 0 ? .semibold : .regular))
                            .foregroundStyle(.white)
                            .frame(width: 52, alignment: .leading)
                        Image(systemName: conditionIcon(day.condition))
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 26)
                        if day.precipitationProbability > 0 {
                            Text("\(Int(day.precipitationProbability))%")
                                .font(.system(size: 11)).foregroundColor(.blue.opacity(0.9))
                                .frame(width: 30)
                        } else { Spacer().frame(width: 30) }
                        Spacer()
                        Text(fmtTemp(day.lowTemperature, tempUnit))
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 36, alignment: .trailing)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(colors: [.blue,.green,.yellow,.orange], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 50, height: 4)
                        Text(fmtTemp(day.highTemperature, tempUnit))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 36, alignment: .trailing)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    if idx < weather.dailyForecast.count - 1 {
                        Divider().background(.white.opacity(0.15)).padding(.leading, 72)
                    }
                }
            }
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            .padding(.horizontal, 16)
        }
    }

    private var sourceBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(lang == .chinese ? "数据源贡献" : "Source Contributions")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                NavigationLink(lang == .chinese ? "详情" : "Details") {
                    SourceBreakdownView(weather: weather)
                }
                .font(.system(size: 14, weight: .medium))
            }.padding(.horizontal, 16)
            GeometryReader { geo in
                HStack(spacing: 2) {
                    ForEach(weather.sourceContributions.sorted(by: { $0.effectiveWeight > $1.effectiveWeight })) { c in
                        if c.isAvailable { RoundedRectangle(cornerRadius: 2).fill(c.source.color).frame(width: max(0, geo.size.width * c.effectiveWeight - 2)) }
                    }
                }
            }.frame(height: 6).clipShape(RoundedRectangle(cornerRadius: 3)).padding(.horizontal, 16)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                ForEach(weather.sourceContributions.sorted(by: { $0.effectiveWeight > $1.effectiveWeight })) { c in
                    HStack(spacing: 5) {
                        Circle().fill(c.source.color).frame(width: 7, height: 7)
                        Text(c.source.shortName).font(.system(size: 11)).foregroundColor(.white.opacity(0.7))
                        Text(String(format: "%.0f%%", c.contributionPercent)).font(.system(size: 11, weight: .medium)).foregroundColor(.white.opacity(0.9))
                    }.opacity(c.isAvailable ? 1 : 0.3)
                }
            }.padding(.horizontal, 16)
        }
    }

    private var refreshFooter: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock").font(.system(size: 10))
            Text(lang == .chinese ? "更新于 \(fmtTime(weather.fetchTimestamp))" : "Updated \(fmtTime(weather.fetchTimestamp))")
                .font(.system(size: 11))
        }
        .foregroundStyle(.white.opacity(0.45))
        .padding(.bottom, 20)
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let icon: String; let label: String; let value: String; let color: Color; let bg: Color
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .light))
                .foregroundStyle(color)
                .frame(height: 24)
            Text(value)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 5, y: 3)
    }
}
