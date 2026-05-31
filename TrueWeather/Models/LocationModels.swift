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
    func displayCountry(_ lang: AppLanguage) -> String { lang == .chinese ? countryZH : countryDisplayName(country) }

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
             "IS", "LU", "MT", "CY", "AL", "RS", "UA", "BY", "MD",
             "RU", "TR": return .europe
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

    static let all: [PresetCity] = china + japan + korea + southeastAsia + southAsia + northAmerica + europe + oceania + southAmerica + africa + middleEast

    // MARK: - 中国大陆 (34 provincial-level capitals)

    static let china: [PresetCity] = [
        PresetCity(nameZH:"北京",nameEN:"Beijing",adminAreaZH:"北京",adminAreaEN:"Beijing",country:"CN",countryZH:"中国",latitude:39.9042,longitude:116.4074),
        PresetCity(nameZH:"上海",nameEN:"Shanghai",adminAreaZH:"上海",adminAreaEN:"Shanghai",country:"CN",countryZH:"中国",latitude:31.2304,longitude:121.4737),
        PresetCity(nameZH:"天津",nameEN:"Tianjin",adminAreaZH:"天津",adminAreaEN:"Tianjin",country:"CN",countryZH:"中国",latitude:39.3434,longitude:117.3616),
        PresetCity(nameZH:"重庆",nameEN:"Chongqing",adminAreaZH:"重庆",adminAreaEN:"Chongqing",country:"CN",countryZH:"中国",latitude:29.5630,longitude:106.5516),
        PresetCity(nameZH:"广州",nameEN:"Guangzhou",adminAreaZH:"广东",adminAreaEN:"Guangdong",country:"CN",countryZH:"中国",latitude:23.1291,longitude:113.2644),
        PresetCity(nameZH:"深圳",nameEN:"Shenzhen",adminAreaZH:"广东",adminAreaEN:"Guangdong",country:"CN",countryZH:"中国",latitude:22.5431,longitude:114.0579),
        PresetCity(nameZH:"杭州",nameEN:"Hangzhou",adminAreaZH:"浙江",adminAreaEN:"Zhejiang",country:"CN",countryZH:"中国",latitude:30.2741,longitude:120.1551),
        PresetCity(nameZH:"南京",nameEN:"Nanjing",adminAreaZH:"江苏",adminAreaEN:"Jiangsu",country:"CN",countryZH:"中国",latitude:32.0603,longitude:118.7969),
        PresetCity(nameZH:"苏州",nameEN:"Suzhou",adminAreaZH:"江苏",adminAreaEN:"Jiangsu",country:"CN",countryZH:"中国",latitude:31.2990,longitude:120.5853),
        PresetCity(nameZH:"武汉",nameEN:"Wuhan",adminAreaZH:"湖北",adminAreaEN:"Hubei",country:"CN",countryZH:"中国",latitude:30.5928,longitude:114.3055),
        PresetCity(nameZH:"成都",nameEN:"Chengdu",adminAreaZH:"四川",adminAreaEN:"Sichuan",country:"CN",countryZH:"中国",latitude:30.5728,longitude:104.0668),
        PresetCity(nameZH:"西安",nameEN:"Xi'an",adminAreaZH:"陕西",adminAreaEN:"Shaanxi",country:"CN",countryZH:"中国",latitude:34.3416,longitude:108.9398),
        PresetCity(nameZH:"长沙",nameEN:"Changsha",adminAreaZH:"湖南",adminAreaEN:"Hunan",country:"CN",countryZH:"中国",latitude:28.2282,longitude:112.9388),
        PresetCity(nameZH:"沈阳",nameEN:"Shenyang",adminAreaZH:"辽宁",adminAreaEN:"Liaoning",country:"CN",countryZH:"中国",latitude:41.8057,longitude:123.4315),
        PresetCity(nameZH:"大连",nameEN:"Dalian",adminAreaZH:"辽宁",adminAreaEN:"Liaoning",country:"CN",countryZH:"中国",latitude:38.9140,longitude:121.6147),
        PresetCity(nameZH:"郑州",nameEN:"Zhengzhou",adminAreaZH:"河南",adminAreaEN:"Henan",country:"CN",countryZH:"中国",latitude:34.7466,longitude:113.6254),
        PresetCity(nameZH:"济南",nameEN:"Jinan",adminAreaZH:"山东",adminAreaEN:"Shandong",country:"CN",countryZH:"中国",latitude:36.6512,longitude:117.1201),
        PresetCity(nameZH:"青岛",nameEN:"Qingdao",adminAreaZH:"山东",adminAreaEN:"Shandong",country:"CN",countryZH:"中国",latitude:36.0671,longitude:120.3826),
        PresetCity(nameZH:"合肥",nameEN:"Hefei",adminAreaZH:"安徽",adminAreaEN:"Anhui",country:"CN",countryZH:"中国",latitude:31.8206,longitude:117.2272),
        PresetCity(nameZH:"福州",nameEN:"Fuzhou",adminAreaZH:"福建",adminAreaEN:"Fujian",country:"CN",countryZH:"中国",latitude:26.0745,longitude:119.2965),
        PresetCity(nameZH:"厦门",nameEN:"Xiamen",adminAreaZH:"福建",adminAreaEN:"Fujian",country:"CN",countryZH:"中国",latitude:24.4798,longitude:118.0894),
        PresetCity(nameZH:"南昌",nameEN:"Nanchang",adminAreaZH:"江西",adminAreaEN:"Jiangxi",country:"CN",countryZH:"中国",latitude:28.6820,longitude:115.8579),
        PresetCity(nameZH:"哈尔滨",nameEN:"Harbin",adminAreaZH:"黑龙江",adminAreaEN:"Heilongjiang",country:"CN",countryZH:"中国",latitude:45.8038,longitude:126.5350),
        PresetCity(nameZH:"长春",nameEN:"Changchun",adminAreaZH:"吉林",adminAreaEN:"Jilin",country:"CN",countryZH:"中国",latitude:43.8178,longitude:125.3235),
        PresetCity(nameZH:"太原",nameEN:"Taiyuan",adminAreaZH:"山西",adminAreaEN:"Shanxi",country:"CN",countryZH:"中国",latitude:37.8706,longitude:112.5489),
        PresetCity(nameZH:"石家庄",nameEN:"Shijiazhuang",adminAreaZH:"河北",adminAreaEN:"Hebei",country:"CN",countryZH:"中国",latitude:38.0428,longitude:114.5149),
        PresetCity(nameZH:"昆明",nameEN:"Kunming",adminAreaZH:"云南",adminAreaEN:"Yunnan",country:"CN",countryZH:"中国",latitude:25.0389,longitude:102.7183),
        PresetCity(nameZH:"贵阳",nameEN:"Guiyang",adminAreaZH:"贵州",adminAreaEN:"Guizhou",country:"CN",countryZH:"中国",latitude:26.6470,longitude:106.6302),
        PresetCity(nameZH:"南宁",nameEN:"Nanning",adminAreaZH:"广西",adminAreaEN:"Guangxi",country:"CN",countryZH:"中国",latitude:22.8170,longitude:108.3665),
        PresetCity(nameZH:"海口",nameEN:"Haikou",adminAreaZH:"海南",adminAreaEN:"Hainan",country:"CN",countryZH:"中国",latitude:20.0170,longitude:110.3492),
        PresetCity(nameZH:"兰州",nameEN:"Lanzhou",adminAreaZH:"甘肃",adminAreaEN:"Gansu",country:"CN",countryZH:"中国",latitude:36.0611,longitude:103.8343),
        PresetCity(nameZH:"西宁",nameEN:"Xining",adminAreaZH:"青海",adminAreaEN:"Qinghai",country:"CN",countryZH:"中国",latitude:36.6171,longitude:101.7785),
        PresetCity(nameZH:"银川",nameEN:"Yinchuan",adminAreaZH:"宁夏",adminAreaEN:"Ningxia",country:"CN",countryZH:"中国",latitude:38.4872,longitude:106.2309),
        PresetCity(nameZH:"乌鲁木齐",nameEN:"Urumqi",adminAreaZH:"新疆",adminAreaEN:"Xinjiang",country:"CN",countryZH:"中国",latitude:43.8256,longitude:87.6168),
        PresetCity(nameZH:"拉萨",nameEN:"Lhasa",adminAreaZH:"西藏",adminAreaEN:"Tibet",country:"CN",countryZH:"中国",latitude:29.6500,longitude:91.1000),
        PresetCity(nameZH:"呼和浩特",nameEN:"Hohhot",adminAreaZH:"内蒙古",adminAreaEN:"Inner Mongolia",country:"CN",countryZH:"中国",latitude:40.8424,longitude:111.7490),
        PresetCity(nameZH:"台北",nameEN:"Taipei",adminAreaZH:"台湾",adminAreaEN:"Taiwan",country:"CN",countryZH:"中国",latitude:25.0330,longitude:121.5654),
        PresetCity(nameZH:"香港",nameEN:"Hong Kong",adminAreaZH:"香港",adminAreaEN:"Hong Kong",country:"CN",countryZH:"中国",latitude:22.3193,longitude:114.1694),
        PresetCity(nameZH:"澳门",nameEN:"Macau",adminAreaZH:"澳门",adminAreaEN:"Macau",country:"CN",countryZH:"中国",latitude:22.1987,longitude:113.5439),
    ]

    // MARK: - 日本 (47 prefectural capitals)

    static let japan: [PresetCity] = [
        PresetCity(nameZH:"东京",nameEN:"Tokyo",adminAreaZH:"东京都",adminAreaEN:"Tokyo",country:"JP",countryZH:"日本",latitude:35.6762,longitude:139.6503),
        PresetCity(nameZH:"大阪",nameEN:"Osaka",adminAreaZH:"大阪府",adminAreaEN:"Osaka",country:"JP",countryZH:"日本",latitude:34.6937,longitude:135.5023),
        PresetCity(nameZH:"京都",nameEN:"Kyoto",adminAreaZH:"京都府",adminAreaEN:"Kyoto",country:"JP",countryZH:"日本",latitude:35.0116,longitude:135.7681),
        PresetCity(nameZH:"札幌",nameEN:"Sapporo",adminAreaZH:"北海道",adminAreaEN:"Hokkaido",country:"JP",countryZH:"日本",latitude:43.0618,longitude:141.3545),
        PresetCity(nameZH:"福冈",nameEN:"Fukuoka",adminAreaZH:"福冈县",adminAreaEN:"Fukuoka",country:"JP",countryZH:"日本",latitude:33.5904,longitude:130.4017),
        PresetCity(nameZH:"名古屋",nameEN:"Nagoya",adminAreaZH:"爱知县",adminAreaEN:"Aichi",country:"JP",countryZH:"日本",latitude:35.1815,longitude:136.9066),
        PresetCity(nameZH:"横滨",nameEN:"Yokohama",adminAreaZH:"神奈川县",adminAreaEN:"Kanagawa",country:"JP",countryZH:"日本",latitude:35.4437,longitude:139.6380),
        PresetCity(nameZH:"神户",nameEN:"Kobe",adminAreaZH:"兵库县",adminAreaEN:"Hyogo",country:"JP",countryZH:"日本",latitude:34.6901,longitude:135.1955),
        PresetCity(nameZH:"仙台",nameEN:"Sendai",adminAreaZH:"宫城县",adminAreaEN:"Miyagi",country:"JP",countryZH:"日本",latitude:38.2682,longitude:140.8694),
        PresetCity(nameZH:"广岛",nameEN:"Hiroshima",adminAreaZH:"广岛县",adminAreaEN:"Hiroshima",country:"JP",countryZH:"日本",latitude:34.3853,longitude:132.4553),
        PresetCity(nameZH:"那霸",nameEN:"Naha",adminAreaZH:"冲绳县",adminAreaEN:"Okinawa",country:"JP",countryZH:"日本",latitude:26.2124,longitude:127.6809),
        PresetCity(nameZH:"新潟",nameEN:"Niigata",adminAreaZH:"新潟县",adminAreaEN:"Niigata",country:"JP",countryZH:"日本",latitude:37.9162,longitude:139.0364),
        PresetCity(nameZH:"长野",nameEN:"Nagano",adminAreaZH:"长野县",adminAreaEN:"Nagano",country:"JP",countryZH:"日本",latitude:36.6485,longitude:138.1942),
        PresetCity(nameZH:"金泽",nameEN:"Kanazawa",adminAreaZH:"石川县",adminAreaEN:"Ishikawa",country:"JP",countryZH:"日本",latitude:36.5613,longitude:136.6562),
        PresetCity(nameZH:"静冈",nameEN:"Shizuoka",adminAreaZH:"静冈县",adminAreaEN:"Shizuoka",country:"JP",countryZH:"日本",latitude:34.9756,longitude:138.3828),
        PresetCity(nameZH:"鹿儿岛",nameEN:"Kagoshima",adminAreaZH:"鹿儿岛县",adminAreaEN:"Kagoshima",country:"JP",countryZH:"日本",latitude:31.5966,longitude:130.5571),
        PresetCity(nameZH:"熊本",nameEN:"Kumamoto",adminAreaZH:"熊本县",adminAreaEN:"Kumamoto",country:"JP",countryZH:"日本",latitude:32.8031,longitude:130.7079),
        PresetCity(nameZH:"冈山",nameEN:"Okayama",adminAreaZH:"冈山县",adminAreaEN:"Okayama",country:"JP",countryZH:"日本",latitude:34.6551,longitude:133.9195),
        PresetCity(nameZH:"松山",nameEN:"Matsuyama",adminAreaZH:"爱媛县",adminAreaEN:"Ehime",country:"JP",countryZH:"日本",latitude:33.8392,longitude:132.7655),
        PresetCity(nameZH:"高松",nameEN:"Takamatsu",adminAreaZH:"香川县",adminAreaEN:"Kagawa",country:"JP",countryZH:"日本",latitude:34.3428,longitude:134.0466),
    ]

    // MARK: - 韩国 (provincial-level capitals)

    static let korea: [PresetCity] = [
        PresetCity(nameZH:"首尔",nameEN:"Seoul",adminAreaZH:"首尔",adminAreaEN:"Seoul",country:"KR",countryZH:"韩国",latitude:37.5665,longitude:126.9780),
        PresetCity(nameZH:"釜山",nameEN:"Busan",adminAreaZH:"釜山",adminAreaEN:"Busan",country:"KR",countryZH:"韩国",latitude:35.1796,longitude:129.0756),
        PresetCity(nameZH:"仁川",nameEN:"Incheon",adminAreaZH:"仁川",adminAreaEN:"Incheon",country:"KR",countryZH:"韩国",latitude:37.4563,longitude:126.7052),
        PresetCity(nameZH:"大邱",nameEN:"Daegu",adminAreaZH:"大邱",adminAreaEN:"Daegu",country:"KR",countryZH:"韩国",latitude:35.8714,longitude:128.6014),
        PresetCity(nameZH:"大田",nameEN:"Daejeon",adminAreaZH:"大田",adminAreaEN:"Daejeon",country:"KR",countryZH:"韩国",latitude:36.3504,longitude:127.3845),
        PresetCity(nameZH:"光州",nameEN:"Gwangju",adminAreaZH:"光州",adminAreaEN:"Gwangju",country:"KR",countryZH:"韩国",latitude:35.1595,longitude:126.8526),
        PresetCity(nameZH:"蔚山",nameEN:"Ulsan",adminAreaZH:"蔚山",adminAreaEN:"Ulsan",country:"KR",countryZH:"韩国",latitude:35.5384,longitude:129.3114),
        PresetCity(nameZH:"世宗",nameEN:"Sejong",adminAreaZH:"世宗",adminAreaEN:"Sejong",country:"KR",countryZH:"韩国",latitude:36.4801,longitude:127.2890),
        PresetCity(nameZH:"水原",nameEN:"Suwon",adminAreaZH:"京畿道",adminAreaEN:"Gyeonggi",country:"KR",countryZH:"韩国",latitude:37.2636,longitude:127.0286),
        PresetCity(nameZH:"春川",nameEN:"Chuncheon",adminAreaZH:"江原道",adminAreaEN:"Gangwon",country:"KR",countryZH:"韩国",latitude:37.8813,longitude:127.7300),
        PresetCity(nameZH:"清州",nameEN:"Cheongju",adminAreaZH:"忠清北道",adminAreaEN:"Chungcheongbuk",country:"KR",countryZH:"韩国",latitude:36.6424,longitude:127.4890),
        PresetCity(nameZH:"全州",nameEN:"Jeonju",adminAreaZH:"全罗北道",adminAreaEN:"Jeollabuk",country:"KR",countryZH:"韩国",latitude:35.8242,longitude:127.1480),
        PresetCity(nameZH:"济州",nameEN:"Jeju",adminAreaZH:"济州道",adminAreaEN:"Jeju",country:"KR",countryZH:"韩国",latitude:33.4996,longitude:126.5312),
    ]

    // MARK: - 东南亚

    static let southeastAsia: [PresetCity] = [
        PresetCity(nameZH:"新加坡",nameEN:"Singapore",adminAreaZH:"新加坡",adminAreaEN:"Singapore",country:"SG",countryZH:"新加坡",latitude:1.3521,longitude:103.8198),
        PresetCity(nameZH:"曼谷",nameEN:"Bangkok",adminAreaZH:"曼谷",adminAreaEN:"Bangkok",country:"TH",countryZH:"泰国",latitude:13.7563,longitude:100.5018),
        PresetCity(nameZH:"清迈",nameEN:"Chiang Mai",adminAreaZH:"清迈府",adminAreaEN:"Chiang Mai",country:"TH",countryZH:"泰国",latitude:18.7883,longitude:98.9853),
        PresetCity(nameZH:"普吉",nameEN:"Phuket",adminAreaZH:"普吉府",adminAreaEN:"Phuket",country:"TH",countryZH:"泰国",latitude:7.8804,longitude:98.3923),
        PresetCity(nameZH:"芭堤雅",nameEN:"Pattaya",adminAreaZH:"春武里府",adminAreaEN:"Chonburi",country:"TH",countryZH:"泰国",latitude:12.9236,longitude:100.8825),
        PresetCity(nameZH:"吉隆坡",nameEN:"Kuala Lumpur",adminAreaZH:"吉隆坡",adminAreaEN:"Kuala Lumpur",country:"MY",countryZH:"马来西亚",latitude:3.1390,longitude:101.6869),
        PresetCity(nameZH:"槟城",nameEN:"Penang",adminAreaZH:"槟城",adminAreaEN:"Penang",country:"MY",countryZH:"马来西亚",latitude:5.4141,longitude:100.3288),
        PresetCity(nameZH:"新山",nameEN:"Johor Bahru",adminAreaZH:"柔佛",adminAreaEN:"Johor",country:"MY",countryZH:"马来西亚",latitude:1.4927,longitude:103.7414),
        PresetCity(nameZH:"哥打基纳巴卢",nameEN:"Kota Kinabalu",adminAreaZH:"沙巴",adminAreaEN:"Sabah",country:"MY",countryZH:"马来西亚",latitude:5.9804,longitude:116.0735),
        PresetCity(nameZH:"古晋",nameEN:"Kuching",adminAreaZH:"砂拉越",adminAreaEN:"Sarawak",country:"MY",countryZH:"马来西亚",latitude:1.5535,longitude:110.3593),
        PresetCity(nameZH:"雅加达",nameEN:"Jakarta",adminAreaZH:"雅加达",adminAreaEN:"Jakarta",country:"ID",countryZH:"印尼",latitude:-6.2088,longitude:106.8456),
        PresetCity(nameZH:"泗水",nameEN:"Surabaya",adminAreaZH:"东爪哇省",adminAreaEN:"East Java",country:"ID",countryZH:"印尼",latitude:-7.2575,longitude:112.7521),
        PresetCity(nameZH:"万隆",nameEN:"Bandung",adminAreaZH:"西爪哇省",adminAreaEN:"West Java",country:"ID",countryZH:"印尼",latitude:-6.9175,longitude:107.6191),
        PresetCity(nameZH:"棉兰",nameEN:"Medan",adminAreaZH:"北苏门答腊省",adminAreaEN:"North Sumatra",country:"ID",countryZH:"印尼",latitude:3.5952,longitude:98.6722),
        PresetCity(nameZH:"登巴萨",nameEN:"Denpasar",adminAreaZH:"巴厘省",adminAreaEN:"Bali",country:"ID",countryZH:"印尼",latitude:-8.6705,longitude:115.2126),
        PresetCity(nameZH:"望加锡",nameEN:"Makassar",adminAreaZH:"南苏拉威西省",adminAreaEN:"South Sulawesi",country:"ID",countryZH:"印尼",latitude:-5.1477,longitude:119.4327),
        PresetCity(nameZH:"马尼拉",nameEN:"Manila",adminAreaZH:"马尼拉",adminAreaEN:"Manila",country:"PH",countryZH:"菲律宾",latitude:14.5995,longitude:120.9842),
        PresetCity(nameZH:"宿务",nameEN:"Cebu",adminAreaZH:"宿务",adminAreaEN:"Cebu",country:"PH",countryZH:"菲律宾",latitude:10.3157,longitude:123.8854),
        PresetCity(nameZH:"达沃",nameEN:"Davao",adminAreaZH:"达沃",adminAreaEN:"Davao",country:"PH",countryZH:"菲律宾",latitude:7.0707,longitude:125.6087),
        PresetCity(nameZH:"河内",nameEN:"Hanoi",adminAreaZH:"河内",adminAreaEN:"Hanoi",country:"VN",countryZH:"越南",latitude:21.0278,longitude:105.8342),
        PresetCity(nameZH:"胡志明市",nameEN:"Ho Chi Minh City",adminAreaZH:"胡志明市",adminAreaEN:"Ho Chi Minh City",country:"VN",countryZH:"越南",latitude:10.8231,longitude:106.6297),
        PresetCity(nameZH:"岘港",nameEN:"Da Nang",adminAreaZH:"岘港",adminAreaEN:"Da Nang",country:"VN",countryZH:"越南",latitude:16.0544,longitude:108.2022),
        PresetCity(nameZH:"海防",nameEN:"Haiphong",adminAreaZH:"海防",adminAreaEN:"Haiphong",country:"VN",countryZH:"越南",latitude:20.8449,longitude:106.6881),
        PresetCity(nameZH:"芹苴",nameEN:"Can Tho",adminAreaZH:"芹苴",adminAreaEN:"Can Tho",country:"VN",countryZH:"越南",latitude:10.0452,longitude:105.7469),
        PresetCity(nameZH:"仰光",nameEN:"Yangon",adminAreaZH:"仰光",adminAreaEN:"Yangon",country:"MM",countryZH:"缅甸",latitude:16.8409,longitude:96.1735),
        PresetCity(nameZH:"内比都",nameEN:"Naypyidaw",adminAreaZH:"内比都",adminAreaEN:"Naypyidaw",country:"MM",countryZH:"缅甸",latitude:19.7633,longitude:96.0785),
        PresetCity(nameZH:"曼德勒",nameEN:"Mandalay",adminAreaZH:"曼德勒",adminAreaEN:"Mandalay",country:"MM",countryZH:"缅甸",latitude:21.9588,longitude:96.0891),
        PresetCity(nameZH:"金边",nameEN:"Phnom Penh",adminAreaZH:"金边",adminAreaEN:"Phnom Penh",country:"KH",countryZH:"柬埔寨",latitude:11.5564,longitude:104.9282),
        PresetCity(nameZH:"暹粒",nameEN:"Siem Reap",adminAreaZH:"暹粒",adminAreaEN:"Siem Reap",country:"KH",countryZH:"柬埔寨",latitude:13.3633,longitude:103.8564),
        PresetCity(nameZH:"万象",nameEN:"Vientiane",adminAreaZH:"万象",adminAreaEN:"Vientiane",country:"LA",countryZH:"老挝",latitude:17.9757,longitude:102.6331),
        PresetCity(nameZH:"斯里巴加湾",nameEN:"Bandar Seri Begawan",adminAreaZH:"文莱",adminAreaEN:"Brunei",country:"BN",countryZH:"文莱",latitude:4.9031,longitude:114.9398),
        PresetCity(nameZH:"帝力",nameEN:"Dili",adminAreaZH:"帝力",adminAreaEN:"Dili",country:"TL",countryZH:"东帝汶",latitude:-8.5569,longitude:125.5603),
    ]

    // MARK: - 南亚

    static let southAsia: [PresetCity] = [
        PresetCity(nameZH:"新德里",nameEN:"New Delhi",adminAreaZH:"德里",adminAreaEN:"Delhi",country:"IN",countryZH:"印度",latitude:28.6139,longitude:77.2090),
        PresetCity(nameZH:"孟买",nameEN:"Mumbai",adminAreaZH:"马哈拉施特拉邦",adminAreaEN:"Maharashtra",country:"IN",countryZH:"印度",latitude:19.0760,longitude:72.8777),
        PresetCity(nameZH:"班加罗尔",nameEN:"Bangalore",adminAreaZH:"卡纳塔克邦",adminAreaEN:"Karnataka",country:"IN",countryZH:"印度",latitude:12.9716,longitude:77.5946),
        PresetCity(nameZH:"金奈",nameEN:"Chennai",adminAreaZH:"泰米尔纳德邦",adminAreaEN:"Tamil Nadu",country:"IN",countryZH:"印度",latitude:13.0827,longitude:80.2707),
        PresetCity(nameZH:"加尔各答",nameEN:"Kolkata",adminAreaZH:"西孟加拉邦",adminAreaEN:"West Bengal",country:"IN",countryZH:"印度",latitude:22.5726,longitude:88.3639),
        PresetCity(nameZH:"海得拉巴",nameEN:"Hyderabad",adminAreaZH:"特伦甘纳邦",adminAreaEN:"Telangana",country:"IN",countryZH:"印度",latitude:17.3850,longitude:78.4867),
        PresetCity(nameZH:"艾哈迈达巴德",nameEN:"Ahmedabad",adminAreaZH:"古吉拉特邦",adminAreaEN:"Gujarat",country:"IN",countryZH:"印度",latitude:23.0225,longitude:72.5714),
        PresetCity(nameZH:"浦那",nameEN:"Pune",adminAreaZH:"马哈拉施特拉邦",adminAreaEN:"Maharashtra",country:"IN",countryZH:"印度",latitude:18.5204,longitude:73.8567),
        PresetCity(nameZH:"斋浦尔",nameEN:"Jaipur",adminAreaZH:"拉贾斯坦邦",adminAreaEN:"Rajasthan",country:"IN",countryZH:"印度",latitude:26.9124,longitude:75.7873),
        PresetCity(nameZH:"勒克瑙",nameEN:"Lucknow",adminAreaZH:"北方邦",adminAreaEN:"Uttar Pradesh",country:"IN",countryZH:"印度",latitude:26.8467,longitude:80.9462),
        PresetCity(nameZH:"昌迪加尔",nameEN:"Chandigarh",adminAreaZH:"昌迪加尔",adminAreaEN:"Chandigarh",country:"IN",countryZH:"印度",latitude:30.7333,longitude:76.7794),
        PresetCity(nameZH:"博帕尔",nameEN:"Bhopal",adminAreaZH:"中央邦",adminAreaEN:"Madhya Pradesh",country:"IN",countryZH:"印度",latitude:23.2599,longitude:77.4126),
        PresetCity(nameZH:"布巴内斯瓦尔",nameEN:"Bhubaneswar",adminAreaZH:"奥里萨邦",adminAreaEN:"Odisha",country:"IN",countryZH:"印度",latitude:20.2961,longitude:85.8245),
        PresetCity(nameZH:"巴特那",nameEN:"Patna",adminAreaZH:"比哈尔邦",adminAreaEN:"Bihar",country:"IN",countryZH:"印度",latitude:25.5941,longitude:85.1376),
        PresetCity(nameZH:"伊斯兰堡",nameEN:"Islamabad",adminAreaZH:"伊斯兰堡",adminAreaEN:"Islamabad",country:"PK",countryZH:"巴基斯坦",latitude:33.6844,longitude:73.0479),
        PresetCity(nameZH:"卡拉奇",nameEN:"Karachi",adminAreaZH:"信德省",adminAreaEN:"Sindh",country:"PK",countryZH:"巴基斯坦",latitude:24.8607,longitude:67.0011),
        PresetCity(nameZH:"拉合尔",nameEN:"Lahore",adminAreaZH:"旁遮普省",adminAreaEN:"Punjab",country:"PK",countryZH:"巴基斯坦",latitude:31.5497,longitude:74.3436),
        PresetCity(nameZH:"奎达",nameEN:"Quetta",adminAreaZH:"俾路支省",adminAreaEN:"Balochistan",country:"PK",countryZH:"巴基斯坦",latitude:30.1798,longitude:66.9750),
        PresetCity(nameZH:"白沙瓦",nameEN:"Peshawar",adminAreaZH:"开伯尔省",adminAreaEN:"Khyber Pakhtunkhwa",country:"PK",countryZH:"巴基斯坦",latitude:34.0151,longitude:71.5249),
        PresetCity(nameZH:"达卡",nameEN:"Dhaka",adminAreaZH:"达卡",adminAreaEN:"Dhaka",country:"BD",countryZH:"孟加拉国",latitude:23.8103,longitude:90.4125),
        PresetCity(nameZH:"吉大港",nameEN:"Chittagong",adminAreaZH:"吉大港",adminAreaEN:"Chittagong",country:"BD",countryZH:"孟加拉国",latitude:22.3569,longitude:91.7832),
        PresetCity(nameZH:"科伦坡",nameEN:"Colombo",adminAreaZH:"科伦坡",adminAreaEN:"Colombo",country:"LK",countryZH:"斯里兰卡",latitude:6.9271,longitude:79.8612),
        PresetCity(nameZH:"康提",nameEN:"Kandy",adminAreaZH:"中央省",adminAreaEN:"Central",country:"LK",countryZH:"斯里兰卡",latitude:7.2906,longitude:80.6337),
        PresetCity(nameZH:"加德满都",nameEN:"Kathmandu",adminAreaZH:"加德满都",adminAreaEN:"Kathmandu",country:"NP",countryZH:"尼泊尔",latitude:27.7172,longitude:85.3240),
        PresetCity(nameZH:"博卡拉",nameEN:"Pokhara",adminAreaZH:"甘达基省",adminAreaEN:"Gandaki",country:"NP",countryZH:"尼泊尔",latitude:28.2095,longitude:83.9856),
        PresetCity(nameZH:"廷布",nameEN:"Thimphu",adminAreaZH:"廷布",adminAreaEN:"Thimphu",country:"BT",countryZH:"不丹",latitude:27.4728,longitude:89.6390),
        PresetCity(nameZH:"马累",nameEN:"Male",adminAreaZH:"马累",adminAreaEN:"Male",country:"MV",countryZH:"马尔代夫",latitude:4.1755,longitude:73.5093),
    ]

    // MARK: - 北美

    static let northAmerica: [PresetCity] = [
        // 美国 (50 states + DC)
        PresetCity(nameZH:"华盛顿",nameEN:"Washington DC",adminAreaZH:"华盛顿特区",adminAreaEN:"District of Columbia",country:"US",countryZH:"美国",latitude:38.9072,longitude:-77.0369),
        PresetCity(nameZH:"纽约",nameEN:"New York",adminAreaZH:"纽约州",adminAreaEN:"New York",country:"US",countryZH:"美国",latitude:40.7128,longitude:-74.0060),
        PresetCity(nameZH:"洛杉矶",nameEN:"Los Angeles",adminAreaZH:"加利福尼亚州",adminAreaEN:"California",country:"US",countryZH:"美国",latitude:34.0522,longitude:-118.2437),
        PresetCity(nameZH:"芝加哥",nameEN:"Chicago",adminAreaZH:"伊利诺伊州",adminAreaEN:"Illinois",country:"US",countryZH:"美国",latitude:41.8781,longitude:-87.6298),
        PresetCity(nameZH:"休斯顿",nameEN:"Houston",adminAreaZH:"得克萨斯州",adminAreaEN:"Texas",country:"US",countryZH:"美国",latitude:29.7604,longitude:-95.3698),
        PresetCity(nameZH:"旧金山",nameEN:"San Francisco",adminAreaZH:"加利福尼亚州",adminAreaEN:"California",country:"US",countryZH:"美国",latitude:37.7749,longitude:-122.4194),
        PresetCity(nameZH:"西雅图",nameEN:"Seattle",adminAreaZH:"华盛顿州",adminAreaEN:"Washington",country:"US",countryZH:"美国",latitude:47.6062,longitude:-122.3321),
        PresetCity(nameZH:"迈阿密",nameEN:"Miami",adminAreaZH:"佛罗里达州",adminAreaEN:"Florida",country:"US",countryZH:"美国",latitude:25.7617,longitude:-80.1918),
        PresetCity(nameZH:"波士顿",nameEN:"Boston",adminAreaZH:"马萨诸塞州",adminAreaEN:"Massachusetts",country:"US",countryZH:"美国",latitude:42.3601,longitude:-71.0589),
        PresetCity(nameZH:"亚特兰大",nameEN:"Atlanta",adminAreaZH:"佐治亚州",adminAreaEN:"Georgia",country:"US",countryZH:"美国",latitude:33.7490,longitude:-84.3880),
        PresetCity(nameZH:"丹佛",nameEN:"Denver",adminAreaZH:"科罗拉多州",adminAreaEN:"Colorado",country:"US",countryZH:"美国",latitude:39.7392,longitude:-104.9903),
        PresetCity(nameZH:"拉斯维加斯",nameEN:"Las Vegas",adminAreaZH:"内华达州",adminAreaEN:"Nevada",country:"US",countryZH:"美国",latitude:36.1716,longitude:-115.1391),
        PresetCity(nameZH:"费城",nameEN:"Philadelphia",adminAreaZH:"宾夕法尼亚州",adminAreaEN:"Pennsylvania",country:"US",countryZH:"美国",latitude:39.9526,longitude:-75.1652),
        PresetCity(nameZH:"菲尼克斯",nameEN:"Phoenix",adminAreaZH:"亚利桑那州",adminAreaEN:"Arizona",country:"US",countryZH:"美国",latitude:33.4484,longitude:-112.0740),
        PresetCity(nameZH:"达拉斯",nameEN:"Dallas",adminAreaZH:"得克萨斯州",adminAreaEN:"Texas",country:"US",countryZH:"美国",latitude:32.7767,longitude:-96.7970),
        PresetCity(nameZH:"波特兰",nameEN:"Portland",adminAreaZH:"俄勒冈州",adminAreaEN:"Oregon",country:"US",countryZH:"美国",latitude:45.5152,longitude:-122.6784),
        PresetCity(nameZH:"明尼阿波利斯",nameEN:"Minneapolis",adminAreaZH:"明尼苏达州",adminAreaEN:"Minnesota",country:"US",countryZH:"美国",latitude:44.9778,longitude:-93.2650),
        PresetCity(nameZH:"底特律",nameEN:"Detroit",adminAreaZH:"密歇根州",adminAreaEN:"Michigan",country:"US",countryZH:"美国",latitude:42.3314,longitude:-83.0458),
        PresetCity(nameZH:"新奥尔良",nameEN:"New Orleans",adminAreaZH:"路易斯安那州",adminAreaEN:"Louisiana",country:"US",countryZH:"美国",latitude:29.9511,longitude:-90.0715),
        PresetCity(nameZH:"盐湖城",nameEN:"Salt Lake City",adminAreaZH:"犹他州",adminAreaEN:"Utah",country:"US",countryZH:"美国",latitude:40.7608,longitude:-111.8910),
        PresetCity(nameZH:"纳什维尔",nameEN:"Nashville",adminAreaZH:"田纳西州",adminAreaEN:"Tennessee",country:"US",countryZH:"美国",latitude:36.1627,longitude:-86.7816),
        PresetCity(nameZH:"火奴鲁鲁",nameEN:"Honolulu",adminAreaZH:"夏威夷州",adminAreaEN:"Hawaii",country:"US",countryZH:"美国",latitude:21.3069,longitude:-157.8583),
        PresetCity(nameZH:"安克雷奇",nameEN:"Anchorage",adminAreaZH:"阿拉斯加州",adminAreaEN:"Alaska",country:"US",countryZH:"美国",latitude:61.2181,longitude:-149.9003),
        // 加拿大 (10 provinces + 3 territories)
        PresetCity(nameZH:"多伦多",nameEN:"Toronto",adminAreaZH:"安大略省",adminAreaEN:"Ontario",country:"CA",countryZH:"加拿大",latitude:43.6532,longitude:-79.3832),
        PresetCity(nameZH:"温哥华",nameEN:"Vancouver",adminAreaZH:"不列颠哥伦比亚省",adminAreaEN:"British Columbia",country:"CA",countryZH:"加拿大",latitude:49.2827,longitude:-123.1207),
        PresetCity(nameZH:"蒙特利尔",nameEN:"Montreal",adminAreaZH:"魁北克省",adminAreaEN:"Quebec",country:"CA",countryZH:"加拿大",latitude:45.5017,longitude:-73.5673),
        PresetCity(nameZH:"卡尔加里",nameEN:"Calgary",adminAreaZH:"阿尔伯塔省",adminAreaEN:"Alberta",country:"CA",countryZH:"加拿大",latitude:51.0447,longitude:-114.0719),
        PresetCity(nameZH:"渥太华",nameEN:"Ottawa",adminAreaZH:"安大略省",adminAreaEN:"Ontario",country:"CA",countryZH:"加拿大",latitude:45.4215,longitude:-75.6972),
        PresetCity(nameZH:"埃德蒙顿",nameEN:"Edmonton",adminAreaZH:"阿尔伯塔省",adminAreaEN:"Alberta",country:"CA",countryZH:"加拿大",latitude:53.5461,longitude:-113.4938),
        PresetCity(nameZH:"温尼伯",nameEN:"Winnipeg",adminAreaZH:"马尼托巴省",adminAreaEN:"Manitoba",country:"CA",countryZH:"加拿大",latitude:49.8951,longitude:-97.1384),
        PresetCity(nameZH:"魁北克市",nameEN:"Quebec City",adminAreaZH:"魁北克省",adminAreaEN:"Quebec",country:"CA",countryZH:"加拿大",latitude:46.8139,longitude:-71.2080),
        PresetCity(nameZH:"哈利法克斯",nameEN:"Halifax",adminAreaZH:"新斯科舍省",adminAreaEN:"Nova Scotia",country:"CA",countryZH:"加拿大",latitude:44.6488,longitude:-63.5752),
        PresetCity(nameZH:"维多利亚",nameEN:"Victoria",adminAreaZH:"不列颠哥伦比亚省",adminAreaEN:"British Columbia",country:"CA",countryZH:"加拿大",latitude:48.4284,longitude:-123.3656),
        // 墨西哥 (32 states)
        PresetCity(nameZH:"墨西哥城",nameEN:"Mexico City",adminAreaZH:"墨西哥城",adminAreaEN:"Mexico City",country:"MX",countryZH:"墨西哥",latitude:19.4326,longitude:-99.1332),
        PresetCity(nameZH:"瓜达拉哈拉",nameEN:"Guadalajara",adminAreaZH:"哈利斯科州",adminAreaEN:"Jalisco",country:"MX",countryZH:"墨西哥",latitude:20.6597,longitude:-103.3496),
        PresetCity(nameZH:"蒙特雷",nameEN:"Monterrey",adminAreaZH:"新莱昂州",adminAreaEN:"Nuevo León",country:"MX",countryZH:"墨西哥",latitude:25.6866,longitude:-100.3161),
        PresetCity(nameZH:"坎昆",nameEN:"Cancun",adminAreaZH:"金塔纳罗奥州",adminAreaEN:"Quintana Roo",country:"MX",countryZH:"墨西哥",latitude:21.1619,longitude:-86.8515),
        PresetCity(nameZH:"蒂华纳",nameEN:"Tijuana",adminAreaZH:"下加利福尼亚州",adminAreaEN:"Baja California",country:"MX",countryZH:"墨西哥",latitude:32.5149,longitude:-117.0382),
    ]

    // MARK: - 欧洲

    static let europe: [PresetCity] = [
        // 英国
        PresetCity(nameZH:"伦敦",nameEN:"London",adminAreaZH:"英格兰",adminAreaEN:"England",country:"GB",countryZH:"英国",latitude:51.5074,longitude:-0.1278),
        PresetCity(nameZH:"爱丁堡",nameEN:"Edinburgh",adminAreaZH:"苏格兰",adminAreaEN:"Scotland",country:"GB",countryZH:"英国",latitude:55.9533,longitude:-3.1883),
        PresetCity(nameZH:"曼彻斯特",nameEN:"Manchester",adminAreaZH:"英格兰",adminAreaEN:"England",country:"GB",countryZH:"英国",latitude:53.4808,longitude:-2.2426),
        PresetCity(nameZH:"伯明翰",nameEN:"Birmingham",adminAreaZH:"英格兰",adminAreaEN:"England",country:"GB",countryZH:"英国",latitude:52.4862,longitude:-1.8904),
        PresetCity(nameZH:"加的夫",nameEN:"Cardiff",adminAreaZH:"威尔士",adminAreaEN:"Wales",country:"GB",countryZH:"英国",latitude:51.4816,longitude:-3.1791),
        PresetCity(nameZH:"贝尔法斯特",nameEN:"Belfast",adminAreaZH:"北爱尔兰",adminAreaEN:"Northern Ireland",country:"GB",countryZH:"英国",latitude:54.5973,longitude:-5.9301),
        PresetCity(nameZH:"格拉斯哥",nameEN:"Glasgow",adminAreaZH:"苏格兰",adminAreaEN:"Scotland",country:"GB",countryZH:"英国",latitude:55.8642,longitude:-4.2518),
        // 法国
        PresetCity(nameZH:"巴黎",nameEN:"Paris",adminAreaZH:"法兰西岛",adminAreaEN:"Île-de-France",country:"FR",countryZH:"法国",latitude:48.8566,longitude:2.3522),
        PresetCity(nameZH:"里昂",nameEN:"Lyon",adminAreaZH:"奥弗涅-罗讷-阿尔卑斯",adminAreaEN:"Auvergne-Rhône-Alpes",country:"FR",countryZH:"法国",latitude:45.7640,longitude:4.8357),
        PresetCity(nameZH:"马赛",nameEN:"Marseille",adminAreaZH:"普罗旺斯-阿尔卑斯-蔚蓝海岸",adminAreaEN:"Provence-Alpes-Côte d'Azur",country:"FR",countryZH:"法国",latitude:43.2965,longitude:5.3698),
        PresetCity(nameZH:"尼斯",nameEN:"Nice",adminAreaZH:"普罗旺斯-阿尔卑斯-蔚蓝海岸",adminAreaEN:"Provence-Alpes-Côte d'Azur",country:"FR",countryZH:"法国",latitude:43.7102,longitude:7.2620),
        PresetCity(nameZH:"波尔多",nameEN:"Bordeaux",adminAreaZH:"新阿基坦",adminAreaEN:"Nouvelle-Aquitaine",country:"FR",countryZH:"法国",latitude:44.8378,longitude:-0.5792),
        PresetCity(nameZH:"图卢兹",nameEN:"Toulouse",adminAreaZH:"奥克西塔尼",adminAreaEN:"Occitanie",country:"FR",countryZH:"法国",latitude:43.6047,longitude:1.4442),
        // 德国 (16 states)
        PresetCity(nameZH:"柏林",nameEN:"Berlin",adminAreaZH:"柏林",adminAreaEN:"Berlin",country:"DE",countryZH:"德国",latitude:52.5200,longitude:13.4050),
        PresetCity(nameZH:"慕尼黑",nameEN:"Munich",adminAreaZH:"巴伐利亚",adminAreaEN:"Bavaria",country:"DE",countryZH:"德国",latitude:48.1351,longitude:11.5820),
        PresetCity(nameZH:"汉堡",nameEN:"Hamburg",adminAreaZH:"汉堡",adminAreaEN:"Hamburg",country:"DE",countryZH:"德国",latitude:53.5511,longitude:9.9937),
        PresetCity(nameZH:"法兰克福",nameEN:"Frankfurt",adminAreaZH:"黑森",adminAreaEN:"Hesse",country:"DE",countryZH:"德国",latitude:50.1109,longitude:8.6821),
        PresetCity(nameZH:"斯图加特",nameEN:"Stuttgart",adminAreaZH:"巴登-符腾堡",adminAreaEN:"Baden-Württemberg",country:"DE",countryZH:"德国",latitude:48.7758,longitude:9.1829),
        PresetCity(nameZH:"科隆",nameEN:"Cologne",adminAreaZH:"北莱茵-威斯特法伦",adminAreaEN:"North Rhine-Westphalia",country:"DE",countryZH:"德国",latitude:50.9375,longitude:6.9603),
        PresetCity(nameZH:"杜塞尔多夫",nameEN:"Düsseldorf",adminAreaZH:"北莱茵-威斯特法伦",adminAreaEN:"North Rhine-Westphalia",country:"DE",countryZH:"德国",latitude:51.2277,longitude:6.7735),
        PresetCity(nameZH:"莱比锡",nameEN:"Leipzig",adminAreaZH:"萨克森",adminAreaEN:"Saxony",country:"DE",countryZH:"德国",latitude:51.3397,longitude:12.3731),
        PresetCity(nameZH:"德累斯顿",nameEN:"Dresden",adminAreaZH:"萨克森",adminAreaEN:"Saxony",country:"DE",countryZH:"德国",latitude:51.0504,longitude:13.7373),
        // 意大利
        PresetCity(nameZH:"罗马",nameEN:"Rome",adminAreaZH:"拉齐奥",adminAreaEN:"Lazio",country:"IT",countryZH:"意大利",latitude:41.9028,longitude:12.4964),
        PresetCity(nameZH:"米兰",nameEN:"Milan",adminAreaZH:"伦巴第",adminAreaEN:"Lombardy",country:"IT",countryZH:"意大利",latitude:45.4642,longitude:9.1900),
        PresetCity(nameZH:"那不勒斯",nameEN:"Naples",adminAreaZH:"坎帕尼亚",adminAreaEN:"Campania",country:"IT",countryZH:"意大利",latitude:40.8518,longitude:14.2681),
        PresetCity(nameZH:"都灵",nameEN:"Turin",adminAreaZH:"皮埃蒙特",adminAreaEN:"Piedmont",country:"IT",countryZH:"意大利",latitude:45.0703,longitude:7.6869),
        PresetCity(nameZH:"佛罗伦萨",nameEN:"Florence",adminAreaZH:"托斯卡纳",adminAreaEN:"Tuscany",country:"IT",countryZH:"意大利",latitude:43.7696,longitude:11.2558),
        PresetCity(nameZH:"威尼斯",nameEN:"Venice",adminAreaZH:"威尼托",adminAreaEN:"Veneto",country:"IT",countryZH:"意大利",latitude:45.4408,longitude:12.3155),
        PresetCity(nameZH:"博洛尼亚",nameEN:"Bologna",adminAreaZH:"艾米利亚-罗马涅",adminAreaEN:"Emilia-Romagna",country:"IT",countryZH:"意大利",latitude:44.4949,longitude:11.3426),
        PresetCity(nameZH:"巴勒莫",nameEN:"Palermo",adminAreaZH:"西西里",adminAreaEN:"Sicily",country:"IT",countryZH:"意大利",latitude:38.1157,longitude:13.3615),
        // 西班牙
        PresetCity(nameZH:"马德里",nameEN:"Madrid",adminAreaZH:"马德里",adminAreaEN:"Madrid",country:"ES",countryZH:"西班牙",latitude:40.4168,longitude:-3.7038),
        PresetCity(nameZH:"巴塞罗那",nameEN:"Barcelona",adminAreaZH:"加泰罗尼亚",adminAreaEN:"Catalonia",country:"ES",countryZH:"西班牙",latitude:41.3874,longitude:2.1686),
        PresetCity(nameZH:"瓦伦西亚",nameEN:"Valencia",adminAreaZH:"瓦伦西亚",adminAreaEN:"Valencia",country:"ES",countryZH:"西班牙",latitude:39.4699,longitude:-0.3763),
        PresetCity(nameZH:"塞维利亚",nameEN:"Seville",adminAreaZH:"安达卢西亚",adminAreaEN:"Andalusia",country:"ES",countryZH:"西班牙",latitude:37.3891,longitude:-5.9845),
        PresetCity(nameZH:"毕尔巴鄂",nameEN:"Bilbao",adminAreaZH:"巴斯克",adminAreaEN:"Basque Country",country:"ES",countryZH:"西班牙",latitude:43.2630,longitude:-2.9350),
        // 俄罗斯
        PresetCity(nameZH:"莫斯科",nameEN:"Moscow",adminAreaZH:"莫斯科",adminAreaEN:"Moscow",country:"RU",countryZH:"俄罗斯",latitude:55.7558,longitude:37.6173),
        PresetCity(nameZH:"圣彼得堡",nameEN:"Saint Petersburg",adminAreaZH:"圣彼得堡",adminAreaEN:"Saint Petersburg",country:"RU",countryZH:"俄罗斯",latitude:59.9343,longitude:30.3351),
        PresetCity(nameZH:"叶卡捷琳堡",nameEN:"Yekaterinburg",adminAreaZH:"斯维尔德洛夫斯克州",adminAreaEN:"Sverdlovsk",country:"RU",countryZH:"俄罗斯",latitude:56.8389,longitude:60.6057),
        PresetCity(nameZH:"新西伯利亚",nameEN:"Novosibirsk",adminAreaZH:"新西伯利亚州",adminAreaEN:"Novosibirsk",country:"RU",countryZH:"俄罗斯",latitude:55.0084,longitude:82.9357),
        PresetCity(nameZH:"喀山",nameEN:"Kazan",adminAreaZH:"鞑靼斯坦",adminAreaEN:"Tatarstan",country:"RU",countryZH:"俄罗斯",latitude:55.7879,longitude:49.1233),
        PresetCity(nameZH:"符拉迪沃斯托克",nameEN:"Vladivostok",adminAreaZH:"滨海边疆区",adminAreaEN:"Primorsky",country:"RU",countryZH:"俄罗斯",latitude:43.1155,longitude:131.8855),
        // 土耳其
        PresetCity(nameZH:"安卡拉",nameEN:"Ankara",adminAreaZH:"安卡拉",adminAreaEN:"Ankara",country:"TR",countryZH:"土耳其",latitude:39.9334,longitude:32.8597),
        PresetCity(nameZH:"伊斯坦布尔",nameEN:"Istanbul",adminAreaZH:"伊斯坦布尔",adminAreaEN:"Istanbul",country:"TR",countryZH:"土耳其",latitude:41.0082,longitude:28.9784),
        PresetCity(nameZH:"伊兹密尔",nameEN:"Izmir",adminAreaZH:"伊兹密尔",adminAreaEN:"Izmir",country:"TR",countryZH:"土耳其",latitude:38.4192,longitude:27.1287),
        PresetCity(nameZH:"安塔利亚",nameEN:"Antalya",adminAreaZH:"安塔利亚",adminAreaEN:"Antalya",country:"TR",countryZH:"土耳其",latitude:36.8969,longitude:30.7133),
        // 荷兰/比利时/瑞士/奥地利
        PresetCity(nameZH:"阿姆斯特丹",nameEN:"Amsterdam",adminAreaZH:"北荷兰省",adminAreaEN:"North Holland",country:"NL",countryZH:"荷兰",latitude:52.3676,longitude:4.9041),
        PresetCity(nameZH:"鹿特丹",nameEN:"Rotterdam",adminAreaZH:"南荷兰省",adminAreaEN:"South Holland",country:"NL",countryZH:"荷兰",latitude:51.9244,longitude:4.4777),
        PresetCity(nameZH:"海牙",nameEN:"The Hague",adminAreaZH:"南荷兰省",adminAreaEN:"South Holland",country:"NL",countryZH:"荷兰",latitude:52.0705,longitude:4.3007),
        PresetCity(nameZH:"布鲁塞尔",nameEN:"Brussels",adminAreaZH:"布鲁塞尔",adminAreaEN:"Brussels",country:"BE",countryZH:"比利时",latitude:50.8503,longitude:4.3517),
        PresetCity(nameZH:"苏黎世",nameEN:"Zurich",adminAreaZH:"苏黎世",adminAreaEN:"Zurich",country:"CH",countryZH:"瑞士",latitude:47.3769,longitude:8.5417),
        PresetCity(nameZH:"日内瓦",nameEN:"Geneva",adminAreaZH:"日内瓦",adminAreaEN:"Geneva",country:"CH",countryZH:"瑞士",latitude:46.2044,longitude:6.1432),
        PresetCity(nameZH:"维也纳",nameEN:"Vienna",adminAreaZH:"维也纳",adminAreaEN:"Vienna",country:"AT",countryZH:"奥地利",latitude:48.2082,longitude:16.3738),
        PresetCity(nameZH:"萨尔茨堡",nameEN:"Salzburg",adminAreaZH:"萨尔茨堡",adminAreaEN:"Salzburg",country:"AT",countryZH:"奥地利",latitude:47.8095,longitude:13.0550),
        // 北欧
        PresetCity(nameZH:"斯德哥尔摩",nameEN:"Stockholm",adminAreaZH:"斯德哥尔摩",adminAreaEN:"Stockholm",country:"SE",countryZH:"瑞典",latitude:59.3293,longitude:18.0686),
        PresetCity(nameZH:"哥德堡",nameEN:"Gothenburg",adminAreaZH:"西约塔兰",adminAreaEN:"Västra Götaland",country:"SE",countryZH:"瑞典",latitude:57.7089,longitude:11.9746),
        PresetCity(nameZH:"奥斯陆",nameEN:"Oslo",adminAreaZH:"奥斯陆",adminAreaEN:"Oslo",country:"NO",countryZH:"挪威",latitude:59.9139,longitude:10.7522),
        PresetCity(nameZH:"卑尔根",nameEN:"Bergen",adminAreaZH:"韦斯特兰",adminAreaEN:"Vestland",country:"NO",countryZH:"挪威",latitude:60.3913,longitude:5.3221),
        PresetCity(nameZH:"哥本哈根",nameEN:"Copenhagen",adminAreaZH:"哥本哈根",adminAreaEN:"Copenhagen",country:"DK",countryZH:"丹麦",latitude:55.6761,longitude:12.5683),
        PresetCity(nameZH:"赫尔辛基",nameEN:"Helsinki",adminAreaZH:"赫尔辛基",adminAreaEN:"Helsinki",country:"FI",countryZH:"芬兰",latitude:60.1699,longitude:24.9384),
        // 东欧
        PresetCity(nameZH:"华沙",nameEN:"Warsaw",adminAreaZH:"华沙",adminAreaEN:"Warsaw",country:"PL",countryZH:"波兰",latitude:52.2297,longitude:21.0122),
        PresetCity(nameZH:"克拉科夫",nameEN:"Krakow",adminAreaZH:"小波兰省",adminAreaEN:"Lesser Poland",country:"PL",countryZH:"波兰",latitude:50.0647,longitude:19.9450),
        PresetCity(nameZH:"布拉格",nameEN:"Prague",adminAreaZH:"布拉格",adminAreaEN:"Prague",country:"CZ",countryZH:"捷克",latitude:50.0755,longitude:14.4378),
        PresetCity(nameZH:"布达佩斯",nameEN:"Budapest",adminAreaZH:"布达佩斯",adminAreaEN:"Budapest",country:"HU",countryZH:"匈牙利",latitude:47.4979,longitude:19.0402),
        PresetCity(nameZH:"布加勒斯特",nameEN:"Bucharest",adminAreaZH:"布加勒斯特",adminAreaEN:"Bucharest",country:"RO",countryZH:"罗马尼亚",latitude:44.4268,longitude:26.1025),
        PresetCity(nameZH:"索菲亚",nameEN:"Sofia",adminAreaZH:"索菲亚",adminAreaEN:"Sofia",country:"BG",countryZH:"保加利亚",latitude:42.6977,longitude:23.3219),
        PresetCity(nameZH:"雅典",nameEN:"Athens",adminAreaZH:"雅典",adminAreaEN:"Athens",country:"GR",countryZH:"希腊",latitude:37.9838,longitude:23.7275),
        PresetCity(nameZH:"萨格勒布",nameEN:"Zagreb",adminAreaZH:"萨格勒布",adminAreaEN:"Zagreb",country:"HR",countryZH:"克罗地亚",latitude:45.8150,longitude:15.9819),
        PresetCity(nameZH:"基辅",nameEN:"Kyiv",adminAreaZH:"基辅",adminAreaEN:"Kyiv",country:"UA",countryZH:"乌克兰",latitude:50.4501,longitude:30.5234),
        // 南欧
        PresetCity(nameZH:"里斯本",nameEN:"Lisbon",adminAreaZH:"里斯本",adminAreaEN:"Lisbon",country:"PT",countryZH:"葡萄牙",latitude:38.7223,longitude:-9.1393),
        PresetCity(nameZH:"波尔图",nameEN:"Porto",adminAreaZH:"波尔图",adminAreaEN:"Porto",country:"PT",countryZH:"葡萄牙",latitude:41.1579,longitude:-8.6291),
        PresetCity(nameZH:"都柏林",nameEN:"Dublin",adminAreaZH:"都柏林",adminAreaEN:"Dublin",country:"IE",countryZH:"爱尔兰",latitude:53.3498,longitude:-6.2603),
        PresetCity(nameZH:"雷克雅未克",nameEN:"Reykjavik",adminAreaZH:"雷克雅未克",adminAreaEN:"Reykjavik",country:"IS",countryZH:"冰岛",latitude:64.1466,longitude:-21.9426),
    ]

    // MARK: - 大洋洲

    static let oceania: [PresetCity] = [
        // 澳大利亚 (6 states + 2 territories)
        PresetCity(nameZH:"悉尼",nameEN:"Sydney",adminAreaZH:"新南威尔士州",adminAreaEN:"New South Wales",country:"AU",countryZH:"澳大利亚",latitude:-33.8688,longitude:151.2093),
        PresetCity(nameZH:"墨尔本",nameEN:"Melbourne",adminAreaZH:"维多利亚州",adminAreaEN:"Victoria",country:"AU",countryZH:"澳大利亚",latitude:-37.8136,longitude:144.9631),
        PresetCity(nameZH:"布里斯班",nameEN:"Brisbane",adminAreaZH:"昆士兰州",adminAreaEN:"Queensland",country:"AU",countryZH:"澳大利亚",latitude:-27.4698,longitude:153.0251),
        PresetCity(nameZH:"珀斯",nameEN:"Perth",adminAreaZH:"西澳大利亚州",adminAreaEN:"Western Australia",country:"AU",countryZH:"澳大利亚",latitude:-31.9505,longitude:115.8605),
        PresetCity(nameZH:"阿德莱德",nameEN:"Adelaide",adminAreaZH:"南澳大利亚州",adminAreaEN:"South Australia",country:"AU",countryZH:"澳大利亚",latitude:-34.9285,longitude:138.6007),
        PresetCity(nameZH:"霍巴特",nameEN:"Hobart",adminAreaZH:"塔斯马尼亚州",adminAreaEN:"Tasmania",country:"AU",countryZH:"澳大利亚",latitude:-42.8821,longitude:147.3272),
        PresetCity(nameZH:"达尔文",nameEN:"Darwin",adminAreaZH:"北领地",adminAreaEN:"Northern Territory",country:"AU",countryZH:"澳大利亚",latitude:-12.4634,longitude:130.8456),
        PresetCity(nameZH:"堪培拉",nameEN:"Canberra",adminAreaZH:"首都领地",adminAreaEN:"Australian Capital Territory",country:"AU",countryZH:"澳大利亚",latitude:-35.2809,longitude:149.1300),
        PresetCity(nameZH:"黄金海岸",nameEN:"Gold Coast",adminAreaZH:"昆士兰州",adminAreaEN:"Queensland",country:"AU",countryZH:"澳大利亚",latitude:-28.0167,longitude:153.4000),
        // 新西兰
        PresetCity(nameZH:"奥克兰",nameEN:"Auckland",adminAreaZH:"奥克兰",adminAreaEN:"Auckland",country:"NZ",countryZH:"新西兰",latitude:-36.8509,longitude:174.7645),
        PresetCity(nameZH:"惠灵顿",nameEN:"Wellington",adminAreaZH:"惠灵顿",adminAreaEN:"Wellington",country:"NZ",countryZH:"新西兰",latitude:-41.2865,longitude:174.7762),
        PresetCity(nameZH:"基督城",nameEN:"Christchurch",adminAreaZH:"坎特伯雷",adminAreaEN:"Canterbury",country:"NZ",countryZH:"新西兰",latitude:-43.5320,longitude:172.6306),
        PresetCity(nameZH:"皇后镇",nameEN:"Queenstown",adminAreaZH:"奥塔哥",adminAreaEN:"Otago",country:"NZ",countryZH:"新西兰",latitude:-45.0312,longitude:168.6626),
        // 斐济
        PresetCity(nameZH:"苏瓦",nameEN:"Suva",adminAreaZH:"苏瓦",adminAreaEN:"Suva",country:"FJ",countryZH:"斐济",latitude:-18.1416,longitude:178.4419),
    ]

    // MARK: - 南美

    static let southAmerica: [PresetCity] = [
        // 巴西 (26 states + DF)
        PresetCity(nameZH:"圣保罗",nameEN:"São Paulo",adminAreaZH:"圣保罗州",adminAreaEN:"São Paulo",country:"BR",countryZH:"巴西",latitude:-23.5505,longitude:-46.6333),
        PresetCity(nameZH:"里约热内卢",nameEN:"Rio de Janeiro",adminAreaZH:"里约热内卢州",adminAreaEN:"Rio de Janeiro",country:"BR",countryZH:"巴西",latitude:-22.9068,longitude:-43.1729),
        PresetCity(nameZH:"巴西利亚",nameEN:"Brasilia",adminAreaZH:"联邦区",adminAreaEN:"Federal District",country:"BR",countryZH:"巴西",latitude:-15.7939,longitude:-47.8828),
        PresetCity(nameZH:"萨尔瓦多",nameEN:"Salvador",adminAreaZH:"巴伊亚州",adminAreaEN:"Bahia",country:"BR",countryZH:"巴西",latitude:-12.9718,longitude:-38.5011),
        PresetCity(nameZH:"福塔萊萨",nameEN:"Fortaleza",adminAreaZH:"塞阿拉州",adminAreaEN:"Ceará",country:"BR",countryZH:"巴西",latitude:-3.7172,longitude:-38.5434),
        PresetCity(nameZH:"贝洛奥里藏特",nameEN:"Belo Horizonte",adminAreaZH:"米纳斯吉拉斯州",adminAreaEN:"Minas Gerais",country:"BR",countryZH:"巴西",latitude:-19.9167,longitude:-43.9345),
        PresetCity(nameZH:"马瑙斯",nameEN:"Manaus",adminAreaZH:"亚马孙州",adminAreaEN:"Amazonas",country:"BR",countryZH:"巴西",latitude:-3.1190,longitude:-60.0217),
        PresetCity(nameZH:"库里蒂巴",nameEN:"Curitiba",adminAreaZH:"巴拉那州",adminAreaEN:"Paraná",country:"BR",countryZH:"巴西",latitude:-25.4290,longitude:-49.2671),
        PresetCity(nameZH:"累西腓",nameEN:"Recife",adminAreaZH:"伯南布哥州",adminAreaEN:"Pernambuco",country:"BR",countryZH:"巴西",latitude:-8.0476,longitude:-34.8770),
        PresetCity(nameZH:"阿雷格里港",nameEN:"Porto Alegre",adminAreaZH:"南里奥格兰德州",adminAreaEN:"Rio Grande do Sul",country:"BR",countryZH:"巴西",latitude:-30.0346,longitude:-51.2177),
        // 阿根廷
        PresetCity(nameZH:"布宜诺斯艾利斯",nameEN:"Buenos Aires",adminAreaZH:"布宜诺斯艾利斯",adminAreaEN:"Buenos Aires",country:"AR",countryZH:"阿根廷",latitude:-34.6037,longitude:-58.3816),
        PresetCity(nameZH:"科尔多瓦",nameEN:"Córdoba",adminAreaZH:"科尔多瓦省",adminAreaEN:"Córdoba",country:"AR",countryZH:"阿根廷",latitude:-31.4201,longitude:-64.1888),
        PresetCity(nameZH:"门多萨",nameEN:"Mendoza",adminAreaZH:"门多萨省",adminAreaEN:"Mendoza",country:"AR",countryZH:"阿根廷",latitude:-32.8895,longitude:-68.8458),
        // 智利
        PresetCity(nameZH:"圣地亚哥",nameEN:"Santiago",adminAreaZH:"圣地亚哥",adminAreaEN:"Santiago",country:"CL",countryZH:"智利",latitude:-33.4489,longitude:-70.6693),
        // 秘鲁
        PresetCity(nameZH:"利马",nameEN:"Lima",adminAreaZH:"利马",adminAreaEN:"Lima",country:"PE",countryZH:"秘鲁",latitude:-12.0464,longitude:-77.0428),
        PresetCity(nameZH:"库斯科",nameEN:"Cusco",adminAreaZH:"库斯科",adminAreaEN:"Cusco",country:"PE",countryZH:"秘鲁",latitude:-13.5320,longitude:-71.9675),
        // 哥伦比亚
        PresetCity(nameZH:"波哥大",nameEN:"Bogotá",adminAreaZH:"波哥大",adminAreaEN:"Bogotá",country:"CO",countryZH:"哥伦比亚",latitude:4.7110,longitude:-74.0721),
        PresetCity(nameZH:"麦德林",nameEN:"Medellín",adminAreaZH:"安蒂奥基亚",adminAreaEN:"Antioquia",country:"CO",countryZH:"哥伦比亚",latitude:6.2476,longitude:-75.5658),
        // 委内瑞拉
        PresetCity(nameZH:"加拉加斯",nameEN:"Caracas",adminAreaZH:"加拉加斯",adminAreaEN:"Caracas",country:"VE",countryZH:"委内瑞拉",latitude:10.4806,longitude:-66.9036),
        // 厄瓜多尔
        PresetCity(nameZH:"基多",nameEN:"Quito",adminAreaZH:"基多",adminAreaEN:"Quito",country:"EC",countryZH:"厄瓜多尔",latitude:-0.1807,longitude:-78.4678),
        // 乌拉圭
        PresetCity(nameZH:"蒙得维的亚",nameEN:"Montevideo",adminAreaZH:"蒙得维的亚",adminAreaEN:"Montevideo",country:"UY",countryZH:"乌拉圭",latitude:-34.9011,longitude:-56.1645),
    ]

    // MARK: - 非洲

    static let africa: [PresetCity] = [
        // 南非 (9 provinces)
        PresetCity(nameZH:"开普敦",nameEN:"Cape Town",adminAreaZH:"西开普省",adminAreaEN:"Western Cape",country:"ZA",countryZH:"南非",latitude:-33.9249,longitude:18.4241),
        PresetCity(nameZH:"约翰内斯堡",nameEN:"Johannesburg",adminAreaZH:"豪登省",adminAreaEN:"Gauteng",country:"ZA",countryZH:"南非",latitude:-26.2041,longitude:28.0473),
        PresetCity(nameZH:"比勒陀利亚",nameEN:"Pretoria",adminAreaZH:"豪登省",adminAreaEN:"Gauteng",country:"ZA",countryZH:"南非",latitude:-25.7479,longitude:28.2293),
        PresetCity(nameZH:"德班",nameEN:"Durban",adminAreaZH:"夸祖鲁-纳塔尔省",adminAreaEN:"KwaZulu-Natal",country:"ZA",countryZH:"南非",latitude:-29.8587,longitude:31.0218),
        // 尼日利亚
        PresetCity(nameZH:"拉各斯",nameEN:"Lagos",adminAreaZH:"拉各斯",adminAreaEN:"Lagos",country:"NG",countryZH:"尼日利亚",latitude:6.5244,longitude:3.3792),
        PresetCity(nameZH:"阿布贾",nameEN:"Abuja",adminAreaZH:"阿布贾",adminAreaEN:"Abuja",country:"NG",countryZH:"尼日利亚",latitude:9.0765,longitude:7.3986),
        // 肯尼亚
        PresetCity(nameZH:"内罗毕",nameEN:"Nairobi",adminAreaZH:"内罗毕",adminAreaEN:"Nairobi",country:"KE",countryZH:"肯尼亚",latitude:-1.2921,longitude:36.8219),
        PresetCity(nameZH:"蒙巴萨",nameEN:"Mombasa",adminAreaZH:"蒙巴萨",adminAreaEN:"Mombasa",country:"KE",countryZH:"肯尼亚",latitude:-4.0435,longitude:39.6682),
        // 埃及
        PresetCity(nameZH:"开罗",nameEN:"Cairo",adminAreaZH:"开罗",adminAreaEN:"Cairo",country:"EG",countryZH:"埃及",latitude:30.0444,longitude:31.2357),
        PresetCity(nameZH:"亚历山大",nameEN:"Alexandria",adminAreaZH:"亚历山大",adminAreaEN:"Alexandria",country:"EG",countryZH:"埃及",latitude:31.2001,longitude:29.9187),
        // 摩洛哥
        PresetCity(nameZH:"卡萨布兰卡",nameEN:"Casablanca",adminAreaZH:"卡萨布兰卡",adminAreaEN:"Casablanca",country:"MA",countryZH:"摩洛哥",latitude:33.5731,longitude:-7.5898),
        PresetCity(nameZH:"马拉喀什",nameEN:"Marrakech",adminAreaZH:"马拉喀什",adminAreaEN:"Marrakech",country:"MA",countryZH:"摩洛哥",latitude:31.6295,longitude:-7.9811),
        // 埃塞俄比亚
        PresetCity(nameZH:"亚的斯亚贝巴",nameEN:"Addis Ababa",adminAreaZH:"亚的斯亚贝巴",adminAreaEN:"Addis Ababa",country:"ET",countryZH:"埃塞俄比亚",latitude:9.0320,longitude:38.7469),
        // 坦桑尼亚
        PresetCity(nameZH:"达累斯萨拉姆",nameEN:"Dar es Salaam",adminAreaZH:"达累斯萨拉姆",adminAreaEN:"Dar es Salaam",country:"TZ",countryZH:"坦桑尼亚",latitude:-6.7924,longitude:39.2083),
        // 加纳
        PresetCity(nameZH:"阿克拉",nameEN:"Accra",adminAreaZH:"大阿克拉",adminAreaEN:"Greater Accra",country:"GH",countryZH:"加纳",latitude:5.6037,longitude:-0.1870),
        // 阿尔及利亚
        PresetCity(nameZH:"阿尔及尔",nameEN:"Algiers",adminAreaZH:"阿尔及尔",adminAreaEN:"Algiers",country:"DZ",countryZH:"阿尔及利亚",latitude:36.7538,longitude:3.0588),
        // 塞内加尔
        PresetCity(nameZH:"达喀尔",nameEN:"Dakar",adminAreaZH:"达喀尔",adminAreaEN:"Dakar",country:"SN",countryZH:"塞内加尔",latitude:14.7167,longitude:-17.4677),
    ]

    // MARK: - 中东

    static let middleEast: [PresetCity] = [
        // 阿联酋
        PresetCity(nameZH:"迪拜",nameEN:"Dubai",adminAreaZH:"迪拜",adminAreaEN:"Dubai",country:"AE",countryZH:"阿联酋",latitude:25.2048,longitude:55.2708),
        PresetCity(nameZH:"阿布扎比",nameEN:"Abu Dhabi",adminAreaZH:"阿布扎比",adminAreaEN:"Abu Dhabi",country:"AE",countryZH:"阿联酋",latitude:24.4539,longitude:54.3773),
        PresetCity(nameZH:"沙迦",nameEN:"Sharjah",adminAreaZH:"沙迦",adminAreaEN:"Sharjah",country:"AE",countryZH:"阿联酋",latitude:25.3223,longitude:55.5136),
        // 卡塔尔
        PresetCity(nameZH:"多哈",nameEN:"Doha",adminAreaZH:"多哈",adminAreaEN:"Doha",country:"QA",countryZH:"卡塔尔",latitude:25.2854,longitude:51.5310),
        // 沙特阿拉伯
        PresetCity(nameZH:"利雅得",nameEN:"Riyadh",adminAreaZH:"利雅得",adminAreaEN:"Riyadh",country:"SA",countryZH:"沙特",latitude:24.7136,longitude:46.6753),
        PresetCity(nameZH:"吉达",nameEN:"Jeddah",adminAreaZH:"麦加",adminAreaEN:"Mecca",country:"SA",countryZH:"沙特",latitude:21.4858,longitude:39.1925),
        // 以色列
        PresetCity(nameZH:"特拉维夫",nameEN:"Tel Aviv",adminAreaZH:"特拉维夫",adminAreaEN:"Tel Aviv",country:"IL",countryZH:"以色列",latitude:32.0853,longitude:34.7818),
        PresetCity(nameZH:"耶路撒冷",nameEN:"Jerusalem",adminAreaZH:"耶路撒冷",adminAreaEN:"Jerusalem",country:"IL",countryZH:"以色列",latitude:31.7683,longitude:35.2137),
        // 伊朗
        PresetCity(nameZH:"德黑兰",nameEN:"Tehran",adminAreaZH:"德黑兰",adminAreaEN:"Tehran",country:"IR",countryZH:"伊朗",latitude:35.6892,longitude:51.3890),
        // 伊拉克
        PresetCity(nameZH:"巴格达",nameEN:"Baghdad",adminAreaZH:"巴格达",adminAreaEN:"Baghdad",country:"IQ",countryZH:"伊拉克",latitude:33.3152,longitude:44.3661),
        // 约旦
        PresetCity(nameZH:"安曼",nameEN:"Amman",adminAreaZH:"安曼",adminAreaEN:"Amman",country:"JO",countryZH:"约旦",latitude:31.9454,longitude:35.9284),
        // 黎巴嫩
        PresetCity(nameZH:"贝鲁特",nameEN:"Beirut",adminAreaZH:"贝鲁特",adminAreaEN:"Beirut",country:"LB",countryZH:"黎巴嫩",latitude:33.8938,longitude:35.5018),
        // 科威特
        PresetCity(nameZH:"科威特城",nameEN:"Kuwait City",adminAreaZH:"科威特城",adminAreaEN:"Kuwait City",country:"KW",countryZH:"科威特",latitude:29.3759,longitude:47.9774),
        // 阿曼
        PresetCity(nameZH:"马斯喀特",nameEN:"Muscat",adminAreaZH:"马斯喀特",adminAreaEN:"Muscat",country:"OM",countryZH:"阿曼",latitude:23.5880,longitude:58.3829),
        // 巴林
        PresetCity(nameZH:"麦纳麦",nameEN:"Manama",adminAreaZH:"麦纳麦",adminAreaEN:"Manama",country:"BH",countryZH:"巴林",latitude:26.2235,longitude:50.5876),
    ]
}

func countryDisplayName(_ code: String) -> String {
    switch code {
    case "CN": "China"; case "JP": "Japan"; case "KR": "South Korea"; case "KP": "North Korea"
    case "SG": "Singapore"; case "TH": "Thailand"; case "MY": "Malaysia"; case "ID": "Indonesia"
    case "PH": "Philippines"; case "VN": "Vietnam"; case "MM": "Myanmar"; case "KH": "Cambodia"
    case "LA": "Laos"; case "BN": "Brunei"; case "TL": "Timor-Leste"
    case "IN": "India"; case "PK": "Pakistan"; case "BD": "Bangladesh"; case "LK": "Sri Lanka"
    case "NP": "Nepal"; case "BT": "Bhutan"; case "MV": "Maldives"
    case "US": "USA"; case "CA": "Canada"; case "MX": "Mexico"
    case "GB": "UK"; case "FR": "France"; case "DE": "Germany"; case "IT": "Italy"
    case "ES": "Spain"; case "RU": "Russia"; case "TR": "Turkey"; case "NL": "Netherlands"
    case "BE": "Belgium"; case "CH": "Switzerland"; case "AT": "Austria"
    case "SE": "Sweden"; case "NO": "Norway"; case "DK": "Denmark"; case "FI": "Finland"
    case "PL": "Poland"; case "CZ": "Czechia"; case "HU": "Hungary"; case "RO": "Romania"
    case "BG": "Bulgaria"; case "GR": "Greece"; case "HR": "Croatia"; case "UA": "Ukraine"
    case "PT": "Portugal"; case "IE": "Ireland"; case "IS": "Iceland"
    case "AU": "Australia"; case "NZ": "New Zealand"; case "FJ": "Fiji"
    case "BR": "Brazil"; case "AR": "Argentina"; case "CL": "Chile"; case "PE": "Peru"
    case "CO": "Colombia"; case "VE": "Venezuela"; case "EC": "Ecuador"; case "UY": "Uruguay"
    case "ZA": "South Africa"; case "NG": "Nigeria"; case "KE": "Kenya"
    case "EG": "Egypt"; case "MA": "Morocco"; case "ET": "Ethiopia"
    case "TZ": "Tanzania"; case "GH": "Ghana"; case "DZ": "Algeria"; case "SN": "Senegal"
    case "AE": "UAE"; case "QA": "Qatar"; case "SA": "Saudi Arabia"
    case "IL": "Israel"; case "IR": "Iran"; case "IQ": "Iraq"
    case "JO": "Jordan"; case "LB": "Lebanon"; case "KW": "Kuwait"
    case "OM": "Oman"; case "BH": "Bahrain"
    default: code
    }
}

// MARK: - Country Group Helper

struct CountryGroup: Identifiable {
    let code: String; let flag: String; let nameZH: String; let nameEN: String; let cities: [Location]
    var id: String { code }
}
