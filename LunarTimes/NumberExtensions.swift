//
//  NumberExtensio.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 1/17/20.
//  Copyright © 2020 LetsHangLLC. All rights reserved.
//

import Foundation

extension Double {
    func string(to decimalPlaces: Int) -> String {
        String(format: "%.1f", self)
    }
    
    func percentString(to decimalPlaces: Int) -> String {
        return string(to: decimalPlaces) + "%"
    }
}
