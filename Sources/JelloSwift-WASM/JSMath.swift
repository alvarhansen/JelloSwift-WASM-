//
//  Foundation.swift
//  physix2
//
//  Created by Alvar Hansen on 24.02.2021.
//

import Foundation

struct Dimension {
    var width: Double
    var height: Double
}
typealias Size = Dimension

struct Point {
    var x: Double
    var y: Double

    static let zero = Point(x: 0, y: 0)
//    var vector: Vector2 { Vector2(x: x, y: y) }
}

//struct Vector2 {
//    var x: Double
//    var y: Double
//
//    static let zero = Vector2(x: 0, y: 0)
//}

//extension Vector2 {
//    var magnitude: Double { sqrt(pow(x, 2) + pow(y, 2)) }
//}

func +(_ lhs: Point, rhs: Point) -> Point {
    Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
//func +(_ lhs: Point, rhs: Vector2) -> Point {
//    Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
//}
//
//func -(_ lhs: Point, rhs: Vector2) -> Point {
//    Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
//}

func -(_ lhs: Point, rhs: Point) -> Point {
    Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
func *(_ lhs: Point, rhs: Double) -> Point {
    Point(x: lhs.x * rhs, y: lhs.y * rhs)
}

func /(_ lhs: Point, rhs: Double) -> Point {
    Point(x: lhs.x / rhs, y: lhs.y / rhs)
}
//
//func -(_ lhs: Point, rhs: Vector2) -> Vector2 {
//    Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
//}
//
//func *(_ lhs: Vector2, rhs: Double) -> Vector2 {
//    Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
//}
//
//func /(_ lhs: Vector2, rhs: Double) -> Vector2 {
//    Vector2(x: lhs.x / rhs, y: lhs.y / rhs)
//}
//
//func +(_ lhs: Vector2, rhs: Vector2) -> Vector2 {
//    Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
//}



struct JSRect {
    var origin: Point
    var size: Dimension

    var x: Double { origin.x }
    var y: Double { origin.y }
    var width: Double { size.width }
    var height: Double { size.height }
}
