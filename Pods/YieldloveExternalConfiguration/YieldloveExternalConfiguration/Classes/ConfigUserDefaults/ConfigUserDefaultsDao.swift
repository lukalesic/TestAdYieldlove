//
//  ConfigUserDefaultsDao.swift
//  YieldloveAdIntegration
//
//  Created by Ondrej Kormanik on 10/08/2020.
//

import Foundation

public class ConfigUserDefaultsDao: ConfigDao {
    public static let configUserDefaultsKey: String = "ExternalConfig"
    private var defaults: UserDefaults
    
    init() {
        defaults = UserDefaults.standard
    }
    
    func read() -> String? {
        return defaults.string(forKey: ConfigUserDefaultsDao.configUserDefaultsKey)
    }
    
    func write(configJSON: String) {
        defaults.set(configJSON, forKey: ConfigUserDefaultsDao.configUserDefaultsKey)
    }

    func delete() {
        defaults.removeObject(forKey: ConfigUserDefaultsDao.configUserDefaultsKey)
    }
}
