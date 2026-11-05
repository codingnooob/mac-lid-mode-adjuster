import Foundation

public struct LidModeController {
    public let reader: PMSetReading
    public let writer: PMSetWriting

    public init(reader: PMSetReading, writer: PMSetWriting) {
        self.reader = reader
        self.writer = writer
    }

    public func status() throws -> PMSetSettings {
        PMSetSettings(raw: try reader.read())
    }

    public func currentLidMode() throws -> LidSleepMode {
        LidSleepMode.from(disablesleep: try status().disablesleep ?? 0)
    }

    public func setLidMode(_ mode: LidSleepMode, scope: PMSetScope) throws {
        try writer.write("disablesleep", mode.disablesleep, scope: scope)
    }

    /// `minutes` is the idle sleep timer; 0 means never.
    public func setIdleSleep(minutes: Int, scope: PMSetScope) throws {
        try writer.write("sleep", minutes, scope: scope)
    }
}
