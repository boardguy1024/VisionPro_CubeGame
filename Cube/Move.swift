//
//  Move.swift
//  Cube
//
//  Created by paku on 2024/02/23.
//

import SwiftUI

enum Move: Character, CaseIterable {
    
    case U = "U" // upの面
    case F = "F" // frontの面
    case R = "R" // rightの面　 x軸を中心に回る(縦回り）
    
    var axis: Vector {
        switch self {
        case .U: Axis.Y
        case .F: Axis.Z
        case .R: Axis.X
        }
    }
    
    var filter: (Sticker) -> Bool {
        switch self {
        case .U: return { $0.position.y > 0 }
        case .F: return { $0.position.z > 0 }
        case .R: return { $0.position.x > 0 }
        }
    }
}

extension Cube {
    // 回転処理
    func apply(move: Move) -> Self {
        let predicated = move.filter
        
        let targetStickers = stickers.filter { predicated($0) }
        
        let moved = targetStickers.map { $0.rotate(on: move.axis, by: .clockwise)}
        let notMoved = stickers.filter { !predicated($0) }
        
        var newCube = Cube()
        newCube.stickers = moved + notMoved
        return newCube
    }
}
