import SwiftUI

struct SourceBreakdownView: View {
    let weather: UnifiedWeather
    @AppStorage("appLanguage") private var lang: AppLanguage = .chinese

    var body: some View {
        let L = lang
        ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 10) {
                    Text(L == .chinese ? "最终结果" : "Final Result")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(fmtTemp(weather.temperature))
                            .font(.system(size: 44, weight: .thin, design: .rounded))
                        Text(conditionDisplay(weather.condition, L))
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    }
                    Text(L == .chinese ? "由 \(weather.availableSourceCount) 个数据源加权融合" : "Blended from \(weather.availableSourceCount) sources")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)

                ForEach(weather.sourceContributions.sorted(by: { $0.effectiveWeight > $1.effectiveWeight })) { c in
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Image(systemName: c.source.systemImage)
                                .font(.system(size: 22))
                                .foregroundStyle(c.source.color)
                            Text(c.source.name)
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            if c.isAvailable {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(format: "%.0f%%", c.contributionPercent))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(c.source.color)
                                    Text(L == .chinese ? "贡献" : "Contrib.")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Label(L == .chinese ? "不可用" : "Unavailable", systemImage: "xmark.circle.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        if let d = c.data {
                            Divider().padding(.leading, 16)
                            VStack(spacing: 6) {
                                sr("thermometer.medium", L == .chinese ? "温度" : "Temp", fmtTemp(d.temperature))
                                sr("humidity.fill", L == .chinese ? "湿度" : "Humidity", "\(Int(d.humidity))%")
                                sr("wind", L == .chinese ? "风速" : "Wind", "\(String(format:"%.1f",d.windSpeed)) km/h")
                                sr("gauge.with.dots.needle.33percent", L == .chinese ? "气压" : "Pressure", "\(String(format:"%.0f",d.pressure)) hPa")
                                sr("eye.fill", L == .chinese ? "能见度" : "Visibility", "\(String(format:"%.1f",d.visibility)) km")
                                sr(conditionIcon(d.condition), L == .chinese ? "天气" : "Condition", conditionDisplay(d.condition, L))
                            }.padding(.horizontal, 16).padding(.vertical, 10)
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                    .opacity(c.isAvailable ? 1 : 0.45)
                }
            }.padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(L == .chinese ? "数据源详情" : "Source Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sr(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
    }
}
