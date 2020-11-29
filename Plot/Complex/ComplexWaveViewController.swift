//
//  ComplexWaveViewController.swift
//  Plot
//
//  Created by Steve Sparks on 11/17/20.
//

import UIKit

class ComplexWaveViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var plotView: PlotView!
    
    var provider: PlotProvider!
    
    let wave1 = WaveformGeneratorProvider()
    let wave2 = WaveformGeneratorProvider()
    
    let w1 = WaveformControlView.fromNib()
    let w2 = WaveformControlView.fromNib()

    override func viewDidLoad() {
        super.viewDidLoad()

        wave1.rate = 0.04
        wave2.rate = 0.05
        wave2.intensity = 0.2
        
        let prov = MultiplexingProvider()
        prov.mode = .add
        prov.providers = [wave1, wave2]
        self.provider = prov
        
        let plot = plotView.plot
        plot.provider = prov
        plot.minX = 0
        plot.maxX = 300
        plot.minY = -2.0
        plot.maxY = 2.0
        
        plotView.backgroundColor = .black
        plotView.drawGridlines = false
        
        stackView.addArrangedSubview(w1)
        stackView.addArrangedSubview(w2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readValues()
        wave1.delegate = self
        wave2.delegate = self
        w1.control = wave1
        w2.control = wave2
    }

    func writeValues() {
        report()
        if let act = userActivity {
            wave1.writeValuesToUserActivity("wave1", act)
            wave2.writeValuesToUserActivity("wave2", act)
        } else {
            print("WELL WHY NOT")
        }
    }
    
    func readValues() {
        report()
        if let act = userActivity {
            wave1.readValuesFromUserActivity("wave1", act)
            wave2.readValuesFromUserActivity("wave2", act)
        } else {
            print("WELL WHY NOT")
        }
    }
}

extension ComplexWaveViewController: WaveformGeneratorProviderDelegate {
    func waveformParametersChanged(_ provider: WaveformGeneratorProvider) {
        writeValues()
    }
}
