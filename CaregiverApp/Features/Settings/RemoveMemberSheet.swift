//
//  RemoveMemberSheet.swift
//  CaregiverApp
//
//  Created by Dzikry Aji Santoso on 08/06/26.
//

import SwiftUI

struct RemoveMemberSheet: View {
    let contact: CareContact
    let onRemove: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 90, height: 90)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(.gray)
                }

            VStack(spacing: 4) {
                Text(contact.name)
                    .font(.title3)
                    .bold()

                Text(contact.phone)
                    .foregroundStyle(.secondary)
            }

            Button {
                onRemove()
            } label: {
                HStack {
                    Image(systemName: "trash")

                    Text("Remove from care group")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(Capsule())
            }

            Spacer()
        }
        .padding()
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        })
    }
}
