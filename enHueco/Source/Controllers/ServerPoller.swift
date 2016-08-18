//
//  NSPoller.swift
//  enHueco
//
//  Created by Diego Gómez on 3/30/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit

protocol ServerPoller {
    var requestTimer: NSTimer { get set }
    var pollingInterval: NSTimeInterval { get }

    func startPolling()

    func pollFromServer(timer: NSTimer)
}

extension ServerPoller where Self: NSObject {
    func stopPolling() {

        requestTimer.invalidate()
    }
}
