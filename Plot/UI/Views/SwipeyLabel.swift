//
//  SwipeyLabel.swift
//  Plot
//
//  Created by Steve Sparks on 11/30/20.
//

import UIKit

class SwipeyLabel: UIControl {
    private var internalLabel = UILabel()
    private var panner = UIPanGestureRecognizer()
    
    var minimumValue: CGFloat = -10.0
    var maximumValue: CGFloat = 10.0
    var value: CGFloat = 0
    
    func setup() {
        internalLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(internalLabel)
        internalLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        internalLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        isUserInteractionEnabled = true
        internalLabel.font = .systemFont(ofSize: 24)
        internalLabel.textColor = .black
        internalLabel.text = "OK then"
//        panner.allowedScrollTypesMask = .all
        panner.addTarget(self, action: #selector(didPan(_:)))
        
        addGestureRecognizer(panner)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    @objc func didPan(_ panner: UIPanGestureRecognizer) {
        let translation = panner.translation(in: self)
        report("\(translation)")
    }
}
