//
//  LangsettingView.swift
//  CaregiverApp
//

import SwiftUI

struct LangsettingView: View {
    enum AppLanguage: String, CaseIterable, Identifiable {
        case english = "English"
        case indonesian = "Bahasa Indonesia"
        case dutch = "Nederlands"
        case spanish = "Español"

        var id: Self { self }

        var flag: String {
            switch self {
            case .english: "🇺🇸"
            case .indonesian: "🇮🇩"
            case .dutch: "🇳🇱"
            case .spanish: "🇪🇸"
            }
        }
    }

    @State private var selectedLanguage: AppLanguage = .english

    var body: some View {
        List {
            Section(footer: Text("Language changes take effect after restarting the app.")) {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        selectedLanguage = language
                    } label: {
                        HStack {
                            Text(language.flag)
                                .font(.title2)
                            Text(language.rawValue)
                                .foregroundStyle(Color.primary)
                            Spacer()
                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        LangsettingView()
    }
}
