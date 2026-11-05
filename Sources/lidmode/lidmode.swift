import Foundation
import lidmodeCore

@main
struct lidmode {
    static func main() {
        let system = SystemPMSet()
        let controller = LidModeController(reader: system, writer: system)
        do {
            try run(Array(CommandLine.arguments.dropFirst()), controller: controller)
        } catch {
            FileHandle.standardError.write(Data("lidmode: \(error.localizedDescription)\n".utf8))
            exit(1)
        }
    }

    static func run(_ arguments: [String], controller: LidModeController) throws {
        guard let command = arguments.first else {
            printUsage(to: .standardOutput)
            return
        }
        let rest = Array(arguments.dropFirst())
        switch command {
        case "status":
            try showStatus(controller: controller)
        case "lid":
            try changeLidMode(rest, controller: controller)
        case "idle":
            try changeIdleSleep(rest, controller: controller)
        case "help", "-h", "--help":
            printUsage(to: .standardOutput)
        default:
            FileHandle.standardError.write(Data("lidmode: unknown command '\(command)'\n".utf8))
            printUsage(to: .standardError)
            exit(2)
        }
    }

    static func showStatus(controller: LidModeController) throws {
        let settings = try controller.status()
        print("Lid mode:      \(try controller.currentLidMode().summary)")
        print("disablesleep:  \(settings.disablesleep.map(String.init) ?? "0 (not set)")")
        print("sleep:         \(settings.idleSleepMinutes.map(String.init) ?? "not set") minutes")
        print("lidwake:       \(settings.lidwake.map(String.init) ?? "not set")")
    }

    static func changeLidMode(_ arguments: [String], controller: LidModeController) throws {
        guard let options = parseOptions(arguments),
              options.positional.count == 1,
              let mode = LidSleepMode(argument: options.positional[0]) else {
            FileHandle.standardError.write(Data(
                "usage: lidmode lid <sleep|awake> [--scope all|battery|charger] [--dry-run]\n".utf8
            ))
            exit(2)
        }
        try LidModeController(reader: controller.reader, writer: options.writer)
            .setLidMode(mode, scope: options.scope)
        if !options.dryRun {
            print("Lid mode set to \(mode.summary).")
        }
    }

    static func changeIdleSleep(_ arguments: [String], controller: LidModeController) throws {
        guard let options = parseOptions(arguments),
              options.positional.count == 1,
              let minutes = parseMinutes(options.positional[0]) else {
            FileHandle.standardError.write(Data(
                "usage: lidmode idle <never|minutes> [--scope all|battery|charger] [--dry-run]\n".utf8
            ))
            exit(2)
        }
        try LidModeController(reader: controller.reader, writer: options.writer)
            .setIdleSleep(minutes: minutes, scope: options.scope)
        if !options.dryRun {
            print("Idle sleep set to \(minutes == 0 ? "never" : "\(minutes) minutes").")
        }
    }

    struct Options {
        var scope: PMSetScope
        var dryRun: Bool
        var positional: [String]
        var writer: PMSetWriting {
            dryRun ? DryRunPMSet() : SystemPMSet()
        }
    }

    static func parseOptions(_ arguments: [String]) -> Options? {
        var options = Options(scope: .all, dryRun: false, positional: [])
        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--scope":
                guard index + 1 < arguments.count,
                      let scope = PMSetScope(argument: arguments[index + 1]) else { return nil }
                options.scope = scope
                index += 2
            case "--dry-run", "-n":
                options.dryRun = true
                index += 1
            default:
                options.positional.append(argument)
                index += 1
            }
        }
        return options
    }

    /// Accepts `never` or a non-negative number of minutes.
    static func parseMinutes(_ text: String) -> Int? {
        if text.lowercased() == "never" { return 0 }
        guard let minutes = Int(text), minutes >= 0 else { return nil }
        return minutes
    }

    enum UsageStream {
        case standardOutput, standardError
        var handle: FileHandle {
            switch self {
            case .standardOutput: .standardOutput
            case .standardError: .standardError
            }
        }
    }

    static func printUsage(to stream: UsageStream = .standardOutput) {
        let text = """
        usage: lidmode <command> [options]

        commands:
          status                     show current lid/sleep settings
          lid <sleep|awake>          set behavior when the lid closes
          idle <never|minutes>       set the idle sleep timer

        options:
          --scope all|battery|charger   power source to change (default: all)
          --dry-run, -n                 print the pmset command instead of running it

        examples:
          lidmode status
          lidmode lid awake --scope battery --dry-run
          lidmode idle never
        """
        stream.handle.write(Data(text.utf8))
    }
}
