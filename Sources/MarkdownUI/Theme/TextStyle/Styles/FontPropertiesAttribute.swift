import Foundation
import SwiftUI

enum FontPropertiesAttribute: AttributedStringKey {
  typealias Value = FontProperties
  static let name = "fontProperties"
}

extension AttributeScopes {
  var markdownUI: MarkdownUIAttributes.Type {
    MarkdownUIAttributes.self
  }

  struct MarkdownUIAttributes: AttributeScope {
    let swiftUI: SwiftUIAttributes
    let fontProperties: FontPropertiesAttribute
    let quoteProperties: QuotePropertiesAttribute
  }
}

extension AttributeDynamicLookup {
  subscript<T: AttributedStringKey>(
    dynamicMember keyPath: KeyPath<AttributeScopes.MarkdownUIAttributes, T>
  ) -> T {
    return self[T.self]
  }
}

extension AttributedString {
  func resolvingFonts() -> AttributedString {
    var output = self

    for run in output.runs {
      guard let fontProperties = run.fontProperties else {
        continue
      }
      output[run.range].font = .withProperties(fontProperties)
      output[run.range].fontProperties = nil
    }

    return output
  }
}


enum QuotePropertiesAttribute: AttributedStringKey {
    
  typealias Value = QuoteProperties
  static let name = "quoteProperties"
}

public struct QuoteProperties: Hashable {
    public var quoteBackground: Color
    
    init(quoteBackground: Color?) {
        self.quoteBackground = quoteBackground ?? .clear
    }
}
    
extension QuoteProperties: TextStyle {
  public func _collectAttributes(in attributes: inout AttributeContainer) {
      attributes.quoteProperties = self
  }
}
