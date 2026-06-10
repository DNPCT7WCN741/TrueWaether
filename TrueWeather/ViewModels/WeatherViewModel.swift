import SwiftUI
import Observation
import CoreLocation

// MARK: - Location Auth Status

enum LocationAuthStatus { case determining, authorized, denied }

// MARK: - ViewModel

@Observable
final class WeatherViewModel: NSObject, CLLocationManagerDelegate {
    var selectedLocation: Location?
    var unifiedWeather: UnifiedWeather?
    var isLoading = false
    var errorMessage: String?
    var searchQuery = ""
    var selectedCountry: String?
    var userLocationCity: Location?
    var locationStatus: LocationAuthStatus = .determining

    private var isChinese: Bool {
        UserDefaults.standard.string(forKey: "appLanguage") == "chinese"
    }

    private let services: [WeatherAPIService] = allWeatherServices()
    private let locationManager = CLLocationManager()
    private var locationAttempted = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    var allLocations: [Location] { PresetCity.all.map { $0.toLocation() } }

    var countriesForDisplay: [CountryGroup] {
        let grouped = Dictionary(grouping: allLocations) { $0.country }
        return grouped.map { (code, cities) in
            let rep = cities.first!
            return CountryGroup(code: code, flag: rep.countryFlag, nameZH: rep.countryZH, nameEN: rep.country, cities: cities)
        }.sorted { $0.nameZH < $1.nameZH }
    }

    func citiesForCountry(_ countryCode: String) -> [Location] {
        allLocations.filter { $0.country == countryCode }.sorted { $0.displayName(.chinese) < $1.displayName(.chinese) }
    }

    var filteredLocations: [Location] {
        guard !searchQuery.isEmpty else { return [] }
        let q = searchQuery.lowercased()
        return allLocations.filter { $0.searchableText.contains(q) }
    }

    func goToCitySelection() {
        selectedLocation = nil
        unifiedWeather = nil
        selectedCountry = nil
        searchQuery = ""
    }

    func requestLocation() {
        guard !locationAttempted else { return }
        locationAttempted = true
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationStatus = .authorized
            locationManager.requestLocation()
        } else if status == .denied || status == .restricted {
            locationStatus = .denied
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLoc = locations.first, selectedLocation == nil else { return }
        let nearest = allLocations.min(by: {
            let d1 = pow($0.latitude - userLoc.coordinate.latitude, 2) + pow($0.longitude - userLoc.coordinate.longitude, 2)
            let d2 = pow($1.latitude - userLoc.coordinate.latitude, 2) + pow($1.longitude - userLoc.coordinate.longitude, 2)
            return d1 < d2
        })
        guard let nearest else { return }
        userLocationCity = nearest
        selectedLocation = nearest
        Task { await fetchWeather() }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if selectedLocation == nil { locationStatus = .denied }
    }

    func selectCity(_ location: Location) {
        selectedLocation = location
        searchQuery = ""
        selectedCountry = nil
    }

    func fetchWeather() async {
        guard let loc = selectedLocation else { return }
        isLoading = true; errorMessage = nil; unifiedWeather = nil
        let rawWeights = WeightStrategy.weights(for: loc.region)
        let results = await fetchAllSources(for: loc)
        let unified = blendResults(location: loc, results: results, rawWeights: rawWeights)
        if unified.sourceContributions.allSatisfy({ !$0.isAvailable }) {
            errorMessage = isChinese ? "所有数据源均无法获取天气数据，请检查网络后重试" : "All data sources unavailable. Check your network and try again."
        } else { unifiedWeather = unified }
        isLoading = false
    }

    private func fetchAllSources(for loc: Location) async -> [(WeatherSource, RawWeatherData?)] {
        await withTaskGroup(of: (WeatherSource, RawWeatherData?).self) { group in
            for s in services { let src = s.source; group.addTask { do { return (src, try await s.fetchWeather(for: loc)) } catch { return (src, nil) } } }
            var r: [(WeatherSource, RawWeatherData?)] = []
            for await v in group { r.append(v) }
            return r
        }
    }

    private func blendResults(location: Location, results: [(WeatherSource, RawWeatherData?)], rawWeights: [WeatherSource:Double]) -> UnifiedWeather {
        let avail = Set(results.compactMap { $0.1 != nil ? $0.0 : nil })
        let eff = WeightStrategy.normalizedWeights(for: location.region, availableSources: avail)
        let valid = results.compactMap { r -> (WeatherSource, Double, RawWeatherData)? in
            guard let d = r.1, let w = eff[r.0] else { return nil }; return (r.0, w, d)
        }
        let contributions = results.map { r in SourceContribution(source: r.0, weight: rawWeights[r.0] ?? 0, effectiveWeight: eff[r.0] ?? 0, data: r.1, isAvailable: r.1 != nil) }
        guard !valid.isEmpty else {
            return UnifiedWeather(temperature:0,feelsLike:0,humidity:0,windSpeed:0,windDirection:0,pressure:0,visibility:0,precipitationProbability:0,condition:"晴",uvIndex:0,hourlyForecast:[],dailyForecast:[],sourceContributions:contributions,effectiveWeights:[:],fetchTimestamp:Date())
        }
        func wa(_ vals: [(Double,Double)]) -> Double { let t = vals.reduce(0){$0+$1.0}; return t>0 ? vals.reduce(0){$0+$1.0*$1.1}/t : 0 }
        let temp = wa(valid.map{($0.1,$0.2.temperature)}); let fl = wa(valid.map{($0.1,$0.2.feelsLike)})
        let hum = wa(valid.map{($0.1,$0.2.humidity)}); let ws = wa(valid.map{($0.1,$0.2.windSpeed)})
        let wd = wa(valid.map{($0.1,$0.2.windDirection)}); let pres = wa(valid.map{($0.1,$0.2.pressure)})
        let vis = wa(valid.map{($0.1,$0.2.visibility)}); let uv = Int(wa(valid.map{($0.1,Double($0.2.uvIndex))}).rounded())
        var cv: [String:Double] = [:]; for(_,w,d) in valid { cv[d.condition,default:0]+=w }
        let cond = cv.max(by:{$0.value<$1.value})?.key ?? "晴"
        let prim = valid.max(by:{$0.1<$1.1})
        let hc = prim.map{$0.2.hourlyForecast.count} ?? 0
        let hourly: [HourlyData] = (0..<hc).map { i in
            let vs = valid.compactMap { (s,w,d)->(Double,Double,Double,Double,String)? in
                guard i<d.hourlyForecast.count else{return nil}
                let h=d.hourlyForecast[i]; return (w,h.temperature,h.humidity,h.windSpeed,h.condition)
            }
            var vc:[String:Double]=[:]; for(w,_,_,_,c) in vs {vc[c,default:0]+=w}
            return HourlyData(time:prim!.2.hourlyForecast[i].time,temperature:wa(vs.map{($0.0,$0.1)}),condition:vc.max(by:{$0.value<$1.value})?.key ?? "晴",humidity:wa(vs.map{($0.0,$0.2)}),windSpeed:wa(vs.map{($0.0,$0.3)}))
        }
        let dc = prim.map{$0.2.dailyForecast.count} ?? 0
        let daily: [DailyData] = (0..<dc).map { i in
            let vs = valid.compactMap { (s,w,d)->(Double,Double,Double,Double,Double,String)? in
                guard i<d.dailyForecast.count else{return nil}
                let dd=d.dailyForecast[i]; return (w,dd.highTemperature,dd.lowTemperature,dd.humidity,dd.windSpeed,dd.condition)
            }
            let pvs = valid.compactMap { (s,w,d)->(Double,Double)? in guard i<d.dailyForecast.count else{return nil}; return (w,d.dailyForecast[i].precipitationProbability) }
            var vc:[String:Double]=[:]; for(w,_,_,_,_,c) in vs {vc[c,default:0]+=w}
            return DailyData(date:prim!.2.dailyForecast[i].date,highTemperature:wa(vs.map{($0.0,$0.1)}),lowTemperature:wa(vs.map{($0.0,$0.2)}),condition:vc.max(by:{$0.value<$1.value})?.key ?? "晴",humidity:wa(vs.map{($0.0,$0.3)}),windSpeed:wa(vs.map{($0.0,$0.4)}),precipitationProbability:wa(pvs.map{($0.0,$0.1)}))
        }
        let prec = wa(valid.compactMap { (s,w,d) in guard !d.dailyForecast.isEmpty else {return nil}; return (w, d.dailyForecast[0].precipitationProbability) })
        return UnifiedWeather(temperature:temp,feelsLike:fl,humidity:hum,windSpeed:ws,windDirection:wd,pressure:pres,visibility:vis,precipitationProbability:prec,condition:cond,uvIndex:uv,hourlyForecast:hourly,dailyForecast:daily,sourceContributions:contributions,effectiveWeights:eff,fetchTimestamp:Date())
    }
}
