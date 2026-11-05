import Foundation
@testable import lidmodeCore

struct PMSetSettingsTests {
    /// Real `pmset -g` output captured on macOS (no `disablesleep` line).
    static let macMiniOutput = """
    System-wide power settings:
    Currently in use:
     standby              0
     Sleep On Power Button 1
     autorestartatconnect 0
     autorestart          0
     powernap             1
     networkoversleep     0
     disksleep            10
     sleep                1 (sleep prevented by powerd)
     ttyskeepawake        1
     displaysleep         10
     tcpkeepalive         1
     lowpowermode         0
     womp                 1
    """

    func run(_ harness: inout TestHarness) {
        let settings = PMSetSettings(raw: Self.macMiniOutput)
        harness.expectEqual(settings.int(for: "sleep"), 1, "parses idle sleep and strips annotation")
        harness.expectEqual(settings.value(for: "sleep"), "1", "raw idle sleep value")
        harness.expectNil(settings.disablesleep, "missing disablesleep is nil")
        harness.expectEqual(settings.int(for: "Sleep On Power Button"), 1, "multi-word key")
        harness.expectEqual(settings.int(for: "sleeponpowerbutton"), 1, "normalized key")

        let present = PMSetSettings(raw: "AC Power:\n disablesleep 1\n sleep 10\n")
        harness.expectEqual(present.disablesleep, 1, "parses disablesleep when present")
        harness.expectEqual(present.idleSleepMinutes, 10, "parses idle sleep when present")

        let tabbed = PMSetSettings(raw: "disablesleep\t1\n")
        harness.expectEqual(tabbed.disablesleep, 1, "normalizes whitespace in keys")
    }
}
