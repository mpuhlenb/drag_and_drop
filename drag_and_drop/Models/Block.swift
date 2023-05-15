//
//  Block.swift
//  drag_and_drop
//
//  Created by Morris Uhlenbrauck on 5/15/23.
//

import Foundation

struct Block: Codable {
    let id: String
    var xCoordinate: CGFloat
    var yCoordinate: CGFloat
    let height: CGFloat
    let width: CGFloat
    
    init(xCoordinate: CGFloat, yCoordinate: CGFloat, height: CGFloat, width: CGFloat) {
        self.id = UUID().uuidString
        self.xCoordinate = xCoordinate
        self.yCoordinate = yCoordinate
        self.height = height
        self.width = width
    }
}
