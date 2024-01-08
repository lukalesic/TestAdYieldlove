import Foundation

class MeasuringStarted: TimeEvent {

    let startingPoint: Date

    init(startingPoint: Date) {
        self.startingPoint = startingPoint
        super.init(measuringStarted: startingPoint, eventProduced: startingPoint)
    }

}
