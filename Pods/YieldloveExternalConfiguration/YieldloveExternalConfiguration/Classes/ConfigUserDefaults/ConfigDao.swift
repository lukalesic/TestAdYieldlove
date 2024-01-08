//
//  ConfigDao.swift
//  YieldloveAdIntegration
//
//  Created by Ondrej Kormanik on 11/08/2020.
//

import Foundation

protocol ConfigDao {
    
    func read() -> String?
    
    func write(configJSON: String)

    func delete() -> Void
    
}
