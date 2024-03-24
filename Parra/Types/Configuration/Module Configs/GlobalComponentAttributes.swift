//
//  GlobalComponentAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// A place to provide global defaults for basic styles of Parra components,
/// given contextual information about where they will be used.
public final class GlobalComponentAttributes: ParraConfigurationOptionType {
    // MARK: - Lifecycle

    public init(
        labelAttributeFactory: LabelAttributeFactory? = nil,
        textButtonAttributeFactory: TextButtonAttributeFactory? = nil,
        imageButtonAttributeFactory: ImageButtonAttributeFactory? = nil,
        menuAttributeFactory: MenuAttributeFactory? = nil,
        textEditorAttributeFactory: TextEditorAttributeFactory? = nil,
        textInputAttributeFactory: TextInputAttributeFactory? = nil,
        segmentAttributeFactory: SegmentAttributeFactory? = nil,
        alertAttributeFactory: AlertAttributeFactory? = nil,
        emptyStateAttributeFactory: EmptyStateAttributeFactory? = nil
    ) {
        self.labelAttributeFactory = labelAttributeFactory
        self.textButtonAttributeFactory = textButtonAttributeFactory
        self.imageButtonAttributeFactory = imageButtonAttributeFactory
        self.menuAttributeFactory = menuAttributeFactory
        self.textEditorAttributeFactory = textEditorAttributeFactory
        self.textInputAttributeFactory = textInputAttributeFactory
        self.segmentAttributeFactory = segmentAttributeFactory
        self.alertAttributeFactory = alertAttributeFactory
        self.emptyStateAttributeFactory = emptyStateAttributeFactory
    }

    // MARK: - Public

    public typealias LabelAttributeFactory = (
        _ config: LabelConfig,
        _ content: LabelContent,
        _ defaultAttributes: LabelAttributes?
    ) -> LabelAttributes

    public typealias TextButtonAttributeFactory = (
        _ config: TextButtonConfig,
        _ content: TextButtonContent,
        _ defaultAttributes: TextButtonAttributes?
    ) -> TextButtonAttributes

    public typealias ImageButtonAttributeFactory = (
        _ config: ImageButtonConfig,
        _ content: ImageButtonContent,
        _ defaultAttributes: ImageButtonAttributes?
    ) -> ImageButtonAttributes

    public typealias MenuAttributeFactory = (
        _ config: MenuConfig,
        _ content: MenuContent,
        _ defaultAttributes: MenuAttributes?
    ) -> MenuAttributes

    public typealias TextEditorAttributeFactory = (
        _ config: TextEditorConfig,
        _ content: TextEditorContent,
        _ defaultAttributes: TextEditorAttributes?
    ) -> TextEditorAttributes

    public typealias TextInputAttributeFactory = (
        _ config: TextInputConfig,
        _ content: TextInputContent,
        _ defaultAttributes: TextInputAttributes?
    ) -> TextInputAttributes

    public typealias SegmentAttributeFactory = (
        _ config: SegmentConfig,
        _ content: SegmentContent,
        _ defaultAttributes: SegmentAttributes?
    ) -> SegmentAttributes

    public typealias AlertAttributeFactory = (
        _ config: AlertConfig,
        _ content: AlertContent,
        _ defaultAttributes: AlertAttributes?
    ) -> AlertAttributes

    public typealias EmptyStateAttributeFactory = (
        _ config: EmptyStateConfig,
        _ content: EmptyStateContent,
        _ defaultAttributes: EmptyStateAttributes?
    ) -> EmptyStateAttributes

    public static var `default`: GlobalComponentAttributes = .init()

    // MARK: - Internal

    private(set) var labelAttributeFactory: LabelAttributeFactory?
    private(set) var textButtonAttributeFactory: TextButtonAttributeFactory?
    private(set) var imageButtonAttributeFactory: ImageButtonAttributeFactory?
    private(set) var menuAttributeFactory: MenuAttributeFactory?
    private(set) var textEditorAttributeFactory: TextEditorAttributeFactory?
    private(set) var textInputAttributeFactory: TextInputAttributeFactory?
    private(set) var segmentAttributeFactory: SegmentAttributeFactory?
    private(set) var alertAttributeFactory: AlertAttributeFactory?
    private(set) var emptyStateAttributeFactory: EmptyStateAttributeFactory?
}
