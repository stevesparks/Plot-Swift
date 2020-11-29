//
//  PlotTests.swift
//  PlotTests
//
//  Created by Steve Sparks on 10/23/20.
//

import XCTest
@testable import Plot

class PlotTests: XCTestCase {
    let plot = Plot()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLinearPlot() throws {
        let plot = Plot()
        plot.plotDensity = 0.1
        plot.minY = 0.0
        plot.function = { .real($0) }
        
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let points = plot.points(for: rect)

        XCTAssertEqual(points.count, 12)
        XCTAssertEqual(points[1].y, 90, accuracy: 0.1)
        XCTAssertEqual(points[2].y, 80, accuracy: 0.1)
        XCTAssertEqual(points[3].y, 70, accuracy: 0.1)
        XCTAssertEqual(points[4].y, 60, accuracy: 0.1)
        XCTAssertEqual(points[5].y, 50, accuracy: 0.1)
        
        XCTAssertEqual(points[1].x, 10, accuracy: 0.1)
        XCTAssertEqual(points[2].x, 20, accuracy: 0.1)
        XCTAssertEqual(points[3].x, 30, accuracy: 0.1)
        XCTAssertEqual(points[4].x, 40, accuracy: 0.1)
        XCTAssertEqual(points[5].x, 50, accuracy: 0.1)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testDualPlot() throws {
        let plot = Plot()
        plot.plotDensity = 0.1
        plot.function = {
            if $0 == 0.0 { return .real($0) } else { return .multiple([$0, 0.0 - $0]) }
        }
        
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let points = plot.points(for: rect, inPosition: -1)
        
        XCTAssertEqual(points.count, 23)
        XCTAssertEqual(points[1].x, 10, accuracy: 0.1)
        XCTAssertEqual(points[3].x, 20, accuracy: 0.1)
        XCTAssertEqual(points[5].x, 30, accuracy: 0.1)
        XCTAssertEqual(points[7].x, 40, accuracy: 0.1)
        XCTAssertEqual(points[9].x, 50, accuracy: 0.1)

        XCTAssertEqual(points[1].y, 45, accuracy: 0.1)
        XCTAssertEqual(points[2].y, 55, accuracy: 0.1)
        XCTAssertEqual(points[3].y, 40, accuracy: 0.1)
        XCTAssertEqual(points[4].y, 60, accuracy: 0.1)
        XCTAssertEqual(points[5].y, 35, accuracy: 0.1)
    }
    
    func testPixelX() {
        let plot = Plot()
        plot.minX = -1.0
        plot.maxX = 1.0
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let x = plot.pixelX(for: 0.5, in: rect)
        XCTAssertEqual(x, 75.0)
    }

    func testPlotX() {
        let plot = Plot()
        plot.minX = -1.0
        plot.maxX = 1.0
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let x = plot.plotX(for: 50.0, in: rect)
        XCTAssertEqual(x, 0.0, accuracy: 0.1)
    }

}
