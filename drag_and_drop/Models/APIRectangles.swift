//
//  APIRectangles.swift
//  drag_and_drop
//
//  Created by Morris Uhlenbrauck on 5/15/23.
//

import Foundation

struct APIRectangles: Decodable {
    let rectangles: [APIRectangle]
}

struct APIRectangle: Decodable {
    let x: Float
    let y: Float
    let size: Float
}
