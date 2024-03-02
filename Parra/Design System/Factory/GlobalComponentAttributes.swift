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
public class GlobalComponentAttributes {
    // MARK: - Lifecycle

    public init(
        labelAttributeFactory: LabelAttributeFactory? = nil,
        buttonAttributeFactory: ButtonAttributeFactory? = nil,
        menuAttributeFactory: MenuAttributeFactory? = nil,
        textEditorAttributeFactory: TextEditorAttributeFactory? = nil,
        textInputAttributeFactory: TextInputAttributeFactory? = nil,
        segmentAttributeFactory: SegmentAttributeFactory? = nil
    ) {
        self.labelAttributeFactory = labelAttributeFactory
        self.buttonAttributeFactory = buttonAttributeFactory
        self.menuAttributeFactory = menuAttributeFactory
        self.textEditorAttributeFactory = textEditorAttributeFactory
        self.textInputAttributeFactory = textInputAttributeFactory
        self.segmentAttributeFactory = segmentAttributeFactory
    }

    // MARK: - Public

    public typealias LabelAttributeFactory = (
        _ config: LabelConfig,
        _ content: LabelContent,
        _ defaultAttributes: LabelAttributes?
    ) -> LabelAttributes

    public typealias ButtonAttributeFactory = (
        _ config: ButtonConfig,
        _ content: ButtonContent,
        _ defaultAttributes: ButtonAttributes?
    ) -> ButtonAttributes

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

    // MARK: - Internal

    private(set) var labelAttributeFactory: LabelAttributeFactory?
    private(set) var buttonAttributeFactory: ButtonAttributeFactory?
    private(set) var menuAttributeFactory: MenuAttributeFactory?
    private(set) var textEditorAttributeFactory: TextEditorAttributeFactory?
    private(set) var textInputAttributeFactory: TextInputAttributeFactory?
    private(set) var segmentAttributeFactory: SegmentAttributeFactory?
}
