//
// Created by Ondrej Kormanik on 14/08/2020.
//

import Foundation

public class ConfigTimestampUserDefaultsDao: ConfigTimestampDao {
    public static let externalConfigLastFetchInMsKey: String = "ExternalConfigLastFetchInMs"

    private var defaults: UserDefaults

    init() {
        defaults = UserDefaults.standard
    }

    func read() -> Int {
        return defaults.integer(forKey: ConfigTimestampUserDefaultsDao.externalConfigLastFetchInMsKey) 
    }

    func write(timestamp: Int) {
        defaults.set(timestamp, forKey: ConfigTimestampUserDefaultsDao.externalConfigLastFetchInMsKey)
    }
}
