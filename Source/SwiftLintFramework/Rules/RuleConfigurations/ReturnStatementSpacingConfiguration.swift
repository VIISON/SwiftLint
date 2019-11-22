public struct ReturnStatementSpacingConfiguration: RuleConfiguration, Equatable {
    private(set) var severityConfiguration = SeverityConfiguration(.warning)
    private(set) var allowComment = true

    public var consoleDescription: String {
        self.severityConfiguration.consoleDescription + ", allow_comment: \(self.allowComment)"
    }

    public mutating func apply(configuration: Any) throws {
        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }

        self.allowComment = configuration["allow_comment"] as? Bool ?? true

        if let severityString = configuration["severity"] as? String {
            try self.severityConfiguration.apply(configuration: severityString)
        }
    }
}
