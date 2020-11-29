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
        
        let w1 = WaveformControlView.fromNib()
        w1.control = wave1
        stackView.addArrangedSubview(w1)

        let w2 = WaveformControlView.fromNib()
        w2.control = wave2
        stackView.addArrangedSubview(w2)
    }


}
