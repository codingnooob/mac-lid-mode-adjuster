import Foundation

/// What the Mac does when the laptop lid is closed.
public enum LidSleepMode: String, CaseIterable, Equatable {
    /// `disablesleep 0` — closing the lid sleeps the Mac (default).
    case sleepOnClose
    /// `disablesleep 1` — closing the lid keeps the Mac awake (clamshell mode).
    case awakeOnClose

    public var disablesleep: Int {
        switch self {
        case .sleepOnClose: 0
        case .awakeOnClose: 1
        }
    }

    /// Parse a mode name from the command line (`sleep` or `awake`).
    public init?(argument: String) {
        switch argument.lowercased() {
        case "sleep": self = .sleepOnClose
        case "awake": self = .awakeOnClose
        default: return nil
        }
    }

    public static func from(disablesleep: Int) -> LidSleepMode {
        disablesleep == 1 ? .awakeOnClose : .sleepOnClose
    }

    public var summary: String {
        switch self {
        case .sleepOnClose: "sleep when the lid closes"
        case .awakeOnClose: "stay awake when the lid closes (clamshell)"
        }
    }
}
