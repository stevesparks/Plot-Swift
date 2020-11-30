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

protocol WaveformGeneratorProviderDelegate: class {
    func waveformParametersChanged(_ provider: WaveformGeneratorProvider)
}

class WaveformGeneratorProvider {
    var values = [CGFloat]()
    var maxNumberOfValues = 320
    var delegate: WaveformGeneratorProviderDelegate?
    
    var intensity = 0.4 { didSet { regen () } }
    var bias = 0.0 { didSet { regen () } }
    var rate = 0.01 { didSet { regen () } }
    
    var generator: CADisplayLink?
    
    func regen() {
        workingIndex = 0
        values.removeAll()
        for _ in 1...maxNumberOfValues {
            workingIndex += rate
            let temp = Double(sin(workingIndex + bias))
            let newValue = (temp * intensity)
            values.append(CGFloat(newValue))
        }
        updater()
        delegate?.waveformParametersChanged(self)
    }
    
    private var workingIndex = 0.0
    
    init() {
        generator = CADisplayLink(target: self, selector: #selector(nextValue))
        generator?.add(to: .main, forMode: .common)
    }
    
    @objc
    func nextValue() {
        workingIndex += rate
        let temp = Double(sin(workingIndex + bias))
        let newValue = (temp * intensity)
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

extension WaveformGeneratorProvider {
    enum ActivityKeys: String {
        case intensity = "wave.phaseAngle"
        case bias = "wave.plotDensity"
        case rate = "wave.maxX"
    }
    
    func writeValuesToUserActivity(_ prefix: String, _ act: NSUserActivity) {
        act.userInfo?["\(prefix)-\(ActivityKeys.intensity.rawValue)"] =
            ((intensity * 100.0).rounded(.toNearestOrAwayFromZero)) / 100.0
        act.userInfo?["\(prefix)-\(ActivityKeys.rate.rawValue)"] =
            ((rate * 100.0).rounded(.toNearestOrAwayFromZero)) / 100.0
        act.userInfo?["\(prefix)-\(ActivityKeys.bias.rawValue)"] =
            ((bias * 100).rounded(.toNearestOrAwayFromZero)) / 100.0
        act.needsSave = true
    }
    
    func readValuesFromUserActivity(_ prefix: String, _ act: NSUserActivity) {
        if let tm = act.userInfo?["\(prefix)-\(ActivityKeys.intensity.rawValue)"] as? Double {
            intensity = tm
        }
        if let pD = act.userInfo?["\(prefix)-\(ActivityKeys.rate.rawValue)"] as? Double {
            rate = pD
        }
        if let max = act.userInfo?["\(prefix)-\(ActivityKeys.bias.rawValue)"] as? Double {
            bias = max
        }
    }    
}
