import Foundation
@testable import lidmodeCore

struct FakeReader: PMSetReading {
    var output: String
    func read() throws -> String { output }
}

final class FakeWriter: PMSetWriting {
    struct Call: Equatable {
        var key: String
        var value: Int
        var scope: PMSetScope
    }

    var calls: [Call] = []

    func write(_ key: String, _ value: Int, scope: PMSetScope) throws {
        calls.append(Call(key: key, value: value, scope: scope))
    }
}

struct LidModeControllerTests {
    func run(_ harness: inout TestHarness) {
        let sleepController = LidModeController(reader: FakeReader(output: "sleep 1\n"), writer: FakeWriter())
        harness.check(
            (try? sleepController.currentLidMode()) == .sleepOnClose,
            "lid mode is sleep when disablesleep is missing"
        )

        let awakeController = LidModeController(reader: FakeReader(output: "disablesleep 1\n"), writer: FakeWriter())
        harness.check(
            (try? awakeController.currentLidMode()) == .awakeOnClose,
            "lid mode is awake when disablesleep is 1"
        )

        let writer = FakeWriter()
        let controller = LidModeController(reader: FakeReader(output: ""), writer: writer)
        try? controller.setLidMode(.awakeOnClose, scope: .battery)
        harness.expectEqual(
            writer.calls,
            [FakeWriter.Call(key: "disablesleep", value: 1, scope: .battery)],
            "setLidMode writes disablesleep"
        )

        let neverWriter = FakeWriter()
        let neverController = LidModeController(reader: FakeReader(output: ""), writer: neverWriter)
        try? neverController.setIdleSleep(minutes: 0, scope: .all)
        harness.expectEqual(
            neverWriter.calls,
            [FakeWriter.Call(key: "sleep", value: 0, scope: .all)],
            "setIdleSleep never writes zero"
        )

        let minutesWriter = FakeWriter()
        let minutesController = LidModeController(reader: FakeReader(output: ""), writer: minutesWriter)
        try? minutesController.setIdleSleep(minutes: 15, scope: .charger)
        harness.expectEqual(
            minutesWriter.calls,
            [FakeWriter.Call(key: "sleep", value: 15, scope: .charger)],
            "setIdleSleep writes minutes"
        )
    }
}
