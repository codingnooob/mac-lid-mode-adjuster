import Foundation
@testable import lidmodeCore

/// Minimal assertion harness. This package deliberately avoids XCTest and
/// Swift Testing: the Command Line Tools on macOS ship neither a usable
/// XCTest.framework nor a Swift Testing macro plugin matching the driver.
struct TestHarness {
    private(set) var checks = 0
    private(set) var failures = 0

    mutating func check(
        _ condition: Bool,
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        checks += 1
        if condition {
            print("ok \(checks) - \(label)")
        } else {
            failures += 1
            print("FAIL \(checks) - \(label) (\(file):\(line))")
        }
    }

    mutating func expectEqual<T: Equatable>(
        _ actual: T,
        _ expected: T,
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        check(
            actual == expected,
            "\(label) - expected \(expected), got \(actual)",
            file: file,
            line: line
        )
    }

    mutating func expectNil<T>(
        _ value: T?,
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        check(
            value == nil,
            "\(label) - expected nil, got \(String(describing: value))",
            file: file,
            line: line
        )
    }
}
