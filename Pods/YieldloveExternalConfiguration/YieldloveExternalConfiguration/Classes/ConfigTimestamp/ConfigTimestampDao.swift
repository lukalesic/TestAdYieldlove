//
// Created by Ondrej Kormanik on 14/08/2020.
//

import Foundation

protocol ConfigTimestampDao {

    func read() -> Int

    func write(timestamp: Int)

}
