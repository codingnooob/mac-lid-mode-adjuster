import Foundation

/// Settings parsed from `pmset -g` output.
public struct PMSetSettings: Equatable {
    /// Raw `pmset -g` output, kept for diagnostics.
    public let raw: String
    /// Normalized key (lowercased, whitespace removed) -> raw value.
    private let values: [String: String]

    public init(raw: String) {
        self.raw = raw
        self.values = PMSetSettings.parse(raw)
    }

    /// Value for a setting key, e.g. `value(for: "disablesleep")`.
    public func value(for key: String) -> String? {
        values[PMSetSettings.normalize(key)]
    }

    public func int(for key: String) -> Int? {
        value(for: key).flatMap(Int.init)
    }

    /// `disablesleep` is omitted from `pmset -g` when it is 0 (the default),
    /// so absence is reported as `nil` here and treated as 0 by callers.
    public var disablesleep: Int? { int(for: "disablesleep") }
    public var idleSleepMinutes: Int? { int(for: "sleep") }
    public var lidwake: Int? { int(for: "lidwake") }

    private static func normalize(_ key: String) -> String {
        key.lowercased().filter { !$0.isWhitespace }
    }

    /// Parse lines of the form `key value`, where the key may contain spaces
    /// and the value may be followed by a parenthetical annotation.
    private static func parse(_ output: String) -> [String: String] {
        var result: [String: String] = [:]
        for line in output.split(separator: "\n", omittingEmptySubsequences: true) {
            var text = line.trimmingCharacters(in: .whitespaces)
            if let paren = text.firstIndex(of: "(") {
                text = String(text[..<paren]).trimmingCharacters(in: .whitespaces)
            }
            let parts = text.split(whereSeparator: { $0.isWhitespace })
            guard parts.count >= 2 else { continue }
            let key = parts.dropLast().joined(separator: " ")
            result[normalize(key)] = String(parts.last!)
        }
        return result
    }
}
