import Foundation

public protocol Event {
    var typeName: String { get }
    var timeSinceMeasuringStarted: Int { get set }
}

public class TimeEvent: Event, Encodable {
    class TimeEventCodingKeys: CodingKeys {
        public static let type = TimeEventCodingKeys(jsonKey: "type", rawValue: "typeName")
        public static let timeSinceMeasuringStarted = TimeEventCodingKeys(jsonKey: "time", rawValue: "timeSinceMeasuringStarted")
    }

    public var typeName: String {
        let fullEventName = String(describing: self)
        if let index = fullEventName.firstIndex(of: ".") {
            let indexAfter = fullEventName.index(after: index)
            return String(fullEventName[indexAfter...])
        }
        return fullEventName
    }
    public var timeSinceMeasuringStarted = 0

    init(measuringStarted: Date, eventProduced: Date) {
        self.timeSinceMeasuringStarted = self.diff(measuringStarted, eventProduced)
    }

    func encodeTimeEventData(to encoder: Encoder) throws -> KeyedEncodingContainer<TimeEventCodingKeys> {
        var container = encoder.container(keyedBy: TimeEventCodingKeys.self)
        try container.encode(typeName, forKey: TimeEventCodingKeys.type)
        try container.encode(timeSinceMeasuringStarted, forKey: TimeEventCodingKeys.timeSinceMeasuringStarted)
        return container
    }

    public func encode(to encoder: Encoder) throws {
        _ = try self.encodeTimeEventData(to: encoder)
    }

    func asString() -> String {
        return "\(typeName): \(timeSinceMeasuringStarted) ms"
    }

    func diff(_ startingPoint: Date, _ eventProduced: Date) -> Int {
        let dateInteval = DateInterval(start: startingPoint, end: eventProduced)
        let sinceMeasuringStarted = dateInteval.duration
        return sinceMeasuringStarted.milliseconds
    }
}

extension TimeInterval {
    var milliseconds: Int {
        return Int(self * 1000)
    }
}
