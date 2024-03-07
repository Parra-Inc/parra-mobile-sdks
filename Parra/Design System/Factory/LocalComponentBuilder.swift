//
//  LocalComponentBuilder.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum LocalComponentBuilder {
    // I don't know why, but these generic typealiases have to be nested within
    // a type. If they're top level, any callsite reports not finding them on
    // the Parra module.
    public typealias Factory<
        V: View,
        Config,
        Content,
        Attributes
    > = (
        _ config: Config,
        _ content: Content?,
        _ defaultAttributes: ParraStyleAttributes
    ) -> V?
}
