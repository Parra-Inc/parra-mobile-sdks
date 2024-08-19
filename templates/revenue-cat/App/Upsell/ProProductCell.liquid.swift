//
//  ProProductCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import SwiftUI
import Parra

struct ProProductCell: View {
    @Environment(\.parraTheme) private var parraTheme

    let title: String
    let subtitle: String
    let price: String
    let badge: String?

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                if let badge {
                    Text(badge)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(parraTheme.palette.primary.shade400)
                        .foregroundStyle(parraTheme.palette.primary.shade700)
                        .cornerRadius(8)
                }

                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(parraTheme.palette.secondaryText)
            }

            Spacer()

            Text(price)
                .font(.title3)
        }
        .padding()
        .background(parraTheme.palette.primaryBackground)
    }
}

#Preview {
    ParraAppPreview {
        VStack(spacing: 30) {
            ProProductCell(
                title: "Annual membership",
                subtitle: "$2.50 per month, billed annually.",
                price: "$29.99",
                badge: "Best value"
            )

            ProProductCell(
                title: "Monthly membership",
                subtitle: "Billed monthly",
                price: "$2.99",
                badge: nil
            )
        }
        .padding()
        .background(.gray)
    }
}
