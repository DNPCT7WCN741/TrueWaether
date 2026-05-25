import Foundation

// MARK: - Region

enum Region: String, CaseIterable {
    case mainlandChina, japanKorea, southeastAsia, southAsia
    case northAmerica, europe, oceania, southAmerica, africa, middleEast, global

    func name(_ lang: AppLanguage) -> String {
        switch self {
        case .mainlandChina: lang == .chinese ? "中国大陆" : "Mainland China"
        case .japanKorea: lang == .chinese ? "日本/韩国" : "Japan / Korea"
        case .southeastAsia: lang == .chinese ? "东南亚" : "Southeast Asia"
        case .southAsia: lang == .chinese ? "南亚" : "South Asia"
        case .northAmerica: lang == .chinese ? "北美" : "North America"
        case .europe: lang == .chinese ? "欧洲" : "Europe"
        case .oceania: lang == .chinese ? "大洋洲" : "Oceania"
        case .southAmerica: lang == .chinese ? "南美" : "South America"
        case .africa: lang == .chinese ? "非洲" : "Africa"
        case .middleEast: lang == .chinese ? "中东" : "Middle East"
        case .global: lang == .chinese ? "全球" : "Global"
        }
    }
}

// MARK: - Location

struct Location: Identifiable, Hashable {
    let id = UUID()
    let nameZH: String
    let nameEN: String
    let country: String
    let countryZH: String
    let adminAreaZH: String
    let adminAreaEN: String
    let latitude, longitude: Double
    var region: Region

    func displayName(_ lang: AppLanguage) -> String { lang == .chinese ? nameZH : nameEN }
    func displayAdminArea(_ lang: AppLanguage) -> String { lang == .chinese ? adminAreaZH : adminAreaEN }
    func displayCountry(_ lang: AppLanguage) -> String { lang == .chinese ? countryZH : country }

    var countryFlag: String {
        let base: UInt32 = 127397
        return country.uppercased().unicodeScalars.compactMap { UnicodeScalar(base + $0.value).map(String.init) }.joined()
    }

    func subtitle(_ lang: AppLanguage) -> String {
        "\(displayAdminArea(lang)) \(countryFlag)"
    }

    var searchableText: String {
        "\(nameZH) \(nameEN) \(adminAreaZH) \(adminAreaEN) \(countryZH) \(country)".lowercased()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nameZH); hasher.combine(country); hasher.combine(latitude); hasher.combine(longitude)
    }
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.nameZH == rhs.nameZH && lhs.country == rhs.country && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension Region {
    static func determine(countryCode: String, adminArea: String) -> Region {
        switch countryCode.uppercased() {
        case "CN", "MO", "HK": return .mainlandChina
        case "JP", "KR", "KP": return .japanKorea
        case "VN", "TH", "MY", "SG", "ID", "PH", "MM", "KH", "LA", "BN", "TL": return .southeastAsia
        case "IN", "PK", "BD", "LK", "NP", "BT", "MV": return .southAsia
        case "US", "CA", "MX": return .northAmerica
        case "GB", "DE", "FR", "IT", "ES", "PT", "NL", "BE", "CH",
             "AT", "SE", "NO", "DK", "FI", "IE", "PL", "CZ", "SK",
             "HU", "RO", "BG", "GR", "HR", "SI", "LT", "LV", "EE",
             "IS", "LU", "MT", "CY", "AL", "RS", "UA", "BY", "MD": return .europe
        case "AU", "NZ", "FJ", "PG", "SB", "VU", "WS": return .oceania
        case "BR", "AR", "CL", "CO", "PE", "VE", "EC", "BO", "PY", "UY", "GY", "SR": return .southAmerica
        case "ZA", "NG", "KE", "EG", "MA", "ET", "TZ", "GH", "UG",
             "DZ", "SD", "AO", "MZ", "CM", "CI", "SN", "TN", "ZW", "RW", "BW", "NA": return .africa
        case "SA", "AE", "QA", "KW", "OM", "BH", "IQ", "IR", "SY", "JO", "LB", "IL", "YE": return .middleEast
        default: return .global
        }
    }
}

// MARK: - Preset City

struct PresetCity {
    let nameZH: String; let nameEN: String
    let adminAreaZH: String; let adminAreaEN: String
    let country: String; let countryZH: String
    let latitude: Double; let longitude: Double

    func toLocation() -> Location {
        Location(nameZH: nameZH, nameEN: nameEN, country: country, countryZH: countryZH,
                 adminAreaZH: adminAreaZH, adminAreaEN: adminAreaEN,
                 latitude: latitude, longitude: longitude,
                 region: Region.determine(countryCode: country, adminArea: adminAreaZH))
    }

    static let all: [PresetCity] = [
        // 中国大陆
        PresetCity(nameZH:"北京",nameEN:"Beijing",adminAreaZH:"北京",adminAreaEN:"Beijing",country:"CN",countryZH:"中国",latitude:39.9042,longitude:116.4074),
        PresetCity(nameZH:"上海",nameEN:"Shanghai",adminAreaZH:"上海",adminAreaEN:"Shanghai",country:"CN",countryZH:"中国",latitude:31.2304,longitude:121.4737),
        PresetCity(nameZH:"广州",nameEN:"Guangzhou",adminAreaZH:"广东",adminAreaEN:"Guangdong",country:"CN",countryZH:"中国",latitude:23.1291,longitude:113.2644),
        PresetCity(nameZH:"深圳",nameEN:"Shenzhen",adminAreaZH:"广东",adminAreaEN:"Guangdong",country:"CN",countryZH:"中国",latitude:22.5431,longitude:114.0579),
        PresetCity(nameZH:"成都",nameEN:"Chengdu",adminAreaZH:"四川",adminAreaEN:"Sichuan",country:"CN",countryZH:"中国",latitude:30.5728,longitude:104.0668),
        PresetCity(nameZH:"杭州",nameEN:"Hangzhou",adminAreaZH:"浙江",adminAreaEN:"Zhejiang",country:"CN",countryZH:"中国",latitude:30.2741,longitude:120.1551),
        PresetCity(nameZH:"武汉",nameEN:"Wuhan",adminAreaZH:"湖北",adminAreaEN:"Hubei",country:"CN",countryZH:"中国",latitude:30.5928,longitude:114.3055),
        PresetCity(nameZH:"西安",nameEN:"Xi'an",adminAreaZH:"陕西",adminAreaEN:"Shaanxi",country:"CN",countryZH:"中国",latitude:34.3416,longitude:108.9398),
        PresetCity(nameZH:"重庆",nameEN:"Chongqing",adminAreaZH:"重庆",adminAreaEN:"Chongqing",country:"CN",countryZH:"中国",latitude:29.5630,longitude:106.5516),
        PresetCity(nameZH:"南京",nameEN:"Nanjing",adminAreaZH:"江苏",adminAreaEN:"Jiangsu",country:"CN",countryZH:"中国",latitude:32.0603,longitude:118.7969),
        PresetCity(nameZH:"苏州",nameEN:"Suzhou",adminAreaZH:"江苏",adminAreaEN:"Jiangsu",country:"CN",countryZH:"中国",latitude:31.2990,longitude:120.5853),
        PresetCity(nameZH:"天津",nameEN:"Tianjin",adminAreaZH:"天津",adminAreaEN:"Tianjin",country:"CN",countryZH:"中国",latitude:39.3434,longitude:117.3616),
        PresetCity(nameZH:"长沙",nameEN:"Changsha",adminAreaZH:"湖南",adminAreaEN:"Hunan",country:"CN",countryZH:"中国",latitude:28.2282,longitude:112.9388),
        PresetCity(nameZH:"青岛",nameEN:"Qingdao",adminAreaZH:"山东",adminAreaEN:"Shandong",country:"CN",countryZH:"中国",latitude:36.0671,longitude:120.3826),
        PresetCity(nameZH:"大连",nameEN:"Dalian",adminAreaZH:"辽宁",adminAreaEN:"Liaoning",country:"CN",countryZH:"中国",latitude:38.9140,longitude:121.6147),
        PresetCity(nameZH:"厦门",nameEN:"Xiamen",adminAreaZH:"福建",adminAreaEN:"Fujian",country:"CN",countryZH:"中国",latitude:24.4798,longitude:118.0894),
        PresetCity(nameZH:"昆明",nameEN:"Kunming",adminAreaZH:"云南",adminAreaEN:"Yunnan",country:"CN",countryZH:"中国",latitude:25.0389,longitude:102.7183),
        PresetCity(nameZH:"沈阳",nameEN:"Shenyang",adminAreaZH:"辽宁",adminAreaEN:"Liaoning",country:"CN",countryZH:"中国",latitude:41.8057,longitude:123.4315),
        PresetCity(nameZH:"哈尔滨",nameEN:"Harbin",adminAreaZH:"黑龙江",adminAreaEN:"Heilongjiang",country:"CN",countryZH:"中国",latitude:45.8038,longitude:126.5350),
        PresetCity(nameZH:"郑州",nameEN:"Zhengzhou",adminAreaZH:"河南",adminAreaEN:"Henan",country:"CN",countryZH:"中国",latitude:34.7466,longitude:113.6254),
        PresetCity(nameZH:"济南",nameEN:"Jinan",adminAreaZH:"山东",adminAreaEN:"Shandong",country:"CN",countryZH:"中国",latitude:36.6512,longitude:117.1201),
        PresetCity(nameZH:"合肥",nameEN:"Hefei",adminAreaZH:"安徽",adminAreaEN:"Anhui",country:"CN",countryZH:"中国",latitude:31.8206,longitude:117.2272),
        PresetCity(nameZH:"福州",nameEN:"Fuzhou",adminAreaZH:"福建",adminAreaEN:"Fujian",country:"CN",countryZH:"中国",latitude:26.0745,longitude:119.2965),
        PresetCity(nameZH:"乌鲁木齐",nameEN:"Urumqi",adminAreaZH:"新疆",adminAreaEN:"Xinjiang",country:"CN",countryZH:"中国",latitude:43.8256,longitude:87.6168),
        PresetCity(nameZH:"拉萨",nameEN:"Lhasa",adminAreaZH:"西藏",adminAreaEN:"Tibet",country:"CN",countryZH:"中国",latitude:29.6500,longitude:91.1000),
        PresetCity(nameZH:"南宁",nameEN:"Nanning",adminAreaZH:"广西",adminAreaEN:"Guangxi",country:"CN",countryZH:"中国",latitude:22.8170,longitude:108.3665),
        PresetCity(nameZH:"贵阳",nameEN:"Guiyang",adminAreaZH:"贵州",adminAreaEN:"Guizhou",country:"CN",countryZH:"中国",latitude:26.6470,longitude:106.6302),
        PresetCity(nameZH:"兰州",nameEN:"Lanzhou",adminAreaZH:"甘肃",adminAreaEN:"Gansu",country:"CN",countryZH:"中国",latitude:36.0611,longitude:103.8343),
        PresetCity(nameZH:"南昌",nameEN:"Nanchang",adminAreaZH:"江西",adminAreaEN:"Jiangxi",country:"CN",countryZH:"中国",latitude:28.6820,longitude:115.8579),
        PresetCity(nameZH:"太原",nameEN:"Taiyuan",adminAreaZH:"山西",adminAreaEN:"Shanxi",country:"CN",countryZH:"中国",latitude:37.8706,longitude:112.5489),
        PresetCity(nameZH:"长春",nameEN:"Changchun",adminAreaZH:"吉林",adminAreaEN:"Jilin",country:"CN",countryZH:"中国",latitude:43.8178,longitude:125.3235),
        PresetCity(nameZH:"呼和浩特",nameEN:"Hohhot",adminAreaZH:"内蒙古",adminAreaEN:"Inner Mongolia",country:"CN",countryZH:"中国",latitude:40.8424,longitude:111.7490),
        PresetCity(nameZH:"台北",nameEN:"Taipei",adminAreaZH:"台湾",adminAreaEN:"Taiwan",country:"CN",countryZH:"中国",latitude:25.0330,longitude:121.5654),
        PresetCity(nameZH:"香港",nameEN:"Hong Kong",adminAreaZH:"香港",adminAreaEN:"Hong Kong",country:"CN",countryZH:"中国",latitude:22.3193,longitude:114.1694),
        PresetCity(nameZH:"澳门",nameEN:"Macau",adminAreaZH:"澳门",adminAreaEN:"Macau",country:"CN",countryZH:"中国",latitude:22.1987,longitude:113.5439),
        // 日本
        PresetCity(nameZH:"东京",nameEN:"Tokyo",adminAreaZH:"东京都",adminAreaEN:"Tokyo",country:"JP",countryZH:"日本",latitude:35.6762,longitude:139.6503),
        PresetCity(nameZH:"大阪",nameEN:"Osaka",adminAreaZH:"大阪府",adminAreaEN:"Osaka",country:"JP",countryZH:"日本",latitude:34.6937,longitude:135.5023),
        PresetCity(nameZH:"京都",nameEN:"Kyoto",adminAreaZH:"京都府",adminAreaEN:"Kyoto",country:"JP",countryZH:"日本",latitude:35.0116,longitude:135.7681),
        PresetCity(nameZH:"札幌",nameEN:"Sapporo",adminAreaZH:"北海道",adminAreaEN:"Hokkaido",country:"JP",countryZH:"日本",latitude:43.0618,longitude:141.3545),
        PresetCity(nameZH:"福冈",nameEN:"Fukuoka",adminAreaZH:"福冈县",adminAreaEN:"Fukuoka",country:"JP",countryZH:"日本",latitude:33.5904,longitude:130.4017),
        // 韩国
        PresetCity(nameZH:"首尔",nameEN:"Seoul",adminAreaZH:"首尔",adminAreaEN:"Seoul",country:"KR",countryZH:"韩国",latitude:37.5665,longitude:126.9780),
        PresetCity(nameZH:"釜山",nameEN:"Busan",adminAreaZH:"釜山",adminAreaEN:"Busan",country:"KR",countryZH:"韩国",latitude:35.1796,longitude:129.0756),
        // 东南亚
        PresetCity(nameZH:"新加坡",nameEN:"Singapore",adminAreaZH:"新加坡",adminAreaEN:"Singapore",country:"SG",countryZH:"新加坡",latitude:1.3521,longitude:103.8198),
        PresetCity(nameZH:"曼谷",nameEN:"Bangkok",adminAreaZH:"曼谷",adminAreaEN:"Bangkok",country:"TH",countryZH:"泰国",latitude:13.7563,longitude:100.5018),
        PresetCity(nameZH:"吉隆坡",nameEN:"Kuala Lumpur",adminAreaZH:"吉隆坡",adminAreaEN:"Kuala Lumpur",country:"MY",countryZH:"马来西亚",latitude:3.1390,longitude:101.6869),
        PresetCity(nameZH:"雅加达",nameEN:"Jakarta",adminAreaZH:"雅加达",adminAreaEN:"Jakarta",country:"ID",countryZH:"印尼",latitude:-6.2088,longitude:106.8456),
        PresetCity(nameZH:"马尼拉",nameEN:"Manila",adminAreaZH:"马尼拉",adminAreaEN:"Manila",country:"PH",countryZH:"菲律宾",latitude:14.5995,longitude:120.9842),
        PresetCity(nameZH:"河内",nameEN:"Hanoi",adminAreaZH:"河内",adminAreaEN:"Hanoi",country:"VN",countryZH:"越南",latitude:21.0278,longitude:105.8342),
        PresetCity(nameZH:"胡志明市",nameEN:"Ho Chi Minh City",adminAreaZH:"胡志明市",adminAreaEN:"Ho Chi Minh City",country:"VN",countryZH:"越南",latitude:10.8231,longitude:106.6297),
        PresetCity(nameZH:"仰光",nameEN:"Yangon",adminAreaZH:"仰光",adminAreaEN:"Yangon",country:"MM",countryZH:"缅甸",latitude:16.8409,longitude:96.1735),
        PresetCity(nameZH:"金边",nameEN:"Phnom Penh",adminAreaZH:"金边",adminAreaEN:"Phnom Penh",country:"KH",countryZH:"柬埔寨",latitude:11.5564,longitude:104.9282),
        // 南亚
        PresetCity(nameZH:"孟买",nameEN:"Mumbai",adminAreaZH:"马哈拉施特拉邦",adminAreaEN:"Maharashtra",country:"IN",countryZH:"印度",latitude:19.0760,longitude:72.8777),
        PresetCity(nameZH:"新德里",nameEN:"New Delhi",adminAreaZH:"德里",adminAreaEN:"Delhi",country:"IN",countryZH:"印度",latitude:28.6139,longitude:77.2090),
        PresetCity(nameZH:"班加罗尔",nameEN:"Bangalore",adminAreaZH:"卡纳塔克邦",adminAreaEN:"Karnataka",country:"IN",countryZH:"印度",latitude:12.9716,longitude:77.5946),
        PresetCity(nameZH:"加尔各答",nameEN:"Kolkata",adminAreaZH:"西孟加拉邦",adminAreaEN:"West Bengal",country:"IN",countryZH:"印度",latitude:22.5726,longitude:88.3639),
        PresetCity(nameZH:"金奈",nameEN:"Chennai",adminAreaZH:"泰米尔纳德邦",adminAreaEN:"Tamil Nadu",country:"IN",countryZH:"印度",latitude:13.0827,longitude:80.2707),
        PresetCity(nameZH:"伊斯兰堡",nameEN:"Islamabad",adminAreaZH:"伊斯兰堡",adminAreaEN:"Islamabad",country:"PK",countryZH:"巴基斯坦",latitude:33.6844,longitude:73.0479),
        PresetCity(nameZH:"科伦坡",nameEN:"Colombo",adminAreaZH:"科伦坡",adminAreaEN:"Colombo",country:"LK",countryZH:"斯里兰卡",latitude:6.9271,longitude:79.8612),
        PresetCity(nameZH:"达卡",nameEN:"Dhaka",adminAreaZH:"达卡",adminAreaEN:"Dhaka",country:"BD",countryZH:"孟加拉国",latitude:23.8103,longitude:90.4125),
        PresetCity(nameZH:"加德满都",nameEN:"Kathmandu",adminAreaZH:"加德满都",adminAreaEN:"Kathmandu",country:"NP",countryZH:"尼泊尔",latitude:27.7172,longitude:85.3240),
        // 北美
        PresetCity(nameZH:"纽约",nameEN:"New York",adminAreaZH:"纽约州",adminAreaEN:"New York",country:"US",countryZH:"美国",latitude:40.7128,longitude:-74.0060),
        PresetCity(nameZH:"洛杉矶",nameEN:"Los Angeles",adminAreaZH:"加利福尼亚州",adminAreaEN:"California",country:"US",countryZH:"美国",latitude:34.0522,longitude:-118.2437),
        PresetCity(nameZH:"芝加哥",nameEN:"Chicago",adminAreaZH:"伊利诺伊州",adminAreaEN:"Illinois",country:"US",countryZH:"美国",latitude:41.8781,longitude:-87.6298),
        PresetCity(nameZH:"旧金山",nameEN:"San Francisco",adminAreaZH:"加利福尼亚州",adminAreaEN:"California",country:"US",countryZH:"美国",latitude:37.7749,longitude:-122.4194),
        PresetCity(nameZH:"西雅图",nameEN:"Seattle",adminAreaZH:"华盛顿州",adminAreaEN:"Washington",country:"US",countryZH:"美国",latitude:47.6062,longitude:-122.3321),
        PresetCity(nameZH:"迈阿密",nameEN:"Miami",adminAreaZH:"佛罗里达州",adminAreaEN:"Florida",country:"US",countryZH:"美国",latitude:25.7617,longitude:-80.1918),
        PresetCity(nameZH:"休斯顿",nameEN:"Houston",adminAreaZH:"得克萨斯州",adminAreaEN:"Texas",country:"US",countryZH:"美国",latitude:29.7604,longitude:-95.3698),
        PresetCity(nameZH:"波士顿",nameEN:"Boston",adminAreaZH:"马萨诸塞州",adminAreaEN:"Massachusetts",country:"US",countryZH:"美国",latitude:42.3601,longitude:-71.0589),
        PresetCity(nameZH:"华盛顿",nameEN:"Washington DC",adminAreaZH:"华盛顿特区",adminAreaEN:"District of Columbia",country:"US",countryZH:"美国",latitude:38.9072,longitude:-77.0369),
        PresetCity(nameZH:"亚特兰大",nameEN:"Atlanta",adminAreaZH:"佐治亚州",adminAreaEN:"Georgia",country:"US",countryZH:"美国",latitude:33.7490,longitude:-84.3880),
        PresetCity(nameZH:"丹佛",nameEN:"Denver",adminAreaZH:"科罗拉多州",adminAreaEN:"Colorado",country:"US",countryZH:"美国",latitude:39.7392,longitude:-104.9903),
        PresetCity(nameZH:"拉斯维加斯",nameEN:"Las Vegas",adminAreaZH:"内华达州",adminAreaEN:"Nevada",country:"US",countryZH:"美国",latitude:36.1716,longitude:-115.1391),
        PresetCity(nameZH:"多伦多",nameEN:"Toronto",adminAreaZH:"安大略省",adminAreaEN:"Ontario",country:"CA",countryZH:"加拿大",latitude:43.6532,longitude:-79.3832),
        PresetCity(nameZH:"温哥华",nameEN:"Vancouver",adminAreaZH:"不列颠哥伦比亚省",adminAreaEN:"British Columbia",country:"CA",countryZH:"加拿大",latitude:49.2827,longitude:-123.1207),
        PresetCity(nameZH:"蒙特利尔",nameEN:"Montreal",adminAreaZH:"魁北克省",adminAreaEN:"Quebec",country:"CA",countryZH:"加拿大",latitude:45.5017,longitude:-73.5673),
        PresetCity(nameZH:"墨西哥城",nameEN:"Mexico City",adminAreaZH:"墨西哥城",adminAreaEN:"Mexico City",country:"MX",countryZH:"墨西哥",latitude:19.4326,longitude:-99.1332),
        // 欧洲
        PresetCity(nameZH:"伦敦",nameEN:"London",adminAreaZH:"英格兰",adminAreaEN:"England",country:"GB",countryZH:"英国",latitude:51.5074,longitude:-0.1278),
        PresetCity(nameZH:"巴黎",nameEN:"Paris",adminAreaZH:"法兰西岛",adminAreaEN:"Île-de-France",country:"FR",countryZH:"法国",latitude:48.8566,longitude:2.3522),
        PresetCity(nameZH:"柏林",nameEN:"Berlin",adminAreaZH:"柏林",adminAreaEN:"Berlin",country:"DE",countryZH:"德国",latitude:52.5200,longitude:13.4050),
        PresetCity(nameZH:"罗马",nameEN:"Rome",adminAreaZH:"拉齐奥",adminAreaEN:"Lazio",country:"IT",countryZH:"意大利",latitude:41.9028,longitude:12.4964),
        PresetCity(nameZH:"马德里",nameEN:"Madrid",adminAreaZH:"马德里",adminAreaEN:"Madrid",country:"ES",countryZH:"西班牙",latitude:40.4168,longitude:-3.7038),
        PresetCity(nameZH:"阿姆斯特丹",nameEN:"Amsterdam",adminAreaZH:"北荷兰省",adminAreaEN:"North Holland",country:"NL",countryZH:"荷兰",latitude:52.3676,longitude:4.9041),
        PresetCity(nameZH:"莫斯科",nameEN:"Moscow",adminAreaZH:"莫斯科",adminAreaEN:"Moscow",country:"RU",countryZH:"俄罗斯",latitude:55.7558,longitude:37.6173),
        PresetCity(nameZH:"伊斯坦布尔",nameEN:"Istanbul",adminAreaZH:"伊斯坦布尔",adminAreaEN:"Istanbul",country:"TR",countryZH:"土耳其",latitude:41.0082,longitude:28.9784),
        PresetCity(nameZH:"斯德哥尔摩",nameEN:"Stockholm",adminAreaZH:"斯德哥尔摩",adminAreaEN:"Stockholm",country:"SE",countryZH:"瑞典",latitude:59.3293,longitude:18.0686),
        PresetCity(nameZH:"巴塞罗那",nameEN:"Barcelona",adminAreaZH:"加泰罗尼亚",adminAreaEN:"Catalonia",country:"ES",countryZH:"西班牙",latitude:41.3874,longitude:2.1686),
        PresetCity(nameZH:"慕尼黑",nameEN:"Munich",adminAreaZH:"巴伐利亚",adminAreaEN:"Bavaria",country:"DE",countryZH:"德国",latitude:48.1351,longitude:11.5820),
        PresetCity(nameZH:"米兰",nameEN:"Milan",adminAreaZH:"伦巴第",adminAreaEN:"Lombardy",country:"IT",countryZH:"意大利",latitude:45.4642,longitude:9.1900),
        PresetCity(nameZH:"维也纳",nameEN:"Vienna",adminAreaZH:"维也纳",adminAreaEN:"Vienna",country:"AT",countryZH:"奥地利",latitude:48.2082,longitude:16.3738),
        PresetCity(nameZH:"布拉格",nameEN:"Prague",adminAreaZH:"布拉格",adminAreaEN:"Prague",country:"CZ",countryZH:"捷克",latitude:50.0755,longitude:14.4378),
        PresetCity(nameZH:"华沙",nameEN:"Warsaw",adminAreaZH:"华沙",adminAreaEN:"Warsaw",country:"PL",countryZH:"波兰",latitude:52.2297,longitude:21.0122),
        PresetCity(nameZH:"布鲁塞尔",nameEN:"Brussels",adminAreaZH:"布鲁塞尔",adminAreaEN:"Brussels",country:"BE",countryZH:"比利时",latitude:50.8503,longitude:4.3517),
        PresetCity(nameZH:"里斯本",nameEN:"Lisbon",adminAreaZH:"里斯本",adminAreaEN:"Lisbon",country:"PT",countryZH:"葡萄牙",latitude:38.7223,longitude:-9.1393),
        PresetCity(nameZH:"都柏林",nameEN:"Dublin",adminAreaZH:"都柏林",adminAreaEN:"Dublin",country:"IE",countryZH:"爱尔兰",latitude:53.3498,longitude:-6.2603),
        PresetCity(nameZH:"哥本哈根",nameEN:"Copenhagen",adminAreaZH:"哥本哈根",adminAreaEN:"Copenhagen",country:"DK",countryZH:"丹麦",latitude:55.6761,longitude:12.5683),
        PresetCity(nameZH:"奥斯陆",nameEN:"Oslo",adminAreaZH:"奥斯陆",adminAreaEN:"Oslo",country:"NO",countryZH:"挪威",latitude:59.9139,longitude:10.7522),
        PresetCity(nameZH:"赫尔辛基",nameEN:"Helsinki",adminAreaZH:"赫尔辛基",adminAreaEN:"Helsinki",country:"FI",countryZH:"芬兰",latitude:60.1699,longitude:24.9384),
        PresetCity(nameZH:"布达佩斯",nameEN:"Budapest",adminAreaZH:"布达佩斯",adminAreaEN:"Budapest",country:"HU",countryZH:"匈牙利",latitude:47.4979,longitude:19.0402),
        PresetCity(nameZH:"雅典",nameEN:"Athens",adminAreaZH:"雅典",adminAreaEN:"Athens",country:"GR",countryZH:"希腊",latitude:37.9838,longitude:23.7275),
        PresetCity(nameZH:"苏黎世",nameEN:"Zurich",adminAreaZH:"苏黎世",adminAreaEN:"Zurich",country:"CH",countryZH:"瑞士",latitude:47.3769,longitude:8.5417),
        PresetCity(nameZH:"爱丁堡",nameEN:"Edinburgh",adminAreaZH:"苏格兰",adminAreaEN:"Scotland",country:"GB",countryZH:"英国",latitude:55.9533,longitude:-3.1883),
        // 大洋洲
        PresetCity(nameZH:"悉尼",nameEN:"Sydney",adminAreaZH:"新南威尔士州",adminAreaEN:"New South Wales",country:"AU",countryZH:"澳大利亚",latitude:-33.8688,longitude:151.2093),
        PresetCity(nameZH:"墨尔本",nameEN:"Melbourne",adminAreaZH:"维多利亚州",adminAreaEN:"Victoria",country:"AU",countryZH:"澳大利亚",latitude:-37.8136,longitude:144.9631),
        PresetCity(nameZH:"布里斯班",nameEN:"Brisbane",adminAreaZH:"昆士兰州",adminAreaEN:"Queensland",country:"AU",countryZH:"澳大利亚",latitude:-27.4698,longitude:153.0251),
        PresetCity(nameZH:"珀斯",nameEN:"Perth",adminAreaZH:"西澳大利亚州",adminAreaEN:"Western Australia",country:"AU",countryZH:"澳大利亚",latitude:-31.9505,longitude:115.8605),
        PresetCity(nameZH:"奥克兰",nameEN:"Auckland",adminAreaZH:"奥克兰",adminAreaEN:"Auckland",country:"NZ",countryZH:"新西兰",latitude:-36.8509,longitude:174.7645),
        PresetCity(nameZH:"惠灵顿",nameEN:"Wellington",adminAreaZH:"惠灵顿",adminAreaEN:"Wellington",country:"NZ",countryZH:"新西兰",latitude:-41.2865,longitude:174.7762),
        // 南美
        PresetCity(nameZH:"圣保罗",nameEN:"São Paulo",adminAreaZH:"圣保罗州",adminAreaEN:"São Paulo",country:"BR",countryZH:"巴西",latitude:-23.5505,longitude:-46.6333),
        PresetCity(nameZH:"里约热内卢",nameEN:"Rio de Janeiro",adminAreaZH:"里约热内卢州",adminAreaEN:"Rio de Janeiro",country:"BR",countryZH:"巴西",latitude:-22.9068,longitude:-43.1729),
        PresetCity(nameZH:"布宜诺斯艾利斯",nameEN:"Buenos Aires",adminAreaZH:"布宜诺斯艾利斯",adminAreaEN:"Buenos Aires",country:"AR",countryZH:"阿根廷",latitude:-34.6037,longitude:-58.3816),
        PresetCity(nameZH:"圣地亚哥",nameEN:"Santiago",adminAreaZH:"圣地亚哥",adminAreaEN:"Santiago",country:"CL",countryZH:"智利",latitude:-33.4489,longitude:-70.6693),
        PresetCity(nameZH:"利马",nameEN:"Lima",adminAreaZH:"利马",adminAreaEN:"Lima",country:"PE",countryZH:"秘鲁",latitude:-12.0464,longitude:-77.0428),
        PresetCity(nameZH:"波哥大",nameEN:"Bogotá",adminAreaZH:"波哥大",adminAreaEN:"Bogotá",country:"CO",countryZH:"哥伦比亚",latitude:4.7110,longitude:-74.0721),
        // 非洲
        PresetCity(nameZH:"开普敦",nameEN:"Cape Town",adminAreaZH:"西开普省",adminAreaEN:"Western Cape",country:"ZA",countryZH:"南非",latitude:-33.9249,longitude:18.4241),
        PresetCity(nameZH:"约翰内斯堡",nameEN:"Johannesburg",adminAreaZH:"豪登省",adminAreaEN:"Gauteng",country:"ZA",countryZH:"南非",latitude:-26.2041,longitude:28.0473),
        PresetCity(nameZH:"内罗毕",nameEN:"Nairobi",adminAreaZH:"内罗毕",adminAreaEN:"Nairobi",country:"KE",countryZH:"肯尼亚",latitude:-1.2921,longitude:36.8219),
        PresetCity(nameZH:"开罗",nameEN:"Cairo",adminAreaZH:"开罗",adminAreaEN:"Cairo",country:"EG",countryZH:"埃及",latitude:30.0444,longitude:31.2357),
        PresetCity(nameZH:"拉各斯",nameEN:"Lagos",adminAreaZH:"拉各斯",adminAreaEN:"Lagos",country:"NG",countryZH:"尼日利亚",latitude:6.5244,longitude:3.3792),
        PresetCity(nameZH:"卡萨布兰卡",nameEN:"Casablanca",adminAreaZH:"卡萨布兰卡",adminAreaEN:"Casablanca",country:"MA",countryZH:"摩洛哥",latitude:33.5731,longitude:-7.5898),
        PresetCity(nameZH:"亚的斯亚贝巴",nameEN:"Addis Ababa",adminAreaZH:"亚的斯亚贝巴",adminAreaEN:"Addis Ababa",country:"ET",countryZH:"埃塞俄比亚",latitude:9.0320,longitude:38.7469),
        // 中东
        PresetCity(nameZH:"迪拜",nameEN:"Dubai",adminAreaZH:"迪拜",adminAreaEN:"Dubai",country:"AE",countryZH:"阿联酋",latitude:25.2048,longitude:55.2708),
        PresetCity(nameZH:"阿布扎比",nameEN:"Abu Dhabi",adminAreaZH:"阿布扎比",adminAreaEN:"Abu Dhabi",country:"AE",countryZH:"阿联酋",latitude:24.4539,longitude:54.3773),
        PresetCity(nameZH:"多哈",nameEN:"Doha",adminAreaZH:"多哈",adminAreaEN:"Doha",country:"QA",countryZH:"卡塔尔",latitude:25.2854,longitude:51.5310),
        PresetCity(nameZH:"特拉维夫",nameEN:"Tel Aviv",adminAreaZH:"特拉维夫",adminAreaEN:"Tel Aviv",country:"IL",countryZH:"以色列",latitude:32.0853,longitude:34.7818),
        PresetCity(nameZH:"利雅得",nameEN:"Riyadh",adminAreaZH:"利雅得",adminAreaEN:"Riyadh",country:"SA",countryZH:"沙特",latitude:24.7136,longitude:46.6753),
        PresetCity(nameZH:"德黑兰",nameEN:"Tehran",adminAreaZH:"德黑兰",adminAreaEN:"Tehran",country:"IR",countryZH:"伊朗",latitude:35.6892,longitude:51.3890),
        PresetCity(nameZH:"安卡拉",nameEN:"Ankara",adminAreaZH:"安卡拉",adminAreaEN:"Ankara",country:"TR",countryZH:"土耳其",latitude:39.9334,longitude:32.8597),
    ]

    static func countriesGrouped(_ lang: AppLanguage) -> [(country: String, flag: String, cities: [Location])] {
        let allLocations = all.map { $0.toLocation() }
        let grouped = Dictionary(grouping: allLocations) { $0.country }
        return grouped.map { (code, cities) in
            let representative = cities.first!
            return (representative.displayCountry(lang), representative.countryFlag, cities.sorted { $0.displayName(lang) < $1.displayName(lang) })
        }.sorted { $0.country < $1.country }
    }
}

// MARK: - Country Group Helper

struct CountryGroup: Identifiable {
    let code: String; let flag: String; let nameZH: String; let nameEN: String; let cities: [Location]
    var id: String { code }
}
