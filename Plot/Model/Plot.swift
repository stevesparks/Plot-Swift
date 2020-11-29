//
//  Plot.swift
//  Plot
//
//  Created by Steve Sparks on 11/2/20.
//

import UIKit

extension Notification.Name {
    static let plotUpdated = Notification.Name("plotUpdated")
}

class Plot: NSObject {
    var minX: CGFloat = 0.0 { didSet { notify() } }
    var maxX: CGFloat = 1.0 { didSet { notify() } }
    var minY: CGFloat = -1.0 { didSet { notify() } }
    var maxY: CGFloat = 1.0 { didSet { notify() } }
    var plotDensity: CGFloat? { didSet { notify() } }

    var provider: PlotProvider? {
        didSet {
            self.provider?.updater = { [weak self] in
                self?.notify()
            }
            self.notify()
        }
    }
    
    lazy var function: PlotFunction = { xValue in
        return self.provider?.yValue(for: xValue) ?? .real(0)
    } { didSet { notify() } }

    func notify() {
        NotificationCenter.default.post(name: .plotUpdated, object: self)
    }
    
    func yValue(for xValue: CGFloat) -> FunctionReturnValue<CGFloat> {
        return function(xValue)
    }
    

    func points(for rect: CGRect, inPosition position: Int = -1) -> [CGPoint] {
        var returnPoints = [CGPoint]()
        
        guard maxX - minX > 0, maxY - minY > 0 else { return [] }
        
        func point(for plottedX: CGFloat, _ plottedY: CGFloat) -> CGPoint {
            return self.point(for: plottedX, plottedY, in: rect)
        }
        
        for plottedXValue in plottableXValues {
            let result = function(plottedXValue)
            switch result {
            case .real(let plottedYValue):
                returnPoints.append(point(for: plottedXValue, plottedYValue))
            case .oneOf(_):
                returnPoints.append(point(for: plottedXValue, result.pickOne()))
            case .multiple(let allYValues):
                if position == -1 {
                    for plottedYValue in allYValues {
                        returnPoints.append(point(for: plottedXValue, plottedYValue))
                    }
                } else {
                    guard position < allYValues.count else { break }
                    let plottedYValue = allYValues[position]
                    returnPoints.append(point(for: plottedXValue, plottedYValue))
                }
            }
        }
        
//        while tempPixelX <= (rect.origin.x + rect.size.width + pixD) {
//            let result = function(plottedXValue)
//            switch result {
//            case .real(let plottedYValue):
//                returnPoints.append(point(for: plottedXValue, plottedYValue))
//            case .oneOf(_):
//                returnPoints.append(point(for: plottedXValue, result.pickOne()))
//            case .multiple(let allYValues):
//                if position == -1 {
//                    for plottedYValue in allYValues {
//                        returnPoints.append(point(for: plottedXValue, plottedYValue))
//                    }
//                } else {
//                    guard position < allYValues.count else { break }
//                    let plottedYValue = allYValues[position]
//                    returnPoints.append(point(for: plottedXValue, plottedYValue))
//                }
//            }
//
//            plottedXValue += plotDensity
//            tempPixelX += pixD
//        }
        return returnPoints
    }
    
    func pointSets(for rect: CGRect) -> [[CGPoint]] {
        var returnPoints = [[CGPoint]]()
        let ct = maximumNumberOfValuesForX
        for x in 0..<ct {
            returnPoints.append(points(for: rect, inPosition: x))
        }
        
        return returnPoints
    }
}

// Info about the plot
extension Plot {
    var pointsHorizontally: Int {
        guard let plotDensity = plotDensity else { return 1000 }
        return Int((maxX - minX) / plotDensity) + 1
    }
    
    var plottableXValues: [CGFloat] {
        var retval = [CGFloat]()
        
        let plotDensity = self.plotDensity ?? (maxX - minX) / 100.0
        var plottedXValue = minX

        while plottedXValue <= (maxX + plotDensity) {
            retval.append(plottedXValue)
            plottedXValue += plotDensity
        }
        
        return retval
    }
    
    // Take 100 samples over max/min and see if any return multiple values.
    var maximumNumberOfValuesForX: Int {
        var maxPoints = 0
        for plottedXValue in plottableXValues {
            let pointCount: Int = {
                switch function(plottedXValue) {
                case .multiple(let allYValues):
                    return allYValues.count
                default:
                    return 1
                }
            }()
            maxPoints = max(maxPoints, pointCount)
        }
        
        return maxPoints
    }
    
    func nearestPlottableX(to x: CGFloat) -> CGFloat {
        var distance = CGFloat.greatestFiniteMagnitude
        var result: CGFloat = x
        
        for val in plottableXValues {
            let dist = abs(val - x)
            if dist < distance {
                distance = dist
                result = val
            }
        }
        return result
    }
}

// MARK: - Translation
extension Plot {
    func point(for plottedX: CGFloat, _ plottedY: CGFloat, in rect: CGRect) -> CGPoint {
        let px = pixelX(for: plottedX, in: rect)
        let py = pixelY(for: plottedY, in: rect)
        
        return CGPoint(x: px, y: py)
    }
    
    func pixelX(for plotX: CGFloat, in rect: CGRect) -> CGFloat {
        guard rect.size.width > 0 else { return 0 }
        let scale = UIScreen.main.scale
        let xPerPoint = (maxX - minX) / rect.size.width // spread of X per screen point

        return (scale * (rect.origin.x + (plotX - minX)) / xPerPoint).rounded(.toNearestOrAwayFromZero) / scale
    }
    
    func pixelY(for plotY: CGFloat, in rect: CGRect) -> CGFloat {
        guard rect.size.height > 0 else { return 0 }
        let scale = UIScreen.main.scale
        let yPerPoint = (maxY - minY) / rect.size.height // spread of Y per screen point
        let pixY = (scale * (rect.origin.y + (plotY - minY)) / yPerPoint).rounded(.toNearestOrAwayFromZero) / scale
        
        return rect.size.height - pixY
    }

    func plotX(for pixelX: CGFloat, in rect: CGRect) -> CGFloat {
        guard maxX - minX > 0, rect.size.width > 0 else { return 0 }
        let pixelXPerPoint = rect.size.width / (maxX - minX)  // spread of X per screen point
        print("rect width = \(rect.size.width)")
        print("xSpread = \(maxX - minX)")
        print("max x = \(maxX)")
        print("pixelXPerPoint = \(pixelXPerPoint)")

        let val = minX + ((pixelX - rect.origin.x) / pixelXPerPoint)
        print("val = \(val)")
        return nearestPlottableX(to: val)
    }

    func plotY(for pixelY: CGFloat, in rect: CGRect) -> CGFloat {
        guard maxY - minY > 0, rect.size.height > 0 else { return 0 }
        let yPerPoint = rect.size.height / maxY - minY  // spread of Y per screen point

        return (pixelY - rect.origin.y) / yPerPoint
    }
}

