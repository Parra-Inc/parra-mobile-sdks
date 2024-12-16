//
//  WrappingHStack.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct WrappingHStack: Layout {
    // MARK: - Lifecycle

    @inlinable
    init(
        alignment: Alignment = .center,
        horizontalSpacing: CGFloat? = nil,
        verticalSpacing: CGFloat? = nil,
        fitContentWidth: Bool = false
    ) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.fitContentWidth = fitContentWidth
    }

    // MARK: - Internal

    struct Cache {
        var minSize: CGSize
        var rows: (Int, [Row])?
    }

    static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .horizontal

        return properties
    }

    var alignment: Alignment
    var horizontalSpacing: CGFloat?
    var verticalSpacing: CGFloat?
    var fitContentWidth: Bool

    func makeCache(
        subviews: Subviews
    ) -> Cache {
        Cache(minSize: minSize(subviews: subviews))
    }

    func updateCache(
        _ cache: inout Cache,
        subviews: Subviews
    ) {
        cache.minSize = minSize(subviews: subviews)
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let rows = arrangeRows(
            proposal: proposal,
            subviews: subviews,
            cache: &cache
        )

        if rows.isEmpty {
            return cache.minSize
        }

        var width: CGFloat = rows.map(\.width).reduce(.zero) {
            max($0, $1)
        }

        if !fitContentWidth, let proposalWidth = proposal.width {
            width = max(width, proposalWidth)
        }

        var height: CGFloat = .zero
        if let lastRow = rows.last {
            height = lastRow.yOffset + lastRow.height
        }

        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let rows = arrangeRows(
            proposal: proposal,
            subviews: subviews,
            cache: &cache
        )

        let anchor = UnitPoint(alignment)

        for row in rows {
            for element in row.elements {
                let x: CGFloat = element.xOffset + anchor.x * (bounds.width - row.width)
                let y: CGFloat = row.yOffset + anchor
                    .y * (row.height - element.size.height)
                let point = CGPoint(
                    x: x + bounds.minX,
                    y: y + bounds.minY
                )

                subviews[element.index].place(
                    at: point,
                    anchor: .topLeading,
                    proposal: proposal
                )
            }
        }
    }
}

extension WrappingHStack {
    struct Row {
        var elements: [(index: Int, size: CGSize, xOffset: CGFloat)] = []
        var yOffset: CGFloat = .zero
        var width: CGFloat = .zero
        var height: CGFloat = .zero
    }

    private func arrangeRows(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> [Row] {
        if subviews.isEmpty {
            return []
        }

        if cache.minSize.width > proposal.width ?? .infinity,
           cache.minSize.height > proposal.height ?? .infinity
        {
            return []
        }

        let sizes = subviews.map { $0.sizeThatFits(proposal) }

        let hash = computeHash(proposal: proposal, sizes: sizes)
        if let (oldHash, oldRows) = cache.rows,
           oldHash == hash
        {
            return oldRows
        }

        var currentX = CGFloat.zero
        var currentRow = Row()
        var rows = [Row]()

        for index in subviews.indices {
            var spacing = CGFloat.zero
            if let previousIndex = currentRow.elements.last?.index {
                spacing = horizontalSpacing(
                    subviews[previousIndex],
                    subviews[index]
                )
            }

            let size = sizes[index]

            if currentX + size.width + spacing > proposal.width ?? .infinity,
               !currentRow.elements.isEmpty
            {
                currentRow.width = currentX
                rows.append(currentRow)
                currentRow = Row()
                spacing = .zero
                currentX = .zero
            }

            currentRow.elements.append(
                (index, sizes[index], currentX + spacing)
            )

            currentX += size.width + spacing
        }

        if !currentRow.elements.isEmpty {
            currentRow.width = currentX
            rows.append(currentRow)
        }

        var currentY = CGFloat.zero
        var previousMaxHeightIndex: Int?

        for index in rows.indices {
            let maxHeightIndex = rows[index].elements
                .max { $0.size.height < $1.size.height }!
                .index

            let size = sizes[maxHeightIndex]

            var spacing = CGFloat.zero
            if let previousMaxHeightIndex {
                spacing = verticalSpacing(
                    subviews[previousMaxHeightIndex],
                    subviews[maxHeightIndex]
                )
            }

            rows[index].yOffset = currentY + spacing
            currentY += size.height + spacing
            rows[index].height = size.height
            previousMaxHeightIndex = maxHeightIndex
        }

        cache.rows = (hash, rows)

        return rows
    }

    private func computeHash(
        proposal: ProposedViewSize,
        sizes: [CGSize]
    ) -> Int {
        let proposal = proposal.replacingUnspecifiedDimensions(
            by: .infinity
        )

        var hasher = Hasher()

        for size in [proposal] + sizes {
            hasher.combine(size.width)
            hasher.combine(size.height)
        }

        return hasher.finalize()
    }

    private func minSize(subviews: Subviews) -> CGSize {
        subviews
            .map { $0.sizeThatFits(.zero) }
            .reduce(CGSize.zero) {
                CGSize(
                    width: max($0.width, $1.width),
                    height: max($0.height, $1.height)
                )
            }
    }

    private func horizontalSpacing(
        _ lhs: LayoutSubview,
        _ rhs: LayoutSubview
    ) -> CGFloat {
        if let horizontalSpacing {
            return horizontalSpacing
        }

        return lhs.spacing.distance(
            to: rhs.spacing,
            along: .horizontal
        )
    }

    private func verticalSpacing(
        _ lhs: LayoutSubview,
        _ rhs: LayoutSubview
    ) -> CGFloat {
        if let verticalSpacing {
            return verticalSpacing
        }

        return lhs.spacing.distance(to: rhs.spacing, along: .vertical)
    }
}

private extension CGSize {
    static var infinity: Self {
        .init(width: CGFloat.infinity, height: CGFloat.infinity)
    }
}

private extension UnitPoint {
    init(_ alignment: Alignment) {
        switch alignment {
        case .leading:
            self = .leading
        case .topLeading:
            self = .topLeading
        case .top:
            self = .top
        case .topTrailing:
            self = .topTrailing
        case .trailing:
            self = .trailing
        case .bottomTrailing:
            self = .bottomTrailing
        case .bottom:
            self = .bottom
        case .bottomLeading:
            self = .bottomLeading
        default:
            self = .center
        }
    }
}
