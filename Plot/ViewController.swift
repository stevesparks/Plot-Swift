//
//  ViewController.swift
//  Plot
//
//  Created by Steve Sparks on 10/23/20.
//

import UIKit
import AVFoundation

fileprivate let DEG2RAD = 180.0 / CGFloat.pi
class SineWaveViewController: UIViewController {
    @IBOutlet var timeMultLabel: UILabel!
    @IBOutlet var plotDensityLabel: UILabel!
    @IBOutlet var maxXLabel: UILabel!
    @IBOutlet var plotView: PlotView!
    
    @IBOutlet weak var phaseSlider: UISlider!
    @IBOutlet weak var plotDensitySlider: UISlider!
    @IBOutlet weak var maxXSlider: UISlider!
    @IBOutlet weak var reportLabel: UILabel!
    
    var phaseAngle: CGFloat = 90.0
    
    var labelX: CGFloat?
    
    enum ActivityKeys: String {
        case phaseAngle = "sineView.phaseAngle"
        case plotDensity = "sineView.plotDensity"
        case maxX = "sineView.maxX"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readValuesFromUserActivity()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plotView.plot.function = { xVal in
            let time = CGFloat(CFAbsoluteTimeGetCurrent()) * 0.2
            let yValue = sin(xVal + time) * 4.0
            let yValue2 = sin(xVal + time + (self.phaseAngle / DEG2RAD)) * 4.0
            if yValue == 0 {
                return .real(0)
            } else {
                return .multiple([yValue, yValue2])
            }
        }
        plotView.delegate = self
        phaseSlider.value = 90.0
        plotDensitySlider.value = 0.01
        maxXSlider.value = 10.0
        plotView.plot.maxX = 10.0
        plotView.plot.minY = -5.0
        plotView.plot.maxY = 5.0
        plotView.plot.plotDensity = 0.01
        populate()

        let link = CADisplayLink(target: self, selector: #selector(linkFired(_:)))
        link.add(to: .main, forMode: .common)
        // Do any additional setup after loading the view.
    }
    
    func populate() {
        let tm = ((phaseAngle * 100.0).rounded(.toNearestOrAwayFromZero)) / 100.0
        timeMultLabel.text = "phase = \(tm)º"

        let density = plotView.plot.plotDensity ?? 0.01
        let pd = ((density * 100.0).rounded(.toNearestOrAwayFromZero)) / 100.0
        plotDensityLabel.text = "pd = \(pd)"
        
        let maxX = ((plotView.plot.maxX * 100).rounded(.toNearestOrAwayFromZero)) / 100.0
        maxXLabel.text = "maxX = \(maxX)"
    }
    
    func writeValuesToUserActivity() {
        if let act = userActivity {
            let tm = ((phaseAngle * 100.0).rounded(.toNearestOrAwayFromZero)) / 100.0
            act.userInfo?[ActivityKeys.phaseAngle.rawValue] = tm
            let density = plotView.plot.plotDensity ?? 0.01
            let pd = ((density * 100.0).rounded(.toNearestOrAwayFromZero)) / 100.0
            act.userInfo?[ActivityKeys.plotDensity.rawValue] = pd
            let maxX = ((plotView.plot.maxX * 100).rounded(.toNearestOrAwayFromZero)) / 100.0
            act.userInfo?[ActivityKeys.maxX.rawValue] = maxX
            act.needsSave = true
        }
    }
    
    func readValuesFromUserActivity() {
        if let act = userActivity {
            if let tm = act.userInfo?[ActivityKeys.phaseAngle.rawValue] as? CGFloat {
                phaseAngle = tm
                phaseSlider.value = Float(tm)
            }
            if let pD = act.userInfo?[ActivityKeys.plotDensity.rawValue] as? CGFloat {
                report("pD = \(pD)")
                plotView.plot.plotDensity = pD
                plotDensitySlider.value = Float(pD * 100)
            }
            if let max = act.userInfo?[ActivityKeys.maxX.rawValue] as? CGFloat {
                plotView.plot.maxX = max
                maxXSlider.value = Float(max)
            }
        }
    }
    
    @objc func linkFired(_ link: CADisplayLink) {
        plotView.setNeedsDisplay()
        if let tX = labelX {
            let y = plotView.plot.yValue(for: tX).any
            let translatedPoint = CGPoint(x: tX, y: y)
            reportLabel.text = "X = \(translatedPoint.x.toThousands) Y = \(translatedPoint.y.toThousands)"
        }
    }
    
    @IBAction func timeSliderValueChanged(_ sender: UISlider) {
        phaseAngle = CGFloat(sender.value / 5.0).rounded() * 5.0
        populate()
        writeValuesToUserActivity()
    }
    
    @IBAction func plotDensitySliderValueChanged(_ sender: UISlider) {
        plotView.plot.plotDensity = CGFloat(sender.value) / 100.0
        populate()
        writeValuesToUserActivity()
    }
    
    @IBAction func xMaxSliderValueChanged(_ sender: UISlider) {
        plotView.plot.maxX = CGFloat(sender.value)
        populate()
        writeValuesToUserActivity()
    }
}

extension SineWaveViewController: PlotViewDelegate {
    func plotViewDidEndTap(_ plotView: PlotView) {
        labelX = nil
    }
    func plotView(_ plotView: PlotView, didTap viewCoordinate: CGPoint, translatedPoint: CGPoint) {
        labelX = translatedPoint.x
    }
}


extension CGFloat {
    var toThousands: CGFloat {
        return (self * 1000).rounded(.toNearestOrAwayFromZero) / 1000.0
    }
}


extension UIViewController {
    var sceneDelegate: SceneDelegate? {
        return view.window?.windowScene?.delegate as? SceneDelegate
    }
    
    open override var userActivity: NSUserActivity? {
        get {
            return sceneDelegate?.activity ?? super.userActivity
        }
        set {
            
        }
    }
}


class MT: UITabBarController {
    
}
