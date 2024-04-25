import Foundation
import SwiftUI

extension InlineNode {
    
    func renderAttributedString(
        baseURL: URL?,
        textStyles: InlineTextStyles,
        attributes: AttributeContainer
    ) -> AttributedString {
        var renderer = AttributedStringInlineRenderer(
            baseURL: baseURL,
            textStyles: textStyles,
            attributes: attributes
        )
        renderer.render(self)
        return renderer.result.resolvingFonts()
    }
    
    func renderAttributedString(
        baseURL: URL?,
        textStyles: InlineTextStyles,
        attributes: AttributeContainer
    ) -> Text {
        var renderer = AttributedStringInlineRenderer(
            baseURL: baseURL,
            textStyles: textStyles,
            attributes: attributes
        )
        renderer.render(self)
        return renderer.renderResult
    }
}

private struct AttributedStringInlineRenderer {
    
    var renderResult = Text("")
    
    var result = AttributedString()
    
    private let baseURL: URL?
    private let textStyles: InlineTextStyles
    private var attributes: AttributeContainer
    private var shouldSkipNextWhitespace = false
    private var shouldRenderReferenceNumber = true
    
    init(baseURL: URL?, textStyles: InlineTextStyles, attributes: AttributeContainer) {
        self.baseURL = baseURL
        self.textStyles = textStyles
        self.attributes = attributes
    }
    
    mutating func render(_ inline: InlineNode) {
        switch inline {
        case .text(let content):
            self.renderText(content)
        case .softBreak:
            self.renderSoftBreak()
        case .lineBreak:
            self.renderLineBreak()
        case .code(let content):
            self.renderCode(content)
        case .html(let content):
            self.renderHTML(content)
        case .emphasis(let children):
            self.renderEmphasis(children: children)
        case .strong(let children):
            self.renderStrong(children: children)
        case .strikethrough(let children):
            self.renderStrikethrough(children: children)
        case .link(let destination, let children):
            self.renderLink(destination: destination, children: children)
        case .image(let source, let children):
            self.renderImage(source: source, children: children)
        }
    }
    
    private mutating func renderText(_ text: String) {
        
        var text = text
        
        if self.shouldSkipNextWhitespace {
            self.shouldSkipNextWhitespace = false
            text = text.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
        }
        
        if self.shouldRenderReferenceNumber {
            self.shouldRenderReferenceNumber = false
            
            // Define a regular expression pattern to match the text within 【】
            let pattern = #"【(\d+)】"#

            // Create a regular expression object
            let regex = try! NSRegularExpression(pattern: pattern, options: [])

            // Find all matches in the text
            let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
            
            if matches.isEmpty {
                self.result += .init(text, attributes: self.attributes).resolvingFonts()
                self.renderResult = self.renderResult + Text(self.result)
                return
            }

            // Extract substrings based on matches
            var substrings: [String] = []

            // Track the index to slice the text
            var index = text.startIndex

            // Add the substrings between matches
            for match in matches {
                let range = match.range
                let startIndex = text.index(text.startIndex, offsetBy: range.lowerBound)
                let endIndex = text.index(text.startIndex, offsetBy: range.upperBound)
                substrings.append(String(text[index..<startIndex]))
                substrings.append(String(text[startIndex..<endIndex]))
                index = endIndex
            }

            // Add the remaining substring after the last match
            substrings.append(String(text[index...]))
            
            for substring in substrings {
                if let match = regex.firstMatch(in: substring, options: [], range: NSRange(substring.startIndex..., in: substring)) {
                    var modifiedText = regex.stringByReplacingMatches(in: substring, options: [], range: NSRange(location: 0, length: substring.utf16.count), withTemplate: "$1")

                    let fontSize = self.attributes.fontProperties?.size ?? 16
                    let lineHeight = fontSize * 1.5 // assume it's CJK environment

                    let backgroundColor = UIColor(Color(rgba: 0x5D5E67FF))
                    let backgroundSize = CGSize(width: fontSize + 2, height: fontSize) // 背景大小
                    let circleSize = CGSize(width: min(16, lineHeight), height: min(16, lineHeight)) // 背景大小
                    UIGraphicsBeginImageContextWithOptions(backgroundSize, false, 0)

                    let backgroundRect = CGRect(origin: CGPoint(x: (backgroundSize.width - circleSize.width) / 2, y: (backgroundSize.height - circleSize.height) / 2), size: circleSize)
                    let cornerRadius: CGFloat = circleSize.height / 2 // 圆角大小
                    let path = UIBezierPath(roundedRect: backgroundRect, cornerRadius: cornerRadius)
                    backgroundColor.setFill()
                    path.fill()

                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    let font = UIFont.systemFont(ofSize: 12)
                    let text_h = font.lineHeight
                    let text_y = (circleSize.height - text_h) / 2
                    let text_rect = CGRect(x: backgroundRect.origin.x, y: text_y + backgroundRect.origin.y, width: circleSize.width, height: text_h)
                    
                    modifiedText.draw(in: text_rect, withAttributes: [.font: font, .foregroundColor: UIColor(Color.white.opacity(0.8)), .paragraphStyle: paragraphStyle])
                    
                    let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if var backgroundImage = backgroundImage {
                        if #unavailable(iOS 16.0) {
                            let baselineOffset = (16 - lineHeight) / 4
                            let newSize = CGSize(width: backgroundImage.size.width + abs(baselineOffset), height: backgroundImage.size.height)
                            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                            backgroundImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                            let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? backgroundImage
                            UIGraphicsEndImageContext()
                            backgroundImage = newImage
                        }
                        self.renderResult = self.renderResult + Text(Image(uiImage: backgroundImage))
                            .baselineOffset((16 - lineHeight) / 4)
                            .tracking(2)
                    }
                } else {
                    var attributeStr = AttributedString(substring, attributes: self.attributes).resolvingFonts()
                    self.result += attributeStr
                    self.renderResult = self.renderResult + Text(attributeStr)
                }
            }
        } else {
            self.result += .init(text, attributes: self.attributes).resolvingFonts()
            self.renderResult = self.renderResult + Text(self.result)
        }
    }
    
    private mutating func renderSoftBreak() {
        if self.shouldSkipNextWhitespace {
            self.shouldSkipNextWhitespace = false
        } else {
            self.result += .init(" ", attributes: self.attributes).resolvingFonts()
            self.renderResult = self.renderResult + Text(self.result)
            
        }
    }
    
    private mutating func renderLineBreak() {
        self.result += .init("\n", attributes: self.attributes).resolvingFonts()
        self.renderResult = self.renderResult + Text(self.result)
    }
    
    private mutating func renderCode(_ code: String) {
        self.result += .init(code, attributes: self.textStyles.code.mergingAttributes(self.attributes)).resolvingFonts()
        self.renderResult = self.renderResult + Text(self.result)
    }
    
    private mutating func renderHTML(_ html: String) {
        let tag = HTMLTag(html)
        
        switch tag?.name.lowercased() {
        case "br":
            self.renderLineBreak()
            self.shouldSkipNextWhitespace = true
        default:
            self.renderText(html)
        }
    }
    
    private mutating func renderEmphasis(children: [InlineNode]) {
        let savedAttributes = self.attributes
        self.attributes = self.textStyles.emphasis.mergingAttributes(self.attributes)
        
        for child in children {
            self.render(child)
        }
        
        self.attributes = savedAttributes
    }
    
    private mutating func renderStrong(children: [InlineNode]) {
        let savedAttributes = self.attributes
        self.attributes = self.textStyles.strong.mergingAttributes(self.attributes)
        
        for child in children {
            self.render(child)
        }
        
        self.attributes = savedAttributes
    }
    
    private mutating func renderStrikethrough(children: [InlineNode]) {
        let savedAttributes = self.attributes
        self.attributes = self.textStyles.strikethrough.mergingAttributes(self.attributes)
        
        for child in children {
            self.render(child)
        }
        
        self.attributes = savedAttributes
    }
    
    private mutating func renderLink(destination: String, children: [InlineNode]) {
        let savedAttributes = self.attributes
        self.attributes = self.textStyles.link.mergingAttributes(self.attributes)
        self.attributes.link = URL(string: destination, relativeTo: self.baseURL)
        
        for child in children {
            self.render(child)
        }
        
        self.attributes = savedAttributes
    }
    
    private mutating func renderImage(source: String, children: [InlineNode]) {
        // AttributedString does not support images
    }
}

extension TextStyle {
    fileprivate func mergingAttributes(_ attributes: AttributeContainer) -> AttributeContainer {
        var newAttributes = attributes
        self._collectAttributes(in: &newAttributes)
        return newAttributes
    }
}
