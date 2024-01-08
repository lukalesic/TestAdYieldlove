import Foundation

enum YLRemoteReportingError: Error {
    case serverUnreachable
    case serverResponseError(message: String)
}
