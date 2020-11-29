//
//  PlotView.swift
//  Plot
//
//  Created by Steve Sparks on 10/23/20.
//

import UIKit

protocol PlotViewDelegate: class {
    func plotView(_ plotView: PlotView, didTap viewCoordinate: CGPoint, translatedPoint: CGPoint)
    func plotViewDidEndTap(_ plotView: PlotView)
}

class PlotView: UIView {
    var lineColor: UIColor = .white
    var plot = Plot()
    var plottedDotSize: CGFloat = 6.0

    var delegate: PlotViewDelegate?
    var highlightX: CGFloat?
    
    var drawGridlines = true
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if window != nil {
            NotificationCenter.default.removeObserver(self, name: .plotUpdated, object: nil)
        }
        if newWindow != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(plotUpdated(_:)), name: .plotUpdated, object: nil)
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard bounds.size.width != 0 else { return }
        if let ctx = UIGraphicsGetCurrentContext() {
            if drawGridlines {
                drawGridlinesX(rect, color: .darkGray, in: ctx)
                drawGridlinesY(rect, color: .darkGray, in: ctx)
            }

            ctx.setStrokeColor(lineColor.cgColor)
            let sets = plot.pointSets(for: rect)
            for (idx, points) in sets.enumerated() {
                let hue = CGFloat(idx % 8) / 8.0
                let setColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
                
                drawLines(points, ctx: ctx, setColor: setColor)
                if plotDots, plot.pointsHorizontally < Int(bounds.size.width / plottedDotSize) {
                    drawDots(rect, points, ctx: ctx, setColor: setColor)
                }
            }
            
            if let ptX = highlightX {
                let y = plot.yValue(for: ptX).first
                let pt = plot.point(for: ptX, y, in: self.bounds)
                
                let setColor = UIColor(hue: 0.0, saturation: 0.5, brightness: 1.0, alpha: 1.0).cgColor
                drawRingCenteredOn(pt, setColor: setColor)
            }
        }
    }
    
    func drawLines(_ points: [CGPoint], ctx: CGContext, setColor: CGColor) {
        ctx.setStrokeColor(setColor)
        guard let firstPoint = points.first else { return }
        ctx.move(to: firstPoint)
        for point in points {
            ctx.addLine(to: point)
        }
        ctx.strokePath()

    }
    
    func drawDots(_ rect: CGRect, _ points: [CGPoint], ctx: CGContext, setColor: CGColor) {
        let plottedDotSize = self.plottedDotSize
        let halfsize = plottedDotSize / 2.0
        for point in points {
            let rect = CGRect(x: point.x - halfsize, y: point.y - halfsize, width: plottedDotSize, height: plottedDotSize)
            let path = UIBezierPath(ovalIn: rect)
            ctx.addPath(path.cgPath)
        }
        ctx.setFillColor(setColor)
        ctx.fillPath()
    }
    
    func drawRingCenteredOn(_ point: CGPoint, setColor: CGColor) {
        if let ctx = UIGraphicsGetCurrentContext() {
            let rect = CGRect(x: point.x - 8, y: point.y - 8, width: 16, height: 16)
            let path = UIBezierPath(ovalIn: rect)
            ctx.addPath(path.cgPath)
//            ctx.move(to: rect.origin)
//            ctx.addLine(to: .zero)
            ctx.setLineWidth(8.0)
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.setStrokeColor(setColor)
            ctx.strokePath()
        }
    }
    
    @objc func plotUpdated(_ notification: Notification) {
        guard let obj = notification.object as? NSObject, obj == plot else { return }
        setNeedsDisplay()
    }
    
    func drawGridlinesX(_ rect: CGRect, color: UIColor, in ctx: CGContext) {
        guard bounds.size.width != 0 else { return }
        ctx.setStrokeColor(color.cgColor)
        ctx.setFillColor(color.cgColor)
        let path = UIBezierPath()
        var x = Int(plot.minX.rounded(.down))
        let last = Int(plot.maxX.rounded(.up))
        while x < last {
            let pX = plot.pixelX(for: CGFloat(x), in: rect)
            if x % 5 == 0 {
                path.move(to: CGPoint(x: pX - 0.5, y: rect.origin.y))
                path.addLine(to: CGPoint(x: pX - 0.5, y: rect.origin.y + rect.size.height))
                path.move(to: CGPoint(x: pX + 0.5, y: rect.origin.y))
                path.addLine(to: CGPoint(x: pX + 0.5, y: rect.origin.y + rect.size.height))
            } else {
                path.move(to: CGPoint(x: pX, y: rect.origin.y))
                path.addLine(to: CGPoint(x: pX, y: rect.origin.y + rect.size.height))
            }
            x += 1
        }
        ctx.addPath(path.cgPath)
        ctx.drawPath(using: .stroke)
    }
    
    func drawGridlinesY(_ rect: CGRect, color: UIColor, in ctx: CGContext) {
        ctx.setStrokeColor(color.cgColor)
        ctx.setFillColor(color.cgColor)
        let path = UIBezierPath()
        var y = Int(plot.minY.rounded(.down))
        let lastY = Int(plot.maxY.rounded(.up))
        while y < lastY {
            let pY = plot.pixelY(for: CGFloat(y), in: rect)
            if y % 5 == 0 {
                path.move(to: CGPoint(x: rect.origin.x, y: pY - 0.5))
                path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: pY - 0.5))
                path.move(to: CGPoint(x: rect.origin.x, y: pY + 0.5))
                path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: pY + 0.5))
            } else {
                path.move(to: CGPoint(x: rect.origin.x, y: pY))
                path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: pY))
            }
            y += 1
        }
        ctx.addPath(path.cgPath)
        ctx.drawPath(using: .stroke)
    }
    var plotDots = true
    func plotDots(_ setColor: CGColor, in ctx: CGContext) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let first = touches.first {
            let pt = first.location(in: self)
            report(pt)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let first = touches.first {
            let pt = first.location(in: self)
            report(pt)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        delegate?.plotViewDidEndTap(self)
    }
    
    func report(_ pt: CGPoint) {
        let xlatX = plot.plotX(for: pt.x, in: self.bounds)
        print("xlatx = \(xlatX)")
        let xlatPt = CGPoint(x: xlatX, y: plot.yValue(for: xlatX).first)
        delegate?.plotView(self, didTap: pt, translatedPoint: xlatPt)
    }
}


