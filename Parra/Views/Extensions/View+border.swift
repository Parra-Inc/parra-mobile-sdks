//
//  View+border.swift
//  Parra
//
//  Created by Mick MacCallum on 2/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: Edge.Set

    func path(in rect: CGRect) -> Path {
        let path = Path()

        if edges.isEmpty {
            return path
        }

        var pathComponents = [Path]()

        if edges.contains(.top) || edges.contains(.vertical) || edges
            .contains(.all)
        {
            pathComponents.append(
                Path(
                    CGRect(
                        x: rect.minX,
                        y: rect.minY,
                        width: rect.width,
                        height: width
                    )
                )
            )
        }

        if edges.contains(.bottom) || edges.contains(.vertical) || edges
            .contains(.all)
        {
            pathComponents.append(
                Path(
                    CGRect(
                        x: rect.minX,
                        y: rect.maxY - width,
                        width: rect.width,
                        height: width
                    )
                )
            )
        }

        if edges.contains(.leading) || edges.contains(.horizontal) || edges
            .contains(.all)
        {
            pathComponents.append(
                Path(
                    CGRect(
                        x: rect.minX,
                        y: rect.minY,
                        width: width,
                        height: rect.height
                    )
                )
            )
        }

        if edges.contains(.trailing) || edges.contains(.horizontal) || edges
            .contains(.all)
        {
            pathComponents.append(
                Path(
                    CGRect(
                        x: rect.maxX - width,
                        y: rect.minY,
                        width: width,
                        height: rect.height
                    )
                )
            )
        }

        return pathComponents.reduce(into: path) {
            $0.addPath($1)
        }
    }
}

extension View {
    func border(
        width: CGFloat,
        edges: Edge.Set,
        color: Color
    ) -> some View {
        overlay(
            EdgeBorder(
                width: width,
                edges: edges
            )
            .foregroundColor(color)
        )
    }
}
