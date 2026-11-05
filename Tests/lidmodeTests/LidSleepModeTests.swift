import Foundation
@testable import lidmodeCore

struct LidSleepModeTests {
    func run(_ harness: inout TestHarness) {
        harness.expectEqual(LidSleepMode(argument: "sleep"), .sleepOnClose, "parses sleep")
        harness.expectEqual(LidSleepMode(argument: "awake"), .awakeOnClose, "parses awake")
        harness.expectEqual(LidSleepMode(argument: "SLEEP"), .sleepOnClose, "parses uppercase")
        harness.expectNil(LidSleepMode(argument: "nope"), "rejects unknown mode")

        harness.expectEqual(LidSleepMode.sleepOnClose.disablesleep, 0, "sleepOnClose disablesleep")
        harness.expectEqual(LidSleepMode.awakeOnClose.disablesleep, 1, "awakeOnClose disablesleep")
        harness.expectEqual(LidSleepMode.from(disablesleep: 0), .sleepOnClose, "mode from 0")
        harness.expectEqual(LidSleepMode.from(disablesleep: 1), .awakeOnClose, "mode from 1")

        harness.expectEqual(PMSetScope(argument: "all"), .all, "scope all")
        harness.expectEqual(PMSetScope(argument: "battery"), .battery, "scope battery")
        harness.expectEqual(PMSetScope(argument: "charger"), .charger, "scope charger")
        harness.expectEqual(PMSetScope(argument: "ac"), .charger, "scope ac")
        harness.expectNil(PMSetScope(argument: "usb"), "rejects unknown scope")
    }
}
