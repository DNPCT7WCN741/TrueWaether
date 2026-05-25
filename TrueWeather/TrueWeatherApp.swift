import SwiftUI

// MARK: - Language & Theme

enum AppLanguage: String, CaseIterable {
    case chinese, english

    var label: String { self == .chinese ? "中" : "EN" }
    var next: AppLanguage { self == .chinese ? .english : .chinese }
}

enum ThemeMode: String, CaseIterable {
    case system, light, dark

    var label: String {
        switch self {
        case .system: "◐"
        case .light: "☀"
        case .dark: "☾"
        }
    }
    var next: ThemeMode {
        switch self {
        case .system: .light
        case .light: .dark
        case .dark: .system
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

// MARK: - App Entry

@main
struct TrueWeatherApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}
