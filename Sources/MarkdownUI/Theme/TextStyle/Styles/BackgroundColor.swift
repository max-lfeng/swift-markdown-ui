import SwiftUI

/// A text style that sets the text background color.
public struct BackgroundColor: TextStyle {
  private let backgroundColor: Color?

  /// Creates a background color text style.
  /// - Parameter backgroundColor: The background color.
  public init(_ backgroundColor: Color?) {
    self.backgroundColor = backgroundColor
  }

  public func _collectAttributes(in attributes: inout AttributeContainer) {
    attributes.backgroundColor = self.backgroundColor
  }
}

public struct QuoteBackgroundColor: TextStyle {
    private let quoteBackgroundColor: Color?

    /// Creates a background color text style.
    /// - Parameter backgroundColor: The background color.
    public init(_ quoteBackgroundColor: Color?) {
      self.quoteBackgroundColor = quoteBackgroundColor
    }

    public func _collectAttributes(in attributes: inout AttributeContainer) {
      attributes.quoteProperties = QuoteProperties(quoteBackground: quoteBackgroundColor)
    }
}

