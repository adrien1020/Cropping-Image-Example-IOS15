//
//  CroppingModel.swift
//  Cropping Image Example
//
//  Created by Adrien Surugue on 08/08/2022.
//

import Foundation
import SwiftUI

enum Side {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    var operation: ((CGFloat, CGFloat) -> CGFloat, (CGFloat, CGFloat) -> CGFloat){
        
        let xOperator: (CGFloat, CGFloat) -> CGFloat
        let yOperator: (CGFloat, CGFloat) -> CGFloat
        
        switch self {
        case .topLeft:
            xOperator = (+)
            yOperator = (+)
            return (xOperator, yOperator)
        case .topRight:
            xOperator = (-)
            yOperator = (+)
            return (xOperator, yOperator)
        case .bottomLeft:
            xOperator = (+)
            yOperator = (-)
            return (xOperator, yOperator)
        case .bottomRight:
            xOperator = (-)
            yOperator = (-)
            return (xOperator, yOperator)
        }
    }
    var comparison: ((CGFloat, CGFloat) -> Bool, (CGFloat, CGFloat) -> Bool){
        
        let xComparisonOperator: (CGFloat, CGFloat) -> Bool
        let yComparisonOperator: (CGFloat, CGFloat) -> Bool
        
        switch self{
        case .topLeft:
            xComparisonOperator = (<=)
            yComparisonOperator = (<=)
            return (xComparisonOperator, yComparisonOperator)
        case .topRight:
            xComparisonOperator = (>=)
            yComparisonOperator = (<=)
            return (xComparisonOperator, yComparisonOperator)
        case .bottomLeft:
            xComparisonOperator = (<=)
            yComparisonOperator = (>=)
            return (xComparisonOperator, yComparisonOperator)
        case .bottomRight:
            xComparisonOperator = (>=)
            yComparisonOperator = (>=)
            return (xComparisonOperator, yComparisonOperator)
        }
    }
    var sides: (Bool, Bool){
        
        var isTopSide = false
        var isLeftSide = false
        
        switch self{
        case .topLeft:
            isTopSide = true
            isLeftSide = true
            return (isTopSide, isLeftSide)
        case .topRight:
            isTopSide = true
            isLeftSide = false
            return (isTopSide, isLeftSide)
        case .bottomRight:
            isTopSide = false
            isLeftSide = false
            return (isTopSide, isLeftSide)
        case .bottomLeft:
            isTopSide = false
            isLeftSide = true
            return (isTopSide, isLeftSide)
        }
    }
}
