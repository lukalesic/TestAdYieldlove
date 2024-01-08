//
//  ConfigFetcher.swift
//  YieldloveAdIntegration
//
//  Created by Ondrej Kormanik on 11/08/2020.
//

import Foundation
import PromiseKit

protocol ConfigFetcher {
    func fetch(url: String) -> Promise<String>
}
