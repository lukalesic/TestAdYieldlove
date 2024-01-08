import Foundation
import PromiseKit

protocol ExceptionReporting {
    @discardableResult func report(err: Error) -> Promise<Void>
}
