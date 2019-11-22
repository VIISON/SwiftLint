internal struct ReturnStatementSpacingRuleExamples {
    static let nonTriggeringExamples = [
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
        func foo() {
            let a = 10

            // Comment
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
            return 0
        }
        """,
        """
        let foo = {
            // Comment
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

    static let triggeringExamples = [
        """
        func foo() {
            let a = 10
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
                let a = 10
                return a
            } else {
                return 1
            }
        }
        """,
        """
        let foo = {
            let a = 10
            return 0
        }
        """,
        """
        [].map = {
            let a = 10
            return a
        }
        """
    ]
}
