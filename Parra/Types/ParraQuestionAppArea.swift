//
//  ParraQuestionAppArea.swift
//  Parra
//
//  Created by Mick MacCallum on 10/11/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraQuestionAppArea {
    case all
    case none
    case id(String)

    public var parameterized: String? {
        switch self {
        case .all:
            return nil
        case .none:
            return "null"
        case .id(let appAreaId):
            return appAreaId
        }
    }
}
