import Foundation
import SourceKittenFramework

public struct ReturnStatementSpacingRule: OptInRule, ConfigurationProviderRule {
    public var configuration = ReturnStatementSpacingConfiguration()

    public init() {}

    public static let description = RuleDescription(
        identifier: "return_statement_spacing",
        name: "Return statement spacing",
        description: "`return` statements must be preceded by a single empty line.",
        kind: .style,
        nonTriggeringExamples: ReturnStatementSpacingRuleExamples.nonTriggeringExamples,
        triggeringExamples: ReturnStatementSpacingRuleExamples.triggeringExamples
    )

    public func validate(file: SwiftLintFile) -> [StyleViolation] {
        file.syntaxTokensByLines.enumerated()
            .filter { file.isReturnOnlyLine($0.element) }
            .compactMap { returnLineIndex, returnLineTokens -> StyleViolation? in
                guard let returnToken = returnLineTokens.first(where: file.isReturnKeywordSyntaxToken) else {
                    preconditionFailure("No `return` token found in return-only line.")
                }

                let violation = StyleViolation(
                    ruleDescription: Self.description,
                    severity: self.configuration.severityConfiguration.severity,
                    location: Location(file: file, byteOffset: returnToken.value.offset)
                )

                // Treat comments that directly precede a `return` statement (no empty lines between them) as part
                // of the `return` statement, if configured
                var firstReturnStatementLine = returnLineIndex
                var firstReturnStatementToken = returnToken
                for (precedingLineIndex, precedingLineTokens) in file.syntaxTokensByLines[0 ..< returnLineIndex].enumerated().reversed() {
                    if file.isCommentLine(precedingLineTokens), let firstCommentToken = precedingLineTokens.first {
                        guard self.configuration.allowComment else {
                            return violation
                        }

                        firstReturnStatementLine = precedingLineIndex
                        firstReturnStatementToken = firstCommentToken
                    } else {
                        break
                    }
                }

                debugPrint(firstReturnStatementLine, firstReturnStatementToken)

                // Find the context enclosing the `return` statement
                guard let context = file.structureDictionary.findContext(of: firstReturnStatementToken) else {
                    return nil
                }

                // Find the `return` statement's sibling directly preceding it, if any
                guard let precedingSibling = context.findSibling(preceding: firstReturnStatementToken) else {
                    return nil
                }

                if context.byteRange == precedingSibling.byteRange {
                    // `return` statement is the only member of its context
                    return nil
                }

                guard
                    let precedingSiblingEndOffset = precedingSibling.byteRange?.upperBound,
                    let (precedingSiblingLine, _) = file.contents.bridge().lineAndCharacter(forByteOffset: precedingSiblingEndOffset),
                    precedingSiblingLine >= (firstReturnStatementLine - 1)
                else {
                    return nil
                }

                return violation
            }
    }
}

fileprivate extension SwiftLintFile {
    func isReturnKeywordSyntaxToken(_ token: SwiftLintSyntaxToken) -> Bool {
        token.kind == .keyword && self.contents(for: token) == "return"
    }

    func isReturnOnlyLine(_ tokens: [SwiftLintSyntaxToken]) -> Bool {
        tokens.first { !($0.kind?.isCommentLike ?? false) }.map { self.isReturnKeywordSyntaxToken($0) } ?? false
    }

    func isCommentLine(_ tokens: [SwiftLintSyntaxToken]) -> Bool {
        !tokens.isEmpty && tokens.allSatisfy { $0.kind?.isCommentLike ?? false }
    }
}

fileprivate extension SourceKittenDictionary {
    func findContext(of token: SwiftLintSyntaxToken) -> SourceKittenDictionary? {
        guard let byteRange = self.byteRange, NSIntersectionRange(byteRange, token.range).length > 0 else {
            return nil
        }

        return self.substructure.reduce(self) { result, subElement in
            if
                let enclosingElement = subElement.findContext(of: token),
                (result.offset ?? 0) <= (enclosingElement.offset ?? 0)
            {
                return enclosingElement
            }

            return result
        }
    }

    func findSibling(preceding token: SwiftLintSyntaxToken) -> SourceKittenDictionary? {
        self.substructure.reduce(self) { result, subElement in
            if let byteRange = subElement.byteRange, byteRange.upperBound < token.offset {
                return subElement
            }

            return result
        }
    }
}
