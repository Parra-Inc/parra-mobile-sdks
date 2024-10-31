//
//  API+userSettings.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import Combine
import Foundation

extension API {
    func getSettingsLayouts() async throws -> [ParraUserSettingsLayout] {
        return try await hitEndpoint(
            .getUserSettingsLayouts,
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData)
        )
    }

    func getSettingsLayout(
        layoutId: String
    ) async throws -> ParraUserSettingsLayout {
        return try await hitEndpoint(
            .getUserSettingsLayout(layoutId: layoutId),
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData)
        )
    }

    func updateSettingValuePublisher(
        for settingIdOrKey: String,
        with newValue: ParraSettingsItemDataWithValue
    ) -> AnyPublisher<ParraSettingsItemDataWithValue, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let result = try await self.updateSettingValue(
                            for: settingIdOrKey,
                            with: newValue
                        )

                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func updateSettingValue(
        for settingIdOrKey: String,
        with newValue: ParraSettingsItemDataWithValue
    ) async throws -> ParraSettingsItemDataWithValue {
        var body: [String: ParraAnyCodable] = [:]

        switch newValue {
        case .settingsItemIntegerDataWithValue(let data):
            if let value = data.value {
                body["value"] = ParraAnyCodable(value)
            }
        case .settingsItemStringDataWithValue(let data):
            if let value = data.value {
                body["value"] = ParraAnyCodable(value)
            }
        case .settingsItemBooleanDataWithValue(let data):
            if let value = data.value {
                body["value"] = ParraAnyCodable(value)
            }
        }

        let result: [String: ParraAnyCodable] = try await hitEndpoint(
            .putUpdateUserSetting(settingsItemId: settingIdOrKey),
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData),
            body: body
        )

        var updatedValue = newValue

        switch newValue {
        case .settingsItemIntegerDataWithValue(let data):
            updatedValue = .settingsItemIntegerDataWithValue(
                ParraSettingsItemIntegerDataWithValue(
                    defaultValue: data.defaultValue,
                    minValue: data.minValue,
                    maxValue: data.maxValue,
                    value: result["value"]?.value as? Int
                )
            )
        case .settingsItemStringDataWithValue(let data):
            updatedValue = .settingsItemStringDataWithValue(
                ParraSettingsItemStringDataWithValue(
                    format: data.format,
                    enumOptions: data.enumOptions,
                    defaultValue: data.defaultValue,
                    value: result["value"]?.value as? String
                )
            )
        case .settingsItemBooleanDataWithValue(let data):
            updatedValue = .settingsItemBooleanDataWithValue(
                ParraSettingsItemBooleanDataWithValue(
                    format: data.format,
                    trueLabel: data.trueLabel,
                    falseLabel: data.falseLabel,
                    defaultValue: data.defaultValue,
                    value: result["value"]?.value as? Bool
                )
            )
        }

        return updatedValue
    }
}
