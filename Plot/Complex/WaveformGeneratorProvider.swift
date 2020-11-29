//
//  WaveformGeneratorProvider.swift
//  Plot
//
//  Created by Steve Sparks on 11/5/20.
//

import UIKit

class MultiplexingProvider: PlotProvider {
    var updater: PlotUpdateBlock = {} {
        didSet {
            populate()
        }
    }
    
    enum Mode {
        case add, subtract, average, minimum, maximum
    }
    var providers = [PlotProvider]() {
        didSet {
            populate()
        }
    }

    func populate() {
        providers.forEach { provider in
            provider.setUpdater({
                self.updater()
            })
        }
    }
    
    var mode: Mode = .add
    
    func yValue(for xValue: CGFloat) -> FunctionReturnValue<CGFloat> {
        let values = providers.map { $0.yValue(for: xValue) }
        var result = CGFloat(0.0)
        
        switch mode {

        case .add:
            return .real(values.reduce(0, { $0 + $1.first }))
        case .subtract:
            return .real(values.reduce(0, { $0 - $1.first }))
        case .average:
            guard !values.isEmpty else { return .real(0) }
            return .real(values.reduce(0, { $0 - $1.first }) / CGFloat(values.count))
        case .minimum:
            guard !values.isEmpty else { return .real(0) }
            result = values.reduce(CGFloat.greatestFiniteMagnitude) { return fmin($0, $1.minimum) }
        case .maximum:
            guard !values.isEmpty else { return .real(0) }
            result = values.reduce(0 - CGFloat.greatestFiniteMagnitude) { return fmax($0, $1.maximum) }
        }
        
        return .real(result)
    }
    
}

class WaveformGeneratorProvider {
    var values = [CGFloat]()
    var maxNumberOfValues = 300 
    
    var intensity = 0.4 { didSet { regen () } }
    var center = 0.0 { didSet { regen () } }
    var rate = 0.01 { didSet { regen () } }
    
    var generator: CADisplayLink?
    
    func regen() {
        workingIndex = 0
        values.removeAll()
        for _ in 1...maxNumberOfValues {
            workingIndex += rate
            let temp = Double(sin(workingIndex))
            let newValue = (temp * intensity) + center
            values.append(CGFloat(newValue))
        }
        updater()
    }
    
    private var workingIndex = 0.0
    
    init() {
        generator = CADisplayLink(target: self, selector: #selector(nextValue))
        generator?.add(to: .main, forMode: .common)
    }
    
    @objc
    func nextValue() {
        workingIndex += rate
        let temp = Double(sin(workingIndex))
        let newValue = (temp * intensity) + center
        values.append(CGFloat(newValue))
        if values.count > maxNumberOfValues {
            values = Array(values.dropFirst())
        }
        updater()
    }
    
    var updater: PlotUpdateBlock = {}
}

extension WaveformGeneratorProvider: PlotProvider {
    func yValue(for xValue: CGFloat) -> FunctionReturnValue<CGFloat> {
        let idx = Int(xValue)
        guard idx < values.count else { return .real(0) }
        return .real(values[idx])
    }
}

