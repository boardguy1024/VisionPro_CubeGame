//
//  Move.swift
//  Cube
//
//  Created by paku on 2024/02/23.
//

import SwiftUI

enum Move: Character, CaseIterable {
    
    case U = "U" // upの面
    case D = "D" // down面
    case L = "L"
    case F = "F" // frontの面
    case R = "R" // rightの面　 x軸を中心に回る(縦回り）
    case B = "B"
    case x = "x"
    case y = "y"
    case z = "z"
    
    var axis: Vector {
        switch self {
        case .U: Axis.Y
        case .D: Axis.Y.negative
        case .L: Axis.X.negative
        case .F: Axis.Z
        case .R: Axis.X
        case .B: Axis.Z.negative
        
        case .x: Axis.X
        case .y: Axis.Y
        case .z: Axis.Z
        }
    }
    
    var filter: (Sticker) -> Bool {
        switch self {
        case .U: return { $0.position.y > 0 }
        case .D: return { $0.position.y < 0 }
        case .L: return { $0.position.x < 0 }
        case .F: return { $0.position.z > 0 }
        case .R: return { $0.position.x > 0 }
        case .B: return { $0.position.z < 0 }
        case .x: return { _ in true }
        case .y: return { _ in true }
        case .z: return { _ in true }
        }
    }
}

extension Cube {
    // 回転処理
    // prime : 反時計回りかどうか
    // twice : 180°
    func apply(move: Move, prime: Bool = false, twice: Bool = false) -> Self {
        let predicated = move.filter
        let targetStickers = stickers.filter { predicated($0) }
        
        let angle: Rotation = twice ? .filp : prime ? .counterClockwire : .clockwise
        let moved = targetStickers.map { $0.rotate(on: move.axis, by: angle)}
        let notMoved = stickers.filter { !predicated($0) }
        
        var newCube = Cube()
        newCube.stickers = moved + notMoved
        return newCube
    }
}
