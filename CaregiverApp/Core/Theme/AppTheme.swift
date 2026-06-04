//
//  AppTheme.swift
//  CaregiverApp
//
//  Adaptive color system for light and dark mode.
//

import SwiftUI

enum AppTheme {
    // MARK: - Backgrounds
    /// Subtle warm cream in light mode, deep navy in dark mode
    static let pageBackground = Color("PageBackground")

    /// Card/surface background — white in light, dark card in dark
    static let cardBackground = Color("CardBackground")

    // MARK: - Accent Colors
    /// Primary navy accent used for buttons, filled capsules
    static let accentNavy = Color(light: Color(red: 0.09, green: 0.15, blue: 0.30),
                                   dark: Color(red: 0.53, green: 0.68, blue: 0.90))

    /// Bright blue used for the header in task sheet and checkmark
    static let accentBlue = Color(light: Color(red: 0.15, green: 0.35, blue: 0.85),
                                  dark: Color(red: 0.35, green: 0.55, blue: 0.95))

    /// Orange accent for inbox icons, badges
    static let accentOrange = Color(light: Color(red: 0.90, green: 0.55, blue: 0.25),
                                     dark: Color(red: 0.95, green: 0.65, blue: 0.35))

    /// Peach/salmon for task sheet icon background
    static let accentPeach = Color(light: Color(red: 0.93, green: 0.75, blue: 0.65),
                                    dark: Color(red: 0.85, green: 0.60, blue: 0.48))

    /// Soft green for completion
    static let accentGreen = Color(light: Color(red: 0.20, green: 0.65, blue: 0.32),
                                    dark: Color(red: 0.30, green: 0.78, blue: 0.45))

    // MARK: - Text
    static let primaryText = Color(light: .black, dark: .white)
    static let secondaryText = Color(light: Color(red: 0.55, green: 0.55, blue: 0.58),
                                      dark: Color(red: 0.62, green: 0.62, blue: 0.66))

    // MARK: - Timeline
    /// Node colors for timeline capsules
    static let completedNode = Color(light: Color(red: 0.70, green: 0.70, blue: 0.72),
                                      dark: Color(red: 0.40, green: 0.42, blue: 0.45))

    static let ongoingNode = Color(light: Color(red: 0.13, green: 0.55, blue: 0.13),
                                    dark: Color(red: 0.22, green: 0.68, blue: 0.22))

    static let assignedNode = Color(light: Color(red: 0.09, green: 0.15, blue: 0.30),
                                     dark: Color(red: 0.25, green: 0.35, blue: 0.55))

    // MARK: - Dividers & Borders
    static let divider = Color(light: Color(red: 0.88, green: 0.88, blue: 0.88),
                                dark: Color(red: 0.25, green: 0.28, blue: 0.32))

    static let trayIconBackground = Color(light: Color(red: 0.92, green: 0.92, blue: 0.94),
                                           dark: Color(red: 0.18, green: 0.22, blue: 0.30))
}

// MARK: - Color Extension for light/dark adaptive colors
extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
