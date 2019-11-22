@testable import SwiftLintFramework
import XCTest

// swiftlint:disable function_body_length

class ReturnStatementSpacingRuleTests: XCTestCase {
    func testWithDefaultConfiguration() {
        self.verifyRule(ReturnStatementSpacingRule.description)
    }

    func testAllowCommentConfigurationDisabled() {
        let nonTriggeringExamples = [
            """
            func foo() {
                return
            }
            """,
            """
            func foo() -> Int {
                return 0
            }
            """,
            """
            func foo() {
                // Comment

                return
            }
            """,
            """
            func foo() {
                /* comment */ return // comment
            }
            """,
            """
            func foo() {
                let a = 10

                return
            }
            """,
            """
            func foo() -> Int {
                if true {
                    return 0
                } else {
                    return 1
                }
            }
            """,
            """
            let foo = {
                return 0
            }
            """,
            """
            let foo = {
                let a = 10

                return 0
            }
            """,
            "[].map = { return 0 }",
            "[].map = { /* Comment */ return 0 }"
        ]
        let triggeringExamples = ReturnStatementSpacingRule.description.triggeringExamples + [
            """
            func foo() {
                //
                return
            }
            """,
            """
            func foo() {
                /**/
                return
            }
            """,
            """
            func foo() {
                /*
                    Comment
                */
                return
            }
            """,
            """
            func foo() {
                //
                // Comment
                //
                return
            }
            """,
            """
            func foo() {
                // Comment
                return
            }
            """,
            """
            func foo() {
                let a = 10

                // Comment
                return
            }
            """,
            """
            func foo() -> Int {
                if true {
                    // Comment
                    return 0
                } else {
                    return 1
                }
            }
            """,
            """
            let foo = {
                // Comment
                return 0
            }
            """
        ]

        let description = ReturnStatementSpacingRule.description
            .with(nonTriggeringExamples: nonTriggeringExamples)
            .with(triggeringExamples: triggeringExamples)

        self.verifyRule(description, ruleConfiguration: ["allow_comment": false])
    }
}
