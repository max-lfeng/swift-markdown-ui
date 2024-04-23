//
//  MarkdownPreprossor.swift
//
//
//  Created by Max Feng on 2024/4/22.
//

import SwiftUI

public protocol MarkdownPreprocessor {
    func process(_ markdown: String) -> String
}

public struct PassthroughMarkdownPreprocessor: MarkdownPreprocessor {
    
    public init() {}
    
    public func process(_ markdown: String) -> String {
        markdown
    }
}
