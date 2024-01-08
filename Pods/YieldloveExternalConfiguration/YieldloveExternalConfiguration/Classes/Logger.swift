import Foundation

class Logger {
    static func debug(message: String) {
        if ExternalConfigurationManagerBuilder.instance.debug {
            print("\(Date()): \(message)")
        }
    }
}
