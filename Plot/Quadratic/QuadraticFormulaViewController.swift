//
//  QuadraticFormulaViewController.swift
//  Plot
//
//  Created by Steve Sparks on 11/1/20.
//

import UIKit

class QuadraticFormulaViewController: UIViewController {
    @IBOutlet weak var plotView: PlotView!
    @IBOutlet weak var functionLabel: UILabel!
    @IBOutlet weak var tapDetailsLabel: UILabel!
    
    var labelX: CGFloat?
    
    enum ActivityKeys: String {
        case a = "quadratic.a"
        case b = "quadratic.b"
        case c = "quadratic.c"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plotView.delegate = self
        let plot = plotView.plot
        plot.provider = provider
        plot.minX = -4.0
        plot.maxX = 4.0
        plot.minY = -4.0
        plot.maxY = 4.0
        plot.plotDensity = 0.25
        functionLabel.text = provider.functionString
        aSlider.value = 0.0
        bSlider.value = 1.0
        cSlider.value = 0.0

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readValuesFromUserActivity()
    }

    var provider = QuadraticFormulaPlotter()
    @IBOutlet weak var aSlider: UISlider!
    @IBOutlet weak var bSlider: UISlider!
    @IBOutlet weak var cSlider: UISlider!
    
    @IBAction func sliderChanged(_ slider: UISlider) {
        switch slider {
        case aSlider: provider.a = CGFloat(slider.value * 20).rounded() / 20.0
        case bSlider: provider.b = CGFloat(slider.value * 20).rounded() / 20.0
        case cSlider: provider.c = CGFloat(slider.value * 20).rounded() / 20.0
        default: break
        }
        functionLabel.text = provider.functionString
        writeValuesToUserActivity()
    }

    @IBAction func resetButtonTapped(_ sender: Any) {
        provider.a = 0.0
        provider.b = 1.0
        provider.c = 0.0
        aSlider.value = 0.0
        bSlider.value = 1.0
        cSlider.value = 0.0
        functionLabel.text = provider.functionString
        writeValuesToUserActivity()
    }
        
    func readValuesFromUserActivity() {
        if let act = userActivity {
            if let a = act.userInfo?[ActivityKeys.a.rawValue] as? CGFloat {
                provider.a = a
                aSlider.value = Float(a)
            }
            if let b = act.userInfo?[ActivityKeys.b.rawValue] as? CGFloat {
                provider.b = b
                bSlider.value = Float(b)
            }
            if let c = act.userInfo?[ActivityKeys.c.rawValue] as? CGFloat {
                provider.c = c
                cSlider.value = Float(c)
            }
            functionLabel.text = provider.functionString
        }
    }
    
    func writeValuesToUserActivity() {
        if let act = userActivity {
            act.userInfo?[ActivityKeys.a.rawValue] = provider.a
            act.userInfo?[ActivityKeys.b.rawValue] = provider.b
            act.userInfo?[ActivityKeys.c.rawValue] = provider.c
            act.needsSave = true
        }
    }

}

extension QuadraticFormulaViewController: PlotViewDelegate {
    func plotView(_ plotView: PlotView, didTap viewCoordinate: CGPoint, translatedPoint: CGPoint) {
        labelX = translatedPoint.x
        plotView.highlightX = translatedPoint.x
        plotView.setNeedsDisplay()
        tapDetailsLabel.text = "X = \(translatedPoint.x.toThousands) Y = \(translatedPoint.y.toThousands)"
    }
    
    func plotViewDidEndTap(_ plotView: PlotView) {
        labelX = nil
        tapDetailsLabel.text = nil
        plotView.highlightX = nil
        plotView.setNeedsDisplay()
    }
}
