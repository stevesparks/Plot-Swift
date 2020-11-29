//
//  Function.swift
//  Plot
//
//  Created by Steve Sparks on 11/2/20.
//

import UIKit

enum FunctionReturnValue<T> {
    case real(T)
    case oneOf([PossibleValue])
    case multiple([T])
    
    var any: T {
        switch self {
        case .real(let value): return value
        case .oneOf(_): return pickOne()
        case .multiple(let arr): return arr.randomElement()!
        }
    }
    var all: [T] {
        switch self {
        case .real(let value): return [value]
        case .oneOf(_): return [pickOne()]
        case .multiple(let arr): return arr
        }
    }
    
    var first: T {
        switch self {
        case .real(let value): return value
        case .oneOf(let values): return values.first!.value
        case .multiple(let arr): return arr.first!
        }
    }
}

typealias PlotFunction = (CGFloat) -> FunctionReturnValue<CGFloat>

protocol PlotProvider: class {
    func yValue(for xValue: CGFloat) -> FunctionReturnValue<CGFloat>
    var updater: PlotUpdateBlock { get set }
    
    func setUpdater(_ updater: @escaping PlotUpdateBlock)
}

extension PlotProvider {
    func setUpdater(_ updater: @escaping PlotUpdateBlock) {
        self.updater = updater
    }
}

extension FunctionReturnValue where T == CGFloat {
    var minimum: T {
        switch self {
        case .real(let value): return value
        case .oneOf(_): return any
        case .multiple(let arr):
            return arr.reduce(CGFloat.greatestFiniteMagnitude) { return fmin($0, $1) }
        }
    }
    
    var maximum: T {
        switch self {
        case .real(let value): return value
        case .oneOf(_): return any
        case .multiple(let arr):
            return arr.reduce(0 - CGFloat.greatestFiniteMagnitude) { return fmax($0, $1) }
        }
    }
}
