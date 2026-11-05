import Foundation
@testable import lidmodeCore

@main
struct lidmodeTests {
    static func main() {
        var harness = TestHarness()
        PMSetSettingsTests().run(&harness)
        LidModeControllerTests().run(&harness)
        LidSleepModeTests().run(&harness)
        print("\(harness.checks) checks, \(harness.failures) failures")
        exit(harness.failures == 0 ? 0 : 1)
    }
}
