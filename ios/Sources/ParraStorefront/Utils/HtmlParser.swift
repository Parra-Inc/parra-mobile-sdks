//
//  HtmlParser.swift
//  Parra
//
//  Created by Mick MacCallum on 2/27/25.
//

import Foundation
import SwiftSoup

class BasicHTML {
    // MARK: - Lifecycle

    required init() {
        self.rawHTML = "Document not initialized correctly"
    }

    convenience init(rawHTML: String) {
        self.init()
        self.rawHTML = rawHTML
    }

    // MARK: - Internal

    func parse() throws {
        let doc = try SwiftSoup.parse(rawHTML)
        document = doc
        rawText = try doc.text()
    }

    func asMarkdown() throws -> String? {
        guard let document else {
            return nil
        }

        markdown = ""

        guard let body: Node = document.body() else {
            return "Document Not Initialized"
        }

        try convertNode(body)

        return markdown.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Private

    private var rawHTML: String
    private var document: Document?
    private var rawText: String = ""
    private var markdown: String = ""
    private var container: Node?
    private var hasSpacedParagraph: Bool = false

    private func convertNode(
        _ node: Node,
        parentNode: Node? = nil,
        index: Int = 0
    ) throws {
        let charSet: CharacterSet = .newlines

        switch node.nodeName() {
        case "h1", "h2", "h3", "h4", "h5", "h6":
            try convertHeadingNode(node)

            return
        case "p":
            if hasSpacedParagraph {
                markdown += "\n\n"
            } else {
                hasSpacedParagraph = true
            }
        case "br":
            if hasSpacedParagraph {
                markdown += "\n"
            } else {
                hasSpacedParagraph = true
            }
        case "a":
            markdown += "["
            try convertChildren(node)
            markdown += "]"

            let href = try node.attr("href")
            markdown += "(\(href))"

            return
        case "strong":
            markdown += "**"
            try convertChildren(node)
            markdown += "**"

            return
        case "em":
            markdown += "*"
            try convertChildren(node)
            markdown += "*"

            return
        case "code" where parentNode?.nodeName() != "pre":
            markdown += "`"
            try convertChildren(node)
            markdown += "`"

            return
        case "pre" where node.childNodeSize() >= 1:
            if hasSpacedParagraph {
                markdown += "\n\n"
            } else {
                hasSpacedParagraph = true
            }

            let codeNode = node.childNode(0)
            if codeNode.nodeName() == "code" {
                try convertCodeNode(codeNode, parentNode: node)
                return
            }
        case "figure":
            container = node
        case "span" where container?.nodeName() == "figure":

            return
        case "figcaption"
            where container?.nodeName() == "figure": // ignore these outside of a figure

            return
        case "img" where container?.nodeName() == "figure":
            try convertImageContainedInFigureNode(node)

            return
        case "img":
            try convertImageNode(node)

            return
        case "blockquote":
            try convertBlockquote(node)

            return
        case "ul", "ol":
            try convertListNode(node)

            return
        case "li":
            try convertListItemNode(
                node,
                parentNode: parentNode,
                index: index
            )

            return
        case "hr":
            // Horizontal rule conversion
            markdown += "\n---\n"
        default:
            break
        }

        try convertText(node, trimming: charSet)
        try convertChildren(node)
    }

    // MARK: -

    private func convertText(
        _ node: Node,
        trimming charSet: CharacterSet = .newlines
    ) throws {
        if node.nodeName() == "#text" && node.description != " " {
            markdown += node.description.trimmingCharacters(in: charSet)
        }
    }

    private func convertChildren(_ node: Node) throws {
        for (idx, child) in node.getChildNodes().enumerated() {
            try convertNode(child, parentNode: node, index: idx)
        }
    }

    private func convertBlockquote(_ node: Node) throws {
        markdown += "\n\n"
        markdown += "> "
        // prevent the next paragraph from appending multiple line returns
        hasSpacedParagraph = false
        try convertChildren(node)
        markdown += "\n\n"
    }

    private func convertCodeNode(_ node: Node, parentNode _: Node) throws {
        markdown += "```"

        // Try and get the language from the code block
        if let codeClass = try? node.attr("class"),
           let match = try? #/lang.*-(\w+)/#.firstMatch(in: codeClass)
        {
            // match.output.1 is equal to the second capture group.
            let language = match.output.1
            markdown += language + "\n"
        } else {
            // Add the ending newline that we need to format this correctly.
            markdown += "\n"
        }

        try convertChildren(node)

        markdown += "\n```"
    }

    private func convertHeadingNode(_ node: Node) throws {
        guard let last = node.nodeName().last else {
            return
        }
        guard let level = Int(String(last)) else {
            return
        }

        for _ in 0 ..< level {
            markdown += "#"
        }

        markdown += " "

        try convertChildren(node)

        markdown += "\n\n"
    }

    private func convertListItemNode(
        _ node: Node,
        parentNode: Node?,
        index: Int
    ) throws {
        switch parentNode?.nodeName() {
        case "ul":
            markdown += "- "
            try convertChildren(node)
            markdown += "\n"

        case "ol":
            markdown += "\(index). "
            try convertChildren(node)
            markdown += "\n"

        default: break
        }
    }

    private func convertListNode(_ node: Node) throws {
        try convertChildren(node)
        markdown += "\n"
    }

    private func convertImageNode(_ node: Node) throws {
        guard
            let src = try? node.attr("src"),
            !src.isEmpty,
            let url = url(from: src) else
        {
            return
        }

        markdown += "\n"
        markdown += "!["
        if let alt = try? node.attr("alt").trimmingCharacters(
            in: .whitespacesAndNewlines
        ), !alt.isEmpty {
            markdown += alt
        }
        markdown += "]("
        markdown += url
        markdown += ")"
        markdown += "\n"
    }

    private func convertImageContainedInFigureNode(_ node: Node) throws {
        guard
            let srcSet = try? node.attr("srcset"),
            !srcSet.isEmpty,
            let url = url(from: srcSet) else
        {
            return
        }

        markdown += "\n"
        markdown += "!["

        var didFindCaption = false
        if let container {
            for child in container.getChildNodes()
                where child.nodeName() == "figcaption"
            {
                for grandChild in child.getChildNodes() {
                    try convertText(grandChild, trimming: .whitespacesAndNewlines)
                }
                didFindCaption = true
                break
            }
        }

        if !didFindCaption, let alt = try? node.attr("alt").trimmingCharacters(
            in: .whitespacesAndNewlines
        ), !alt.isEmpty {
            markdown += alt
        }

        markdown += "]("
        markdown += url
        markdown += ")"
        markdown += "\n"
    }

    private func url(from string: String) -> String? {
        let srcSetComponents = string
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard
            let srcSize = srcSetComponents.last else
        {
            return nil
        }

        let srcSizeComponents = srcSize
            .replacingOccurrences(of: "%20", with: " ")
            .components(separatedBy: " ")

        guard
            let url = srcSizeComponents.first else
        {
            return nil
        }

        return url
    }
}
