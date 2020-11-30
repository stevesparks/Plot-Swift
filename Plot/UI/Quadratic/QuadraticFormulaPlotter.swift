//
//  QuadraticFormulaPlotter.swift
//  Plot
//
//  Created by Steve Sparks on 11/1/20.
//

import UIKit

typealias PlotUpdateBlock = () -> Void

class QuadraticFormulaPlotter: PlotProvider {
    var a: CGFloat = 0 {
        didSet { updater() }
    }
    var b: CGFloat = 1 {
        didSet { updater() }
    }
    var c: CGFloat = 0 {
        didSet { updater() }
    }
    
    var updater: PlotUpdateBlock = {}
    
    func yValue(for xValue: CGFloat) -> FunctionReturnValue<CGFloat> {
        let aSquaredX: CGFloat = a * (xValue * xValue)
        let result = CGFloat(aSquaredX + (b * xValue) + c)
        return .real( result )
    }
    var functionString: String {
        let a = CGFloat(Int(self.a * 1000))/1000.0
        let b = CGFloat(Int(self.b * 1000))/1000.0
        let c = CGFloat(Int(self.c * 1000))/1000.0
        return "\(a)x² + \(b)x + \(c)"
    }
}
