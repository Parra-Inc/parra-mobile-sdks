//
//  ParraGlobalComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

///
/// 1. Stores global defaults for component configs
/// 2. Stores references to component factory functions
/// 3. Creates and returns components given 1, 2 and local overrides passed to builder methods.
///
public class ParraGlobalComponentFactory {
    /// A map between ``ParraComponentType`` and factory functions that the user provided to generate
    /// components of the same type. This dictionary is accessed to check if a factory exists for a given component
    /// type and if an entry is present, use it as the base in builder functions.
    private var userComponentFactories: [ParraComponentType : ParraUserFactoryFunctionWrapperType] = [:]

    public init() {}

    internal func userComponentFactory(for componentType: ParraComponentType) -> ParraUserFactoryFunctionWrapperType? {
        return userComponentFactories[componentType]
    }

    // MARK: - Global Component Registration

    public func registerDefaultViewComponent(
        factory: @escaping (_ config: ParraViewConfig) -> any View
    ) {
        registerComponentFactory(
            for: .view,
            factoryWrapper: ParraUserFactoryFunctionWrapper(
                type: ParraViewConfig.self,
                function: factory
            )
        )
    }

    public func registerDefaultLabelComponent(
        factory: @escaping (_ config: ParraLabelViewConfig) -> any View
    ) {
        registerComponentFactory(
            for: .label,
            factoryWrapper: ParraUserFactoryFunctionWrapper(
                type: ParraLabelViewConfig.self,
                function: factory
            )
        )
    }

    public func registerDefaultPlainButtonComponent(
        factory: @escaping (_ config: ParraButtonViewConfig) -> any View
    ) {
        registerComponentFactory(
            for: .plainButton,
            factoryWrapper: ParraUserFactoryFunctionWrapper(
                type: ParraButtonViewConfig.self,
                function: factory
            )
        )
    }

    public func registerDefaultOutlinedButtonComponent(
        factory: @escaping (_ config: ParraButtonViewConfig) -> any View
    ) {
        registerComponentFactory(
            for: .outlinedButton,
            factoryWrapper: ParraUserFactoryFunctionWrapper(
                type: ParraButtonViewConfig.self,
                function: factory
            )
        )
    }

    public func registerDefaultContainedButtonComponent(
        factory: @escaping (_ config: ParraButtonViewConfig) -> any View
    ) {
        registerComponentFactory(
            for: .containedButton,
            factoryWrapper: ParraUserFactoryFunctionWrapper(
                type: ParraButtonViewConfig.self,
                function: factory
            )
        )
    }

    internal func registerComponentFactory<T: ParraViewConfigType>(
        for type: ParraComponentType,
        factoryWrapper: ParraUserFactoryFunctionWrapper<T>
    ) {
        userComponentFactories[type] = factoryWrapper
    }
}
