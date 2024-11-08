//
//  AddressView.swift
//  Parra
//
//  Created by Mick MacCallum on 11/8/24.
//

import SwiftUI

struct AddressView: View {
    // MARK: - Internal

    enum AddressType {
        case same(as: String)
        case different(ParraOrderAddress)
    }

    let title: String
    let address: AddressType

    var body: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(title: title)
                .padding(.bottom, 10)

            switch address {
            case .same(let other):
                componentFactory.buildLabel(
                    text: "Same as \(other)"
                )

            case .different(let address):
                renderAddress(address)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder
    private func renderAddress(
        _ address: ParraOrderAddress
    ) -> some View {
        VStack(alignment: .leading) {
            let names = [address.firstName, address.lastName].compactMap { $0 }.joined(
                separator: " "
            ).trimmingCharacters(in: .whitespacesAndNewlines)

            if !names.isEmpty {
                componentFactory.buildLabel(
                    text: names
                )
            }

            if let component = address.address1 {
                componentFactory.buildLabel(
                    text: component
                )
            }

            if let component = address.address2 {
                componentFactory.buildLabel(
                    text: component
                )
            }

            let cityInfo = [address.city, address.postalCode].compactMap { $0 }.joined(
                separator: " "
            ).trimmingCharacters(in: .whitespacesAndNewlines)

            if !cityInfo.isEmpty {
                componentFactory.buildLabel(
                    text: cityInfo
                )
            }

            if let component = address.countryCode {
                componentFactory.buildLabel(
                    text: component
                )
            }

            if let component = address.phone {
                componentFactory.buildLabel(
                    text: component
                )
            }
        }
        .font(.body)
    }
}
