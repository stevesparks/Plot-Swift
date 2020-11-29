//
//  WaveformControlView.swift
//  Plot
//
//  Created by Steve Sparks on 11/17/20.
//

import UIKit

class WaveformControlView: UIView {
    @IBOutlet var intensitySlider: UISlider!
    @IBOutlet var rateSlider: UISlider!
    @IBOutlet var biasSlider: UISlider!
    
    @IBOutlet var intensityLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var biasLabel: UILabel!

    var control: WaveformGeneratorProvider? {
        didSet {
            if let ctrl = control {
                populate(from: ctrl)
            }
        }
    }
    
    func populate(from control: WaveformGeneratorProvider) {
        intensitySlider.value = Float(control.intensity)
        rateSlider.value = Float(control.rate)
        biasSlider.value = Float(control.center)
        
        intensityLabel.text = "\(control.intensity)"
        rateLabel.text = "\(control.rate)"
        biasLabel.text = "\(control.center)"
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        switch sender {
        case intensitySlider: control?.intensity = Double(sender.value)
        case rateSlider: control?.rate = Double(sender.value)
        case biasSlider: control?.center = Double(sender.value)
        default:
            print("weeeerd")
            break
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    static func fromNib() -> WaveformControlView {
        let nib = UINib(nibName: "WaveformControlView", bundle: .main)
        let arr = nib.instantiate(withOwner: nil, options: nil)
        return arr[0] as! WaveformControlView
    }
}

