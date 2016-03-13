//
//  Interpolator.swift
//  CsoundBasic2
//
//  Created by Carlos Millan on 3/12/16.
//  Copyright © 2016 Carlos Millan. All rights reserved.
//

import Foundation


class Interpolator {
    var coeff: Double
    var current: Double
    
    
    init(coeff: Double) {
        self.coeff = coeff
        self.current = 0
    }
    
    
    func addSample(value: Double) -> Double {
        let delta = (value - current) * coeff
        current = current + delta
        if delta > 0 {
            current = min(current, value)
        }
        else if delta < 0 {
            current = max(current, value)
        }
        return current
    }
    
    
}