//
//  PossibleValueTests.swift
//  PlotTests
//
//  Created by Steve Sparks on 10/23/20.
//

import XCTest
@testable import Plot

class PossibleValueTests: XCTestCase {
    override func setUp() {
        
    }
    override func tearDown() {
        
    }

    func testPossible() {
        let p1 = FunctionReturnValue.PossibleValue(value: 2.0, chances: 1)
        let p2 = FunctionReturnValue.PossibleValue(value: 42.0, chances: 1)
        let p3 = FunctionReturnValue.PossibleValue(value: 142.0, chances: 1)
        let possible = FunctionReturnValue.oneOf([p1, p2, p3])

        var twosFound = 0
        var fortyTwosFound = 0
        var hunnitFortyTwosFound = 0
        for x in 1...100 {
            let v = possible.any
            if v == 2 {
                twosFound += 1
            } else if v == 42 {
                fortyTwosFound += 1
            } else if v == 142 {
                hunnitFortyTwosFound += 1
            } else {
                XCTFail()
                print("unex: iter \(x) returned \(v)")
            }
        }
        print("Log out -> \(twosFound) \(fortyTwosFound) \(hunnitFortyTwosFound)")
        XCTAssertGreaterThan(twosFound, 25)
        XCTAssertGreaterThan(fortyTwosFound, 25)
        XCTAssertGreaterThan(hunnitFortyTwosFound, 25)
        XCTAssertLessThan(twosFound, 50)
        XCTAssertLessThan(fortyTwosFound, 50)
        XCTAssertLessThan(hunnitFortyTwosFound, 50)
    }
    
    func testBasicRealValue() {
        let result = FunctionReturnValue.real(10.0)
        XCTAssertEqual(result.any, 10.0)
    }
    
    func testMultipleValues() {
        let val = FunctionReturnValue.multiple([1,2,3])
        
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertTrue([1,2,3].contains(val.any))
        XCTAssertEqual([1,2,3], val.all)
    }
}
