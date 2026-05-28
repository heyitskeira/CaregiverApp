//
//  CustomRepeatView.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 28/05/26.
//

import SwiftUI

struct CustomRepeatView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var repeatInterval: Int
    @Binding var repeatUnit: RepeatUnit

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                Picker(
                    "Number",
                    selection: $repeatInterval
                ) {
                    ForEach(1..<100) { number in
                        Text("\(number)")
                            .tag(number)
                    }
                }
                .pickerStyle(.wheel)

                Picker(
                    "Unit",
                    selection: $repeatUnit
                ) {
                    ForEach(
                        RepeatUnit.allCases,
                        id: \.self
                    ) { unit in
                        Text(unit.rawValue)
                            .tag(unit)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Custom Repeat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
