import Foundation

/// Which power source a `pmset` change applies to.
public enum PMSetScope: String, Equatable {
    case all = "-a"
    case battery = "-b"
    case charger = "-c"

    public init?(argument: String) {
        switch argument.lowercased() {
        case "all": self = .all
        case "battery": self = .battery
        case "charger", "ac": self = .charger
        default: return nil
        }
    }
}

public enum PMSetError: LocalizedError {
    case launchFailed(path: String, message: String)
    case pmsetFailed(status: Int, message: String)

    public var errorDescription: String? {
        switch self {
        case .launchFailed(let path, let message):
            return "could not run \(path): \(message)"
        case .pmsetFailed(let status, let message):
            let detail = message.trimmingCharacters(in: .whitespacesAndNewlines)
            return detail.isEmpty
                ? "pmset exited with status \(status)"
                : "pmset exited with status \(status): \(detail)"
        }
    }
}

public protocol PMSetReading {
    func read() throws -> String
}

public protocol PMSetWriting {
    func write(_ key: String, _ value: Int, scope: PMSetScope) throws
}

/// Runs the real `/usr/bin/pmset`.
public struct SystemPMSet: PMSetReading, PMSetWriting {
    public var pmsetPath: String
    public var sudoPath: String

    public init(pmsetPath: String = "/usr/bin/pmset", sudoPath: String = "/usr/bin/sudo") {
        self.pmsetPath = pmsetPath
        self.sudoPath = sudoPath
    }

    public func read() throws -> String {
        try run(pmsetPath, arguments: ["-g"])
    }

    public func write(_ key: String, _ value: Int, scope: PMSetScope) throws {
        // pmset only changes settings when run as root, and sudo needs a TTY
        // to prompt for the password.
        _ = try run(sudoPath, arguments: [pmsetPath, scope.rawValue, key, String(value)])
    }

    private func run(_ path: String, arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        do {
            try process.run()
        } catch {
            throw PMSetError.launchFailed(path: path, message: error.localizedDescription)
        }
        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw PMSetError.pmsetFailed(
                status: Int(process.terminationStatus),
                message: String(data: errorData, encoding: .utf8) ?? ""
            )
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

/// Prints the command it would run instead of executing it.
public struct DryRunPMSet: PMSetWriting {
    public init() {}

    public func write(_ key: String, _ value: Int, scope: PMSetScope) throws {
        print("sudo /usr/bin/pmset \(scope.rawValue) \(key) \(value)")
    }
}
