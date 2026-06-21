import SwiftUI

extension Color {
    init(hex: String) {
        let clean = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        let scanner = Scanner(string: clean)
        if !(scanner.scanHexInt64(&value) && scanner.isAtEnd) {
            value = 0xFFFFFF
        }

        let red, green, blue: UInt64
        switch clean.count {
        case 6:
            red = (value >> 16) & 0xFF
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
        default:
            red = 255
            green = 255
            blue = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }
}
