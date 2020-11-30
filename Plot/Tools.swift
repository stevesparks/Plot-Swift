//
//  Tools.swift
//  Plot
//
//  Created by Steve Sparks on 11/30/20.
//

import UIKit

extension CGFloat {
    var toThousands: CGFloat {
        return (self * 1000).rounded(.toNearestOrAwayFromZero) / 1000.0
    }
}

extension Double {
    var toThousands: Double {
        return (self * 1000).rounded(.toNearestOrAwayFromZero) / 1000.0
    }
}

extension Float {
    var toThousands: Float {
        return (self * 1000).rounded(.toNearestOrAwayFromZero) / 1000.0
    }
}

extension NSObject {
    func report(_ message: CustomStringConvertible = "", _ preamble: CustomStringConvertible = "", function: String = #function) {
        let fn = String(describing: type(of: self))
        print("--> \(preamble)\(fn) \(function) \(message) ")
    }
}
