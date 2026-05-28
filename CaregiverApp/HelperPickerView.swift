//
//  HelperPickerView.swift
//  CaregiverApp
//

import SwiftUI

struct HelperPickerView: View {

    @Environment(\.dismiss) private var dismiss

    let availableHelpers: [Helper]

    let onSelect: (Helper) -> Void

    var body: some View {
        NavigationStack {

            List(availableHelpers) { helper in

                Button {
                    onSelect(helper)
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {

                        Text(helper.name)

                        Text(helper.phoneNumber)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Select Helper")
        }

    }

}
