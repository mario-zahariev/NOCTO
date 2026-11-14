import SwiftUI

extension Color {
    init(hex: String) {
        let normalized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()

        let fallback = (r: 255.0, g: 255.0, b: 255.0)

        guard !normalized.isEmpty else {
            self.init(.sRGB, red: fallback.r / 255, green: fallback.g / 255, blue: fallback.b / 255, opacity: 1)
            return
        }

        let rawValue: String
        switch normalized.count {
        case 3:
            rawValue = normalized.map { String(repeating: String($0), count: 2) }.joined()
        case 6:
            rawValue = normalized
        default:
            self.init(.sRGB, red: fallback.r / 255, green: fallback.g / 255, blue: fallback.b / 255, opacity: 1)
            return
        }

        var parsedValue: UInt64 = 0
        let scanner = Scanner(string: rawValue)
        guard scanner.scanHexInt64(&parsedValue) && scanner.isAtEnd else {
            self.init(.sRGB, red: fallback.r / 255, green: fallback.g / 255, blue: fallback.b / 255, opacity: 1)
            return
        }

        let red = (parsedValue >> 16) & 0xFF
        let green = (parsedValue >> 8) & 0xFF
        let blue = parsedValue & 0xFF

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }
}
